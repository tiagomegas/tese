require 'twitter'
require 'sequel'
require './crawlingusers.rb'

class UserID
	#account created at 19 Nov 22:49:23 2012
	$maxnumber = 958792842

	def init
		t = TwitterInspector.new
		t.init
		return t		
	end

	def generateRandom
		return 1 + rand($maxnumber)
	end

	def lookRandomUsers
		
		
	end

end