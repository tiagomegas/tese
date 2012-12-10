require 'twitter'
require 'sequel'
require 'active_support/time'
require './database.rb'

class CrawlingUsers

#  @db = Database.connect('Tese','localhost')
  
  
  def initialize
    @db = Sequel.connect(:database=>'Tese',:adapter=>'mysql2', :host=>'localhost', :user=>'root', :password=>'2001odisseianoespaco')
    self.configure
  end

  def configure
    Twitter.configure do |config|
      config.consumer_key = "5HwJKF261Qal0p1ZAmMLZg"
      config.consumer_secret = "mPlbSLkoADM6GqfxWr6O56CQQ3TWYKHp14It8ATzIQ"
      config.oauth_token = "8837772-Q3U75L99eMHMXXlq8nnp7NnQt7dxNJPbjzAUPvRxTq"
      config.oauth_token_secret = "g6qCacAdPFnFbufr7kEykW86KJo8LMejZbpqMNM"
      puts 'Credentials activated'
    end
  end

  def buildSeed(names)
   
    seed = self.lookUpUsers(names)
    self.insertUsers(seed)

  end

  def update(status)
    Twitter.update(status)
  end

  def getFriends(name)
    ids = Twitter.friend_ids(name)
  end
  

  def getFollowers(userid,cursor)
    begin
    response = Twitter.follower_ids(userid, {:cursor=>cursor})
    
    rescue Twitter::Error::TooManyRequests => error
      puts "Rate Limit of #{error.rate_limit} hit!"
      sleep error.rate_limit.reset_in
      retry
    
    rescue Twitter::Error::BadGateway => error
      retry
    
    rescue Twitter::Error::ClientError => error
      retry
    end
  
  end

 def getAllFollowers(userid,followerscount)
      puts userid      
      count = followerscount/5000
      puts count
      
      if count == 0  
        followers = self.getFollowers(userid,-1).ids
      else
        response = self.getFollowers(userid,-1)
        followers = response.ids
        
        count.times do
          puts "."
          response = self.getFollowers(userid,response.next_cursor)
          followers.concat(response.ids)
          puts followers.length  
        end
      
      end
      followers
  end
  

  def lookUpUser(id)
    
   begin
    user = Twitter.user(id)
    
    rescue Twitter::Error::TooManyRequests => error
      puts "Rate Limit of #{error.rate_limit} hit!"
      sleep error.rate_limit.reset_in
      retry
    
    rescue Twitter::Error::BadGateway => error
      retry
    
    rescue Twitter::Error::ClientError => error
      retry
    
    end
  end

  def lookUpUsers(ids)
   begin
    userlist = Twitter.users(ids)
    
    rescue Twitter::Error::TooManyRequests => error
      puts "Rate Limit of #{error.rate_limit} hit!"
      sleep error.rate_limit.reset_in
      retry
    
    rescue Twitter::Error::BadGateway => error
      retry
    
    rescue Twitter::Error::ClientError => error
      retry
    end
  end

  def insertUser(user)
    dataset=@db[:utilizador]
    
    dataset.insert(:name=> user.name, 
                   :id=> user.id, 
                   :screen_name=>user.screen_name,
                   :location=> user.location, 
                   :url=>user.url, 
                   :followers_count=>user.followers_count,
                   :friends_count=>user.friends_count,
                   :lang=>user.lang,
                   :crawled=>false)
  end

  def insertFollower(userid, followerid)
    dataset=@db[:seguidores]

    dataset.insert(:id=> userid,
                   :followerid=> followerid)
  end

  def InsertFollowers(userid, followersid)
    followersid.each{ |item| 
      self.insertFollower(userid, item)
      puts "Inseri relacao de seguidor!" 
    }
  end

  def checkLastStatusDate(user)
    # Using one month to determine wether the user is active or not
    if user.status == nil 
      return false
    end
    
    user.status.created_at > 1.month.ago 
  end

  def checkIfTimeZonePT(user)
    user.time_zone == 'Lisbon'
  end

  def checkLocationPT(user)
    #Verify location: Needs to be more complex
    user.location == 'Portugal'
  end


  def getFollowersInfo(followers)
    followerlist = Array.new

    chunkfollowers = followers.each_slice(100).to_a
    chunkfollowers.each{ |item|
      puts "Slicing list!"
      response = self.lookUpUsers(item)
      followerlist.concat(response) }

    return followerlist
    
  end

  def filterValidUsers(users)
    list = Array.new
    users.each { |item|
        if checkIfTimeZonePT(item) && checkLastStatusDate(item)
          list.push(item)
        end }
    list
  end

  def insertUsers(users)
    users.each {|item|
      self.insertUser(item)}
  end

  # def verifyUser(user)
  #   dataset = @db[:utilizador]
  #   idusers = Array.new
  #   allusers = dataset.all
    
  #   allusers.each { |item|
  #     idusers.push(item[:id]) }
  #   idusers.include? user.id
  # end

  def verifyUserId(id, alluserids)
    #returns true if id in array
    alluserids.include? id
  end

  def getUserIdsFromDb
    idusers = Array.new
    dataset = @db[:utilizador]
    allusers = dataset.all    

    allusers.each { |item|
      idusers.push(item[:id]) }

    return idusers
  end

  def insertNewUsers(userid, users)
    #modificar para fazer mais sentido
    self.InsertFollowers(userid,users[1])

    users[0].each { |item|
      puts "user:" + item.screen_name
      self.insertUser(item)
      puts "Inseri item!"
      self.insertFollower(userid,item.id)
      puts "Inseri relacao de seguidor!"
      }

  end

  def lookUpNewUsers(userids, savedids)
    #from an array of ids, only does the lookup for the ones that
    #don't belong in DB. Returns array of users
    listusers = Array.new

    userids.each{ |item| 
      if !self.verifyUserId(item, savedids)
          listusers.push(item)
      end }

    self.lookUpUsers(listusers)
   end

   def filterNewUsers(userids, savedids)
    listusers = Array.new

    userids.each{ |item| 
      if !self.verifyUserId(item, savedids)
          listusers.push(item)
      end }



    listusers

   end

    def filterRepeatedUsers(userids, savedids)
    listusers = Array.new

    userids.each{ |item| 
      if self.verifyUserId(item, savedids)
          listusers.push(item)
      end }
  
    listusers

   end
      
   def getUncrawledUsers
     #gets all uncrawled users from DB
     idusers = Hash.new
     dataset = @db[:utilizador]
     uncrawledusers = dataset.filter(:crawled => 0)  

     uncrawledusers.each { |item|
      idusers.store(item[:id],item[:followers_count]) }

    return idusers
   end

  def crawlUser(iduser, followerscount)
    dataset = @db[:utilizador]
    savedids = self.getUserIdsFromDb
    
    listusersids = self.getAllFollowers(iduser, followerscount)

    # to filter the users that are new to the DB
    #newusers = self.filterNewUsers(listusersids, savedids)
  
    #filter the already in DB users
    oldusers = self.filterRepeatedUsers(listusersids, savedids)
    
    # to get all the info from the users.listuserids-oldusers give
    # only the new users
    listusers = self.getFollowersInfo(listusersids-oldusers)
   
     #analyse the user's info, to filter the valid users
    filteredusers = self.filterValidUsers(listusers)

    dataset.where(:id => iduser).update(:crawled=>true)

    return filteredusers, oldusers

  end

  def crawlAndSave(iduser, followerscount)
    crawlresponse = self.crawlUser(iduser, followerscount)
    
    self.insertNewUsers(iduser, crawlresponse)
  end

  def crawlAllUsers
    uncrawled = self.getUncrawledUsers
    
    if uncrawled == nil
      puts "no more users to crawl! The end!"
      return  
    end

    uncrawled.each { |key, value| 
      self.crawlAndSave(key, value)
    }

    crawlAllUsers
    
  end
    
end 