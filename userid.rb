require 'active_support/time'
require './twitterapi.rb'
require './database.rb'

class UserID
	
	
	
	def initialize

    @twitter = TwitterAPI.new

    @maxnumber = 1193816142
    #account created at Mon Feb 18 16:26:31 +0000 2013
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
		count=0
		while count!=10000
			if a = self.lookRandomUser
				Database.insertUserInTable(a,:utilizadorporid) 
				count+=1
			end
		end
		
	end

end

# Invocação da execução
u = UserID.new
u.lookRandomUsers