require 'twitter'
require './database.rb'
require 'active_support/time'

class TwitterAPI

  def initialize
    
    self.configure
    
  end

  def configure
    
    #setting the credentials

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
    method="utilizadorporfriend_getfriends"

    begin
    
    userlist= Twitter.friend_ids(userid, {:cursor=>cursor})

    rescue Twitter::Error::BadRequest => error
      Database.insertErrorInTable(:badrequest,method)
      puts "#{Time.now}: Bad Request!"
      Database.insertInvocation(method,Time.now,2,0)
      userlist={}

    rescue Twitter::Error::Forbidden => error
      Database.insertErrorInTable(:forbidden,method)
      puts "#{Time.now}: Forbidden!"
      Database.insertInvocation(method,Time.now,3,0)
      userlist={}

    rescue Twitter::Error::NotAcceptable => error
      Database.insertErrorInTable(:notacceptable,method)
      Database.insertInvocation(method,Time.now,4,0)
      puts "#{Time.now}: Not Acceptable!"
     

    rescue Twitter::Error::NotFound => error
      Database.insertErrorInTable(:notfound,method)
      Database.insertInvocation(method,Time.now,5,0)
      puts "#{Time.now}: Not Found!"


    rescue Twitter::Error::Unauthorized=> error
      Database.insertErrorInTable(:unauthorized,method)
      Database.insertInvocation(method,Time.now,6,0)
      puts "#{Time.now}: Unauthorized!"

      

    rescue Twitter::Error::UnprocessableEntity=> error
      Database.insertErrorInTable(:unprocessableentity,method)
      Database.insertInvocation(method,Time.now,7,0)
      puts "#{Time.now}: Unprocessable Entity!"
      userlist={}
    #

    rescue Twitter::Error::TooManyRequests => error
      puts "#{Time.now}: Rate Limit hit! Going to sleep for #{error.rate_limit.reset_in}"
      Database.insertInvocation(method,Time.now,8,0)
      Database.insertErrorInTable(:toomany,method)
      sleep error.rate_limit.reset_in
      retry
    
      rescue Twitter::Error::BadGateway => error
        puts "#{Time.now}: BadGateway ERRa!!1"
        Database.insertInvocation(method,Time.now,9,0)
        Database.insertErrorInTable(:badgateway,method)
        sleep 5
        retry
  
      rescue Twitter::Error::ServiceUnavailable => error
        Database.insertErrorInTable(:serviceunav,method)
        Database.insertInvocation(method,Time.now,10,0)
        puts "#{Time.now}: Service is down! Over Capacity Error!" 
        retry

        rescue Twitter::Error::InternalServerError => error
        Database.insertErrorInTable(:internalserv,method)
        Database.insertInvocation(method,Time.now,11,0)
        puts "#{Time.now}: InternalServerError: Something is technically wrong." 
        retry

        rescue Twitter::Error::ClientError => error
          Database.insertInvocation(method,Time.now,12,0)
        Database.insertErrorInTable(:clienterror,method)
        puts "#{Time.now}: Weird bug isn't it?"
        retry

        else 
          Database.insertInvocation(method,Time.now,1,userlist.ids.length)
          return userlist
    end
   
   end
  
  # term é o contéudo da query. Count vai de 0 a 100 por chamada. Since_id é o limite min de tweet, sendo que 0 o default.
  def searchTerm(term,count,since_id)
    method="twittersearch"
    begin
      
    response = Twitter.search(term,{:count=>count, :since_id=>since_id})
    
     rescue Twitter::Error::BadRequest => error
      Database.insertErrorInTable(:badrequest,method)
      Database.insertInvocation(method,Time.now,2,0)
      puts "#{Time.now}: Bad Request!"
      userlist={}

    rescue Twitter::Error::Forbidden => error
      Database.insertErrorInTable(:forbidden,method)
      Database.insertInvocation(method,Time.now,3,0)
      puts "#{Time.now}: Forbidden!"
      userlist={}

    rescue Twitter::Error::NotAcceptable => error
      Database.insertErrorInTable(:notacceptable,method)
      Database.insertInvocation(method,Time.now,4,0)
      puts "#{Time.now}: Not Acceptable!"
      userlist={}

    rescue Twitter::Error::NotFound => error
      Database.insertErrorInTable(:notfound,method)
      Database.insertInvocation(method,Time.now,5,0)
      puts "#{Time.now}: Not Found!"
      userlist={}

    rescue Twitter::Error::Unauthorized=> error
      Database.insertErrorInTable(:unauthorized,method)
      Database.insertInvocation(method,Time.now,6,0)
      puts "#{Time.now}: Unauthorized!"
    

    rescue Twitter::Error::UnprocessableEntity=> error
      Database.insertErrorInTable(:unprocessableentity,method)
      Database.insertInvocation(method,Time.now,7,0)
      puts "#{Time.now}: Unprocessable Entity!"
      userlist={}

    rescue Twitter::Error::TooManyRequests => error
      Database.insertErrorInTable(:toomany,method)
      Database.insertInvocation(method,Time.now,8,0)
      puts "#{Time.now}: Rate Limit hit! Going to sleep for #{error.rate_limit.reset_in}"
      sleep error.rate_limit.reset_in
      retry

    rescue Twitter::Error::BadGateway => error
      Database.insertErrorInTable(:badgateway,method)
      Database.insertInvocation(method,Time.now,9,0)
      puts "#{Time.now}: BadGateway ERRa!!1"
      retry

    rescue Twitter::Error::ServiceUnavailable => error
      Database.insertErrorInTable(:serviceunav,method)
      Databse.insertInvocation(method,Time.now,10,0)
      puts "#{Time.now}: Service is down! Over Capacity Error!" 
      retry

      rescue Twitter::Error::InternalServerError => error
      Database.insertErrorInTable(:internalserv,method)
      Database.insertInvocation(method,Time.now,12,0)
      puts "#{Time.now}: InternalServerError: Something is technically wrong." 
      retry
      
      rescue Twitter::Error::ClientError => error
        Database.insertErrorInTable(:clienterror,method)
        puts "#{Time.now}: Weird bug isn't it?"
        userlist={}



    end

    
   end

  def getFollowers(userid,cursor)
    method="utilizadorporfol_getfols"
    begin
    
    userlist = Twitter.follower_ids(userid, {:cursor=>cursor})
    
     rescue Twitter::Error::BadRequest => error
      Database.insertErrorInTable(:badrequest,method)
      puts "#{Time.now}: Bad Request!"
      Database.insertInvocation(method,Time.now,2,0)
      userlist={}

    rescue Twitter::Error::Forbidden => error
      Database.insertErrorInTable(:forbidden,method)
      puts "#{Time.now}: Forbidden!"
      Database.insertInvocation(method,Time.now,3,0)
      userlist={}

    rescue Twitter::Error::NotAcceptable => error
      Database.insertErrorInTable(:notacceptable,method)
      Database.insertInvocation(method,Time.now,4,0)
      puts "#{Time.now}: Not Acceptable!"
     

    rescue Twitter::Error::NotFound => error
      Database.insertErrorInTable(:notfound,method)
      Database.insertInvocation(method,Time.now,5,0)
      puts "#{Time.now}: Not Found!"


    rescue Twitter::Error::Unauthorized=> error
      Database.insertErrorInTable(:unauthorized,method)
      Database.insertInvocation(method,Time.now,6,0)
      puts "#{Time.now}: Unauthorized!"
      
      

    rescue Twitter::Error::UnprocessableEntity=> error
      Database.insertErrorInTable(:unprocessableentity,method)
      Database.insertInvocation(method,Time.now,7,0)
      puts "#{Time.now}: Unprocessable Entity!"
      userlist={}
    #

    rescue Twitter::Error::TooManyRequests => error
      puts "#{Time.now}: Rate Limit hit! Going to sleep for #{error.rate_limit.reset_in}"
      Database.insertInvocation(method,Time.now,8,0)
      Database.insertErrorInTable(:toomany,method)
      sleep error.rate_limit.reset_in
      retry
    
      rescue Twitter::Error::BadGateway => error
        puts "#{Time.now}: BadGateway ERRa!!1"
        Database.insertInvocation(method,Time.now,9,0)
        Database.insertErrorInTable(:badgateway,method)
        sleep 5
        retry
  
      rescue Twitter::Error::ServiceUnavailable => error
        Database.insertErrorInTable(:serviceunav,method)
        Database.insertInvocation(method,Time.now,10,0)
        puts "#{Time.now}: Service is down! Over Capacity Error!" 
        retry

        rescue Twitter::Error::InternalServerError => error
        Database.insertErrorInTable(:internalserv,method)
        Database.insertInvocation(method,Time.now,11,0)
        puts "#{Time.now}: InternalServerError: Something is technically wrong." 
        retry

        rescue Twitter::Error::ClientError => error
          Database.insertInvocation(method,Time.now,12,0)
        Database.insertErrorInTable(:clienterror,method)
        puts "#{Time.now}: Weird bug isn't it?"
        retry

          else 
           Database.insertInvocation(method,Time.now,1,userlist.ids.length)
           return userlist
         
    
    end
 
  end

  def lookUpUser(id,method)
    
   begin
    userlist = Twitter.user(id)
    #client errors!
    rescue Twitter::Error::BadRequest => error
      Database.insertErrorInTable(:badrequest,method)
      puts "#{Time.now}: Bad Request!"
      Database.insertInvocation(method,Time.now,2,0)
      userlist={}

    rescue Twitter::Error::Forbidden => error
      Database.insertErrorInTable(:forbidden,method)
      puts "#{Time.now}: Forbidden!"
      Database.insertInvocation(method,Time.now,3,0)
      userlist={}

    rescue Twitter::Error::NotAcceptable => error
      Database.insertErrorInTable(:notacceptable,method)
      Database.insertInvocation(method,Time.now,4,0)
      puts "#{Time.now}: Not Acceptable!"
     

    rescue Twitter::Error::NotFound => error
      Database.insertErrorInTable(:notfound,method)
      Database.insertInvocation(method,Time.now,5,0)
      puts "#{Time.now}: Not Found!"


    rescue Twitter::Error::Unauthorized=> error
      Database.insertErrorInTable(:unauthorized,method)
      Database.insertInvocation(method,Time.now,6,0)
      puts "#{Time.now}: Unauthorized!"
      

    rescue Twitter::Error::UnprocessableEntity=> error
      Database.insertErrorInTable(:unprocessableentity,method)
      Database.insertInvocation(method,Time.now,7,0)
      puts "#{Time.now}: Unprocessable Entity!"
      userlist={}
    #

    rescue Twitter::Error::TooManyRequests => error
      puts "#{Time.now}: Rate Limit hit! Going to sleep for #{error.rate_limit.reset_in}"
      Database.insertInvocation(method,Time.now,8,0)
      Database.insertErrorInTable(:toomany,method)
      sleep error.rate_limit.reset_in
      retry
    
      rescue Twitter::Error::BadGateway => error
        puts "#{Time.now}: BadGateway ERRa!!1"
        Database.insertInvocation(method,Time.now,9,0)
        Database.insertErrorInTable(:badgateway,method)
        sleep 5
        retry
  
      rescue Twitter::Error::ServiceUnavailable => error
        Database.insertErrorInTable(:serviceunav,method)
        Database.insertInvocation(method,Time.now,10,0)
        puts "#{Time.now}: Service is down! Over Capacity Error!" 
        retry

        rescue Twitter::Error::InternalServerError => error
        Database.insertErrorInTable(:internalserv,method)
        Database.insertInvocation(method,Time.now,11,0)
        puts "#{Time.now}: InternalServerError: Something is technically wrong." 
        retry

        rescue Twitter::Error::ClientError => error
          Database.insertInvocation(method,Time.now,12,0)
        Database.insertErrorInTable(:clienterror,method)
        puts "#{Time.now}: Weird bug isn't it?"
        retry

    end
  end

  def lookUpUsers(ids,name)
   method = name + '_lookup'

   begin
    userlist = Twitter.users(ids)
    
    rescue Twitter::Error::BadRequest => error
      Database.insertErrorInTable(:badrequest,method)
      puts "#{Time.now}: Bad Request!"
      Database.insertInvocation(method,Time.now,2,0)
      userlist={}
      return

    rescue Twitter::Error::Forbidden => error
      Database.insertErrorInTable(:forbidden,method)
      puts "#{Time.now}: Forbidden!"
      Database.insertInvocation(method,Time.now,3,0)
      userlist={}
      return

    rescue Twitter::Error::NotAcceptable => error
      Database.insertErrorInTable(:notacceptable,method)
      Database.insertInvocation(method,Time.now,4,0)
      puts "#{Time.now}: Not Acceptable!"
      return
     

    rescue Twitter::Error::NotFound => error
      Database.insertErrorInTable(:notfound,method)
      Database.insertInvocation(method,Time.now,5,0)
      puts "#{Time.now}: Not Found!"
      return


    rescue Twitter::Error::Unauthorized=> error
      Database.insertErrorInTable(:unauthorized,method)
      Database.insertInvocation(method,Time.now,6,0)
      puts "#{Time.now}: Unauthorized!"
      return
      

    rescue Twitter::Error::UnprocessableEntity=> error
      Database.insertErrorInTable(:unprocessableentity,method)
      Database.insertInvocation(method,Time.now,7,0)
      puts "#{Time.now}: Unprocessable Entity!"
      return userlist={}
    #

    rescue Twitter::Error::TooManyRequests => error
      puts "#{Time.now}: Rate Limit hit! Going to sleep for #{error.rate_limit.reset_in}"
      Database.insertInvocation(method,Time.now,8,0)
      Database.insertErrorInTable(:toomany,method)
      sleep error.rate_limit.reset_in
      retry
    
      rescue Twitter::Error::BadGateway => error
        puts "#{Time.now}: BadGateway ERRa!!1"
        Database.insertInvocation(method,Time.now,9,0)
        Database.insertErrorInTable(:badgateway,method)
        sleep 5
        retry
  
      rescue Twitter::Error::ServiceUnavailable => error
        Database.insertErrorInTable(:serviceunav,method)
        Database.insertInvocation(method,Time.now,10,0)
        puts "#{Time.now}: Service is down! Over Capacity Error!" 
        retry

        rescue Twitter::Error::InternalServerError => error
        Database.insertErrorInTable(:internalserv,method)
        Database.insertInvocation(method,Time.now,11,0)
        puts "#{Time.now}: InternalServerError: Something is technically wrong." 
        retry

        rescue Twitter::Error::ClientError => error
        Database.insertInvocation(method,Time.now,12,0)
        Database.insertErrorInTable(:clienterror,method)
        puts "#{Time.now}: Weird bug isn't it?"
        retry

        else 
          Database.insertInvocation(method,Time.now,1,userlist.length)
          return userlist
    
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

      response = self.getFollowers(userid,-1)
      # if response is error, returns empty list
      if response == nil
        return {}
      end

      
      if count == 0  
        return response.ids
      else
        
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

      response = self.getFriends(userid,-1)
      # if response is error, returns empty list
      if response == nil
        return {}
      end

      if count == 0  
        return response.ids
      
      else
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
  def getUsersInfo(users,method)
    userslist = Array.new

    chunkusers = users.each_slice(100).to_a
    chunkusers.each{ |item|
      puts "#{Time.now}: Getting info from 100 users!"
      response = self.lookUpUsers(item,method)
      
      if response != {}
      userslist.concat(response)
      end
      }

    userslist
    
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
  def lookUpNewUsers(userids, savedids,method)
 
    listusers = Array.new

    userids.each{ |item|
      listusers.push(item) unless self.verifyUserId(item, savedids)
    }

    self.lookUpUsers(listusers,method)
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