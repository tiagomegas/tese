require 'twitter'
require 'sequel'
require 'active_support/time'


class TwitterAPI

  def initialize
    
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

  #simple API methods
  def update(status)

    Twitter.update(status)

  end

  def getFriends(userid,cursor)

    begin
    
    response = Twitter.friend_ids(userid, {:cursor=>cursor})

      rescue Twitter::Error::TooManyRequests => error
        puts "#{Time.now}: Rate Limit hit! Going to sleep for #{error.rate_limit.reset_in}"
        sleep error.rate_limit.reset_in
        retry
    
      rescue Twitter::Error::BadGateway => error
        puts "#{Time.now}: BadGateway ERRa!!1"
        sleep 5
        retry
    
      rescue Twitter::Error::ClientError => error
        puts "#{Time.now}: Client Error!"
        retry

      rescue Twitter::Error::ServiceUnavailable => error
        puts "#{Time.now}: Service is down! Over Capacity Error!" 
        retry
    
    end
   end
  
  # term é o contéudo da query. Count vai de 0 a 100 por chamada. Since_id é o limite min de tweet, sendo que 0 o default.
  def searchTerm(term,count,since_id)
    begin
      
    response = Twitter.search(term,{:count=>count, :since_id=>since_id})
    
    rescue Twitter::Error::TooManyRequests => error
      puts "#{Time.now}: Rate Limit hit! Going to sleep for #{error.rate_limit.reset_in}"
      sleep error.rate_limit.reset_in
      retry

    rescue Twitter::Error::BadGateway => error
      puts "#{Time.now}: BadGateway ERRa!!1"
      retry

    rescue Twitter::Error::ServiceUnavailable => error
      puts "#{Time.now}: Service is down! Over Capacity Error!" 
      retry

      rescue Twitter::Error::Unauthorized => error
        puts "#{Time.now}: Could not authenticate you" 
      

    
    end

    
   end

  def getFollowers(userid,cursor)
    
    begin
    response = Twitter.follower_ids(userid, {:cursor=>cursor})
    
    rescue Twitter::Error::TooManyRequests => error
      puts "#{Time.now}: Rate Limit hit! Going to sleep for #{error.rate_limit.reset_in}"
      sleep error.rate_limit.reset_in
      retry
    
    rescue Twitter::Error::BadGateway => error
      puts "#{Time.now}: BadGateway ERRa!!1"
      retry
    
    rescue Twitter::Error::ClientError => error
      puts "#{Time.now}: Client Error!"
      retry

    rescue Twitter::Error::ServiceUnavailable => error
      puts "#{Time.now}: Service is down! Over Capacity Error!" 
      retry
    
    end
  end

  def lookUpUser(id)
    
   begin
    user = Twitter.user(id)
    
    rescue Twitter::Error::TooManyRequests => error
      puts "#{Time.now}: Rate Limit hit! Too many requests! Going to sleep for #{error.rate_limit.reset_in}"
      sleep error.rate_limit.reset_in
      retry
    
    rescue Twitter::Error::BadGateway => error
      puts "#{Time.now}: BadGateway Error!"
      retry
    
    rescue Twitter::Error::ClientError => error
      puts "#{Time.now}: Client Error!"
    
    rescue Twitter::Error::ServiceUnavailable => error
      puts "#{Time.now}: Service is down! Over Capacity Error!" 
      retry  
    
    end
  end

  def lookUpUsers(ids)
   begin
    userlist = Twitter.users(ids)
    
    rescue Twitter::Error::TooManyRequests => error
      puts "#{Time.now}: Rate Limit hit! Too many requests! Going to sleep for #{error.rate_limit.reset_in} seconds"
      sleep error.rate_limit.reset_in
      retry
    
    rescue Twitter::Error::BadGateway => error
      puts "#{Time.now}: BadGateway Error!"
      retry
    
    rescue Twitter::Error::ClientError => error
      puts "#{Time.now}: Client Error!"
      userlist={}
    
      
    rescue Twitter::Error::ServiceUnavailable => error
      puts "#{Time.now}: Service is down! Over Capacity Error!" 
      retry

    rescue Twitter::Error::InternalServerError => error
      puts "Something is technically wrong."
      retry
    end
  end

# Methods that using the simple ones above combined, get more information
# and those are the ones that really matter to accomplish the research

# Gets all the ids of the followers from a certain user(userid). The followerscount
# argument is to control the number of times the getFollowers method should be invoked.
# returns the complete list of followers ids
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

  def getAllFriends(userid,friendscount)
      puts userid      
      count = friendscount/5000
      puts count
      
      if count == 0  
        friends = self.getFriends(userid,-1).ids
      else
        response = self.getFriends(userid,-1)
        friends = response.ids
        
        count.times do
          puts "."
          response = self.getFriends(userid,response.next_cursor)
          friends.concat(response.ids)
          puts friends.length  
        end
      
      end
      friends
  end


# Gets all the user Info regarding a list of followers. 
#It now works for followers and friends, despite the variables refering to followers
  def getUsersInfo(followers)
    followerlist = Array.new

    chunkfollowers = followers.each_slice(100).to_a
    chunkfollowers.each{ |item|
      puts "#{Time.now}: Slicing list!"
      response = self.lookUpUsers(item)
      followerlist.concat(response) }

    followerlist
    
  end

  #metodo a não ser usado!
  def verifyUser(user)
    dataset = @db[:utilizadorporfriendfol]
    idusers = Array.new
    allusers = dataset.all
    
    allusers.each { |item|
      idusers.push(item[:id]) }
    idusers.include? user.id
  end
  
  # Methods used to check user values and to test and filter them
  # Using one month to determine wether the user is active or not
  def checkLastStatusDate(user)
    if user.status == nil 
        false
    end
    
    user.status.created_at > 1.month.ago 
  end

  def checkIfTimeZonePT(user)
    user.time_zone == 'Lisbon'
  end

  # Verify location: Needs to be more complex
  def checkLocationPT(user)
   
    user.location == 'Portugal'
  end

  def filterValidUsers(users)
    list = Array.new
    users.each { |item|
        if checkIfTimeZonePT(item) && checkLastStatusDate(item)
          list.push(item)
        end }
    list
  end

  def verifyUserId(id, alluserids)
    #returns true if id in array
    alluserids.include? id
  end


  #from an array of ids, only does the lookup for the ones that
  #don't belong in DB. Returns array of users
  def lookUpNewUsers(userids, savedids)
 
    listusers = Array.new

    userids.each{ |item|
      listusers.push(item) unless self.verifyUserId(item, savedids)
    }

    self.lookUpUsers(listusers)
   end

  def filterNewUsers(userids, savedids)
    listusers = Array.new

    userids.each{ |item| 
      listusers.push(item) unless self.verifyUserId(item, savedids) }

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

   

    #gets all uncrawled users from DB    
end 