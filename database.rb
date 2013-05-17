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
    allusers = dataset.order(:entry_date).all    

    allusers.each { |item|
      idusers.push(item[:id].to_i) }

    idusers
  end

  def self.insertUsers(users,table)
    users.each {|item|
      self.insertUserInTable(item,table)}
  end

  def self.insertFollowerRelation(userid, followerid)
    Database.connect

    dataset=@db[:followers]
    begin
    dataset.insert(:id=> userid,
                   :followerid=> followerid)
    rescue Mysql2::Error::Duplicate => error
      puts "Erro!Chave duplicada!"

    end
  end

  def self.insertFriendRelation(userid, friendid)
    Database.connect

    dataset=@db[:friends]
    begin
    dataset.insert(:id=> userid,
                   :friendid=> friendid)
    rescue Mysql2::Error::Duplicate => error
      puts "Erro!Chave duplicada!"

    end
  end

  def self.InsertFollowerRelations(userid, followersid)
    followersid.each{ |item| 
      self.insertFollowerRelation(userid, item)
      puts "Inseri relacao de seguidor!" 
    }
  end

  def self.InsertFriendRelations(userid, friendsid)
    friendsid.each{ |item| 
      self.insertFriendRelation(userid, item)
      puts "Inseri relacao de amigo!" 
    }
  end

  def self.InsertRelations(userid,list, table)
    if table==:utilizadorporfol
      self.InsertFollowerRelations(userid,list)
    elsif table==:utilizadorporfriend
      self.InsertFriendRelations(userid, list)
    end

  end
    
  

  def self.getUncrawledUsers(table)
  	puts table	
    if table==:utilizadorporfol
      puts table
      count = :followers_count
    elsif table==:utilizadorporfriend
      puts table
      count = :friends_count
    end  
  	
    Database.connect	 
    
    puts @db

    idusers = Hash.new
    dataset = @db[table]
    uncrawledusers = dataset.order(:entry_date).filter(:crawled => 0)

    uncrawledusers.each { |item|
     idusers.store(item[:id].to_i,item[count]) }

    return idusers
   end

  # users is a array that contains 2 kind of users: the users[0]
  # is a list of new users (users that are not in the DB). users[1]
  # are old users, so only the follower relationship is inserted.
 
  def self.insertNewUsers(userid, users, table)
    
    self.InsertRelations(userid,users[1],table)

    users[0].each { |item|
      puts "user:" + item.screen_name
      self.insertUserInTable(item,table)
      puts "Inseri item!"
      
      if table==:utilizadorporfol
        self.insertFollowerRelation(userid,item.id)
        puts "Inseri relacao de seguidor!"
      elsif table==:utilizadorporfriend
        self.insertFriendRelation(userid,item.id)
      end        
      }

  	end

  def self.setUserCrawled(iduser,table)
  	Database.connect
  	dataset = @db[table]
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

    begin

    dataset.insert(:name=> user.name, 
                   :id=> user.attrs[:id_str], 
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
                   :entry_date=>Time.now.utc,
                   :protected=>user.protected,
                   :geo=>user.geo_enabled,
                   :verified=>user.verified,
                   :listed_count=>user.listed_count,
                   :timezone=>user.time_zone)
    
    rescue Mysql2::Error::Duplicate => error
      puts "Erro!Chave duplicada!"

    end

    puts "#{Time.now}: Inserido utilizador #{user.screen_name} na BD"
  end

  def self.insertTweetInTable(tweet,table)
    Database.connect

    dataset=@db[table]
    #control coordinates
    if tweet.attrs[:coordinates]!=nil
      coordx=tweet.attrs[:coordinates][:coordinates][0]
      coordy=tweet.attrs[:coordinates][:coordinates][1]
      else 
        coordx=nil
        coordy=nil
    end

    begin

    dataset.insert(:id=> tweet.attrs[:id_str],
                   :status => tweet.text,
                   :entry_date => Time.now.utc,
                   :user_id => tweet.attrs[:id_str],
                   :source => tweet.source,
                   :created_at => tweet.created_at.utc,
                   :in_reply_to_status =>  tweet.attrs[:in_reply_to_status_id_str],
                   :in_reply_to_user => tweet.attrs[:in_reply_to_user_id_str],
                   :lang => tweet[:attrs][:lang],
                   :retweet_count=>tweet.retweet_count,
                   :favorite_count=>tweet.attrs[:favorite_count],
                   :coordx=>coordx,
                   :coordy=>coordy)
    
    rescue Mysql2::Error::Duplicate => error
      puts "Erro!Chave duplicada!"

    end

    
    puts "#{Time.now}: Inserido tweet #{tweet.id} na BD"


  end

  def self.insertTweetsInTable(tweets,table)
    
    tweets.each { |item| 
      self.insertTweetInTable(item,table)    
    
    }
  end

  def self.insertErrorInTable(error,method)
    Database.connect

    dataset=@db[:erros]
    
    
    dataset.where(:metodo=>method).update(error=>error + 1)
    

  end

  def self.insertInvocation(method,date,response,hitrate)
    Database.connect
    dataset=@db[:inv]

    dataset.insert(:method=>method,
                   :entry=>date.utc,
                   :response=>response,
                   :hitrate=>hitrate)
    
  end

end