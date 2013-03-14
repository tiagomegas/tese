require 'active_support/time'
require './twitterapi.rb'
require './database.rb'

class SearchTweet

	 def initialize

    @twitter = TwitterAPI.new
    @table = :tweetsporsearch

  end
	
end