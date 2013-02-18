require 'active_support/time'
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