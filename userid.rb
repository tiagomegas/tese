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

	def generateRandomNumbers
		list = Array.new
		
		begin			
			n = generateRandom
			if !list.include? n 
				puts n
				list.push(n)
				end
		end until list.length == 100			
		
		return list

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
		numbers = self.generateRandomNumbers
		return @twitter.lookUpUsers(self.generateRandomNumbers)
		
	end

	

	def lookById
		count=0
		while count!=10000
			if a = self.lookRandomUser
				Database.insertUserInTable(a,:utilizadorporid) 
				count+=1
			end
		end
		
	end

	def lookByIds
		count=0
		while count<10000
			a = self.lookRandomUsers
			Database.insertUsers(a,:utilizadorporid) 
 			count+=a.length
		end
		
	end

end

# Invocação da execução
u = UserID.new
u.lookByIds
