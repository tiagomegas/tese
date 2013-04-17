require 'active_support/time'
require './twitterapi.rb'
require './database.rb'

class SearchTweet

   def initialize

    @twitter = TwitterAPI.new
    @table = :twittersearch

  end 

  def getSearchTweets(term)
    # It receives an array of terms, to be later searched by the Search API.
    max_id=0
    size=0
    statuses = Array.new
    list = term.join(" OR ")
    
      100.times do 
      tweets = @twitter.searchTerm(list,100,max_id)
      puts "going to wait for more tweets mateys!"
      puts "since_id will be: #{tweets.max_id}"
      Database.insertTweetsInTable(tweets.statuses, @table)
      temp=tweets.statuses.length
      max_id=tweets.max_id
      #statuses.concat(tweets.statuses)
     sleep 240
    end
  end
  
end

#Invocação do método
t=SearchTweet.new
terms = ['relvas','governo','cavaco','socrates','ps','psd']
t.getSearchTweets(terms)

