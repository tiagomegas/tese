require 'twitter'
require 'sequel'
require './twitterapi.rb'
require './database.rb'

class UserID
	
	
	
	def initialize

    @twitter = TwitterAPI.new

    @maxnumber = 958792842
    #account created at 19 Nov 22:49:23 2012
  	end

	def generateRandom
		return 1 + rand(@maxnumber)
	end

	def maxnumber
		return @maxnumber
		
	end

	def lookRandomUser
		number = self.generateRandom
		puts number
		return @twitter.lookUpUser(number)
		
	end

	def lookRandomUsers
		while true
			if self.lookRandomUser 
				puts "OuKAY!" 

			end
		end
		
	end

end