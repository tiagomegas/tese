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

	def self.getUserIdsFromDb(table)
		
		Database.connect
    
    idusers = Array.new
    dataset = @db[table]
    allusers = dataset.all    

    allusers.each { |item|
      idusers.push(item[:id]) }

    idusers
  end

  def self.insertUsers(users,table)
    users.each {|item|
      self.insertUserInTable(item,table)}
  end

  def self.insertFollowerRelation(userid, followerid)
    Database.connect

    dataset=@db[:followers]

    dataset.insert(:id=> userid,
                   :followerid=> followerid)
  end

  def self.insertFriend(userid, friendid)
    Database.connect

    dataset=@db[:friends]

    dataset.insert(:id=> userid,
                   :friendid=> followerid)
  end

  def self.InsertFollowerRelations(userid, followersid)
    followersid.each{ |item| 
      self.insertFollowerRelation(userid, item)
      puts "Inseri relacao de seguidor!" 
    }
  end

  def self.getUncrawledUsers
  		
  	Database.connect	 
    
    puts @db

    idusers = Hash.new
    dataset = @db[:utilizadorporfriendfol]
    uncrawledusers = dataset.filter(:crawled => 0)  

    uncrawledusers.each { |item|
     idusers.store(item[:id],item[:followers_count]) }

    return idusers
   end

  # users is a array that contains 2 kind of users: the users[0]
  # is a list of new users (users that are not in the DB). users[1]
  # are old users, so only the follower relationship is inserted.
 
  def self.insertNewUsers(userid, users)
    
    self.InsertFollowerRelations(userid,users[1])

    users[0].each { |item|
      puts "user:" + item.screen_name
      self.insertUserInTable(item,:utilizadorporfriendfol)
      puts "Inseri item!"
      self.insertFollowerRelation(userid,item.id)
      puts "Inseri relacao de seguidor!"
      }

  	end

  def self.setUserCrawled(iduser)
  	Database.connect
  	dataset = @db[:utilizadorporfriendfol]
  	dataset.where(:id => iduser).update(:crawled=>1)
  	
  end

  # Isto vai meio à trolha. Este metodo é para inserir na mesma DB mas na tabela do user ID. No futuro, seria mais fancy modular todo o 
  # código para as mesmas situações em tabelas diferentes!

   def self.insertUserInTable(user,table)
    
    Database.connect

    dataset=@db[table]

    # Controlo do status para evitar erro ao criar registo
    
    if !user.status
      tweetdate=nil
    else 
      tweetdate=user.status.created_at.utc
    end

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
                   :lastweet_date=>tweetdate,
                   :entry_date=>Time.now.utc)
    
    puts "#{Time.now}: Inserido utilizador #{user.screen_name} na BD"
  end

  def self.insertTweetInTable(tweet,table)
    Database.connect

    dataset=@db[table]
    
    dataset.insert(:status=> tweet.text 
                   )
    
    puts "#{Time.now}: Inserido tweet #{tweet.id} na BD"


  end

end