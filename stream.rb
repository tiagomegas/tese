require 'tweetstream'
require './database.rb'

class TwitterStream

	def configure
    	TweetStream.configure do |config|
    	  config.consumer_key 		= "5HwJKF261Qal0p1ZAmMLZg"
    	  config.consumer_secret	= "mPlbSLkoADM6GqfxWr6O56CQQ3TWYKHp14It8ATzIQ"
    	  config.oauth_token 		= "8837772-Q3U75L99eMHMXXlq8nnp7NnQt7dxNJPbjzAUPvRxTq"
	     config.oauth_token_secret = "g6qCacAdPFnFbufr7kEykW86KJo8LMejZbpqMNM"
		  config.auth_method        = :oauth
      
     	  puts 'Credentials activated'
    	end
	end


	def initialize
		@table = :twitterstream
		self.configure
	end

	def getSample
		# This will pull a sample of all tweets based on
		# your Twitter account's Streaming API role.
		TweetStream::Client.new.sample do |status|
		  # The status object is a special Hash with
		  # method access to its keys.
		puts "Begin the STREAM!"
		puts "#{status.user.screen_name}"
		puts "#{status.text}"
		#Database.insertTweetInTable(status,@table)
		 	
		end
	end

	def getFilteredData(filter)
		#Filters the data of the stream, according to the terms. the arg filter is an array of terms.
		TweetStream::Client.new.track(filter) do |status|
	  	puts "Begin the STREAM!"
	   puts "."
	   Database.insertTweetInTable(status,@table)
		end

	end

end

t=TwitterStream.new
terms = ['relvas','governo','cavaco','socrates','ps','psd']
t.getFilteredData(terms)
#t.getSample

