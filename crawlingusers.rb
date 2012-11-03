require 'twitter'
require 'sequel'

class TwitterInspector


  
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

 def getAllFollowers(seedname)
      
      user=self.lookUpUser(seedname)
      puts user.screen_name
      count = user.followers_count/5000
      
      if count == 0    
        return self.getFollowers(seedname,-1).ids
      else
        response = self.getFollowers(seedname,-1)
        followers=response.ids
        puts count
        count.times do
          puts "."
          response=self.getFollowers(seedname,response.next_cursor)
          followers.concat(response.ids)
          puts followers.length  
        end
      end
      followers
  end
  

  def lookUpUser(id)
    user = Twitter.user(id)
  end

end