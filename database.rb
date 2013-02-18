require 'sequel'
require 'active_support/time'

class Database

	# def self.connection
	# 	if @db != nil
	# 		@db = Database.connect('Tese','localhost')
	# 	end
	# 	@db
	# end

	def self.connect

		if @db == nil
			@db = Sequel.connect(:database => 'Tese',
													 :adapter=>'mysql2', 
													 :host=> 'localhost', 
													 :user=>'root', 
													 :password=>'2001odisseianoespaco')
		end
			
	end

	def self.getUserIdsFromDb
		
		Database.connect
    
    idusers = Array.new
    dataset = @db[:utilizador]
    allusers = dataset.all    

    allusers.each { |item|
      idusers.push(item[:id]) }

    idusers
  end

  def self.insertUser(user)
    
    Database.connect

    dataset=@db[:utilizador]
    
    dataset.insert(:name=> user.name, 
                   :id=> user.id, 
                   :screen_name=>user.screen_name,
                   :location=> user.location, 
                   :url=>user.url, 
                   :followers_count=>user.followers_count,
                   :friends_count=>user.friends_count,
                   :lang=>user.lang,
                   :crawled=>false)
  end

  def self.insertUsers(users)
    users.each {|item|
      self.insertUser(item)}
  end

  def self.insertFollower(userid, followerid)
    Database.connect

    dataset=@db[:seguidores]

    dataset.insert(:id=> userid,
                   :followerid=> followerid)
  end

  def self.InsertFollowers(userid, followersid)
    followersid.each{ |item| 
      self.insertFollower(userid, item)
      puts "Inseri relacao de seguidor!" 
    }
  end

  def self.getUncrawledUsers
  		
  	Database.connect	 
    
    puts @db

    idusers = Hash.new
    dataset = @db[:utilizador]
    uncrawledusers = dataset.filter(:crawled => 0)  

    uncrawledusers.each { |item|
     idusers.store(item[:id],item[:followers_count]) }

    return idusers
   end

  # users is a array that contains 2 kind of users: the users[0]
  # is a list of new users (users that are not in the DB). users[1]
  # are old users, so only the follower relationship is inserted.
 
  def self.insertNewUsers(userid, users)
    
    self.InsertFollowers(userid,users[1])

    users[0].each { |item|
      puts "user:" + item.screen_name
      self.insertUser(item)
      puts "Inseri item!"
      self.insertFollower(userid,item.id)
      puts "Inseri relacao de seguidor!"
      }

  	end
  def self.setUserCrawled(iduser)
  	Database.connect
  	dataset = @db[:utilizador]
  	dataset.where(:id => iduser).update(:crawled=>true)
  	
  end

  # Isto vai meio à trolha. Este metodo é para inserir na mesma DB mas na tabela do user ID. No futuro, seria mais fancy modular todo o 
  # código para as mesmas situações em tabelas diferentes!

   def self.insertUserInTable(user,table)
    
    Database.connect

    dataset=@db[table]
    
    dataset.insert(:name=> user.name, 
                   :id=> user.id, 
                   :screen_name=>user.screen_name,
                   :description=>user.description,
                   :location=> user.location, 
                   :url=>user.url, 
                   :followers_count=>user.followers_count,
                   :friends_count=>user.friends_count,
                   :lang=>user.lang,
                   :statuses_count=>user.statuses_count,
                   :user_date=>user.created_at.utc,
                   :lastweet_date=>user.status.created_at,
                   :entry_date=>Time.now.utc)
    
    puts "#{Time.now}: Inserido utilizador #{user.screen_name} na BD"
  end

end