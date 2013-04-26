require 'active_support/time'
require './twitterapi.rb'
require './database.rb'

class UserID

	def initialize

    @twitter = TwitterAPI.new
    @table = :utilizadorporid
    @maxnumber = 1380121788
    #account created at 2013-04-25 19:38:44 +0100
    @generatedids = Database.getUserIdsFromDb(@table)
    @timelimit = Time.now + 2.days
    @method = "utilizadorporid"

    
    
  	end

	def generateRandom
		return 1 + rand(@maxnumber)
	end

	def generateRandomNumbers()
		#method to generate random numbers. It generates a random number, then he checks if it belongs to the list of all ids
		#if it doesn't, he adds to the list of all ids, if it does, he generates another random number. repeat until the list
		#of ids to search by gets 100 ids.
		list = Array.new
		
		begin			
			n = generateRandom
			if !@generatedids.include? n 
				@generatedids.push(n)
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
		puts "#{Time.now}:Generated random numbers. Going to look up users!"
		return @twitter.lookUpUser(number,@method)
		
	end

	def lookRandomUsers
		numbers = self.generateRandomNumbers
		puts "#{Time.now}: Getting user info!"
		return @twitter.lookUpUsers(self.generateRandomNumbers,@method)
		
	end

	

	def lookById
		count=0
		while count!=10000
			if a = self.lookRandomUser
				Database.insertUserInTable(a,@table) 
				count+=1
			end
		end
		
	end

	def lookByIds
		count=0
		while Time.now < @timelimit
			a = self.lookRandomUsers
			Database.insertUsers(a,@table) 
 			count+=a.length
		end
		
	end

end

# Invocação da execução
u = UserID.new
u.lookByIds

