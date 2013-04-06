require 'active_support/time'
require './twitterapi.rb'
require './database.rb'

class SearchTweet

	 def initialize

    @twitter = TwitterAPI.new
    @table = :tweetsporsearch

  end	

  def getSearchTweets(term)
  	max_id=0
    statuses = Array.new


    5.times do 
      tweets = @twitter.searchTerm(term,100,max_id)
      puts "going to wait for more tweets mateys!"
      puts "since_id will be: #{tweets.max_id}"
      max_id=tweets.max_id
      statuses.concat(tweets.statuses)
      sleep 240
    end
  return statuses
  end
	
end