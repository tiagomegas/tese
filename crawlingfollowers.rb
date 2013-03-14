require 'active_support/time'
require './twitterapi.rb'
require './database.rb'

class CrawlingUsers

  def initialize

    @twitter = TwitterAPI.new
    @table = :utilizadorporfriendfol

  end

  def buildSeed(names)   
    seed = @twitter.lookUpUsers(names)
    Database.insertUsers(seed,@table)
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
     
    alluserids.include? id
  end

  #from an array of ids, only does the lookup for the ones that
  #don't belong in DB. Returns array of users
  def lookUpNewUsers(userids, savedids)
    
    listusers = Array.new

    userids.each{ |item| 
      if !self.verifyUserId(item, savedids)
          listusers.push(item)
      end }

    @twitter.lookUpUsers(listusers)
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
      

  def crawlUser(iduser, followerscount)
    puts 'CrawlUser'
    puts iduser
    puts followerscount

    savedids = Database.getUserIdsFromDb(@table)
    
    listusersids = @twitter.getAllFollowers(iduser, followerscount)

    # to filter the users that are new to the DB
    #newusers = self.filterNewUsers(listusersids, savedids)
  
    #filter the already in DB users
    oldusers = self.filterRepeatedUsers(listusersids, savedids)
    
    # to get all the info from the users.listuserids-oldusers give
    # only the new users
    listusers = @twitter.getFollowersInfo(listusersids-oldusers)
   
     #analyse the user's info, to filter the valid users. This will not be used at the moment!
    # filteredusers = self.filterValidUsers(listusers)

    
    Database.setUserCrawled(iduser)

    return listusers, oldusers

  end

  def crawlAndSave(iduser, followerscount)
    puts 'CrawlAndSave'
    puts iduser
    puts followerscount

    crawlresponse = self.crawlUser(iduser, followerscount)
    
    Database.insertNewUsers(iduser, crawlresponse)
  end

  def crawlAllUsers(uncrawled)
      
      uncrawled.each { |key, value| 
      self.crawlAndSave(key, value)
      }

      uncrawled = Database.getUncrawledUsers

    #Termina execução caso já não existam mais utilizadores para explorar
    if uncrawled.length == 0
      puts "no more users to crawl! The end!"
      return  
    end

    crawlAllUsers(uncrawled)
    
  end
    


end

#invocação da execução
crawl = CrawlingUsers.new
uncrawled = Database.getUncrawledUsers
#Construir seed se necessário
if uncrawled.length == 0
  puts 'Jogo!'
  crawl.buildSeed('megas')
  uncrawled = Database.getUncrawledUsers
end

crawl.crawlAllUsers(uncrawled)
