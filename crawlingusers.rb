require 'twitter'
require 'sequel'
require 'oj'
require 'active_support/time'

class TwitterInspector

  $db = Sequel.connect(:database=>'Tese',:adapter=>'mysql2', :host=>'localhost', :user=>'root', :password=>'2001odisseianoespaco')

  def init 
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

  def update(status)
    Twitter.update(status)
  end

  def getFriends(name)
    ids = Twitter.friend_ids(name)
  end
  

  def getFollowers(seedname,cursor)
    begin
    response = Twitter.follower_ids(seedname, {:cursor=>cursor})
    rescue Twitter::Error::TooManyRequests => error
      puts "Rate Limit of #{error.rate_limit} hit!"
      sleep error.rate_limit.reset_in
      retry
    end
  end

 def getAllFollowers(user)
      puts user.screen_name      
      count = user.followers_count/5000
      puts count
      
      if count == 0  
        followers = self.getFollowers(user.screen_name,-1).ids
      else
        followers = self.getFollowers(user.screen_name,-1).ids
        count.times do
          puts "."
          response = self.getFollowers(user.scree_name,response.next_cursor)
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
    end
  end

  def lookUpUsers(ids)
   begin
    userlist = Twitter.users(ids)
    rescue Twitter::Error::TooManyRequests => error
      puts "Rate Limit of #{error.rate_limit} hit!"
      sleep error.rate_limit.reset_in
      retry
    end
  end

  def insertUser(user)
    dataset=$db[:utilizador]
    
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

  def getAllFollowersInfo(user)
    followers = self.getAllFollowers(user)
    followerlist = Array.new
    chunkfollowers = followers.each_slice(100).to_a
    chunkfollowers.each { |item|
      puts "Getting users chunks up! lets do this!"
      response = self.lookUpUsers(item)
      followerlist.concat(response) }
    followerlist
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

  def verifyUser(user)
    dataset = $db[:utilizador]
    idusers = Array.new
    allusers = dataset.all
    allusers.each { |item|
      idusers.push(item[:id]) }
    idusers.include? user.id
  end

  def verifyUserId(id, alluserids)
    #returns true if id in array
    alluserids.include? id
  end

  def getUserIdsFromDb
    idusers = Array.new
    dataset = $db[:utilizador]
    allusers = dataset.all    

    allusers.each { |item|
      idusers.push(item[:id]) }

    return idusers
  end

  def insertNewUsers(users)
    #modificar para fazer mais sentido
    users.each { |item|
      puts "user:" + item.screen_name
      if !self.verifyUser(item) 
        puts "Inseri item!"
        self.insertUser(item)
        end
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

   def getUncrawledUsers
     #gets all uncrawled users from DB
     idusers = Array.new
     dataset = $db[:utilizador]
     uncrawledusers = dataset.filter(:crawled => 0)  

     uncrawledusers.each { |item|
      idusers.push(item[:id]) }

    return idusers
   end

  
end