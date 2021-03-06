require 'active_support/time'
require './twitterapi.rb'
require './database.rb'

class CrawlingFriends

  def initialize

    @twitter = TwitterAPI.new
    @tableusers = :utilizadorporfriend
    @tablefriends = :friends
    @method = "utilizadorporfriend"
    @timelimit = Time.now + 2.days
   # @idlist = Database.getUserIdsFromDb(@table).inject({}){|h,v| h[v]= nil; h}

  end

  def getTable
    return @tableusers
  end

  def buildSeed(names)   
    seed = @twitter.lookUpUsers(names,@method)
    Database.insertUsers(seed,@tableusers)
  end

  def checkLastStatusDate(user)
    # Using one month to determine wether the user is active or not
    if user.status == nil 
      return false
    end  
    user.status.created_at > 1.month.ago 
  end

  def checkIfTimeZonePT(user)

    user.time_zone == 'Lisbon'
  end

  def checkLocationPT(user)
    #Verify location: Needs to be more complex
    user.location == 'Portugal'
  end

  def filterValidUsers(users)
    list = Array.new
    users.each { |item|
        if checkIfTimeZonePT(item) && checkLastStatusDate(item)
          list.push(item)
        end }
    list
  end

  #returns true if id in array
  def verifyUserId(id, alluserids)
     alluserids.has_key?(id) 
  end

  #from an array of ids, only does the lookup for the ones that
  #don't belong in DB. Returns array of users
  def lookUpNewUsers(userids, savedids)
    
    listusers = Array.new

    userids.each{ |item| 
      if !self.verifyUserId(item, savedids)
          listusers.push(item)
      end }

    @twitter.lookUpUsers(listusers,@method)
   end

   def filterNewUsers(userids, savedids)
    listusers = Array.new

    userids.each{ |item| 
      if !self.verifyUserId(item, savedids)
          listusers.push(item)
      end }

    listusers

   end

    def filterRepeatedUsers(userids, savedids)
    listusers = Array.new

    userids.each{ |item| 
      if self.verifyUserId(item, savedids)
          listusers.push(item)
      end }
  
    listusers

   end
      

  def crawlUser(iduser, friendscount)
    puts 'CrawlUser'
    puts iduser
    puts friendscount

    #transforms the database response into hash
    savedids = Database.getUserIdsFromDb(@tableusers).inject({}){|h,v| h[v]= nil; h}
    
    listusersids = @twitter.getAllFriends(iduser, friendscount)
    
    if listusersids == {}
      return {}
    end

    # to filter the users that are new to the DB
    #newusers = self.filterNewUsers(listusersids, savedids)
  
    #filter the already in DB users
    oldusers = self.filterRepeatedUsers(listusersids, savedids)
    
    # to get all the info from the users.listuserids-oldusers give
    # only the new users
    listusers = @twitter.getUsersInfo(listusersids-oldusers,@method)
   
    #analyse the user's info, to filter the valid users. This will not be used at the moment!
    # filteredusers = self.filterValidUsers(listusers)

    
    Database.setUserCrawled(iduser,@tableusers)

    return listusers, oldusers

  end

  def crawlAndSave(iduser, friendscount)
    puts 'CrawlAndSave'
    puts iduser
    puts friendscount

    crawlresponse = self.crawlUser(iduser, friendscount)
    
    if crawlresponse == {}
      return
    end
    
    Database.insertNewUsers(iduser, crawlresponse,@tableusers)

    if Time.now > @timelimit
        puts puts "#{Time.now}: Time limit hit! Byebye!"
        abort
    end
  end

  def crawlAllUsers(uncrawled)
      
      uncrawled.each { |key, value| 
      self.crawlAndSave(key, value)
     }

      uncrawled = Database.getUncrawledUsers(@tableusers)

    #Termina execução caso já não existam mais utilizadores para explorar, ou o tempo limite seja ultrapassado
    if uncrawled.length == 0 
      puts "#{Time.now}: no more users to crawl! The end!"
      return  
    end

    crawlAllUsers(uncrawled)
    
  end
  
end

#invocação da execução
crawl = CrawlingFriends.new
table = crawl.getTable()
uncrawled = Database.getUncrawledUsers(table)
#Construir seed se necessário
if uncrawled.length == 0
  puts 'Jogo!'
  crawl.buildSeed(['corpodormente','pedrotochas','havidaemmarkl','fernandoalvim','davidfonseca','brunoaleixo','pauloquerido'])
  uncrawled = Database.getUncrawledUsers(table)
end

crawl.crawlAllUsers(uncrawled)
