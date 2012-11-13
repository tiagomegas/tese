require 'sequel'
require 'mysql2'

class Database

	def init

	db = Sequel.connect(:database=>'Tese',:adapter=>'mysql2', :host=>'localhost', :user=>'root', :password=>'2001odisseianoespaco')
	#create the user table

		db.create_table :utilizador do 
			primary_key :id
			String :screen_name
			String :name
			String :location
			String :url
			Integer :followers_count
			Integer :friends_count
			String :lang
			Boolean :crawled

		end
	end

end