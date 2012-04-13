require 'nokogiri'
require 'mechanize'
require 'net/http'
require 'json'
require 'net/http'


rss_feeds = Mechanize.new.get('http://www.press.jhu.edu/journals/toc_feeds_rss.html').search('#textwell/.feeds_list').search('a')

feed_hash = Hash.new
for feed in rss_feeds
  feed_hash[feed.text()] = feed.attributes["href"].text()
end


p feed_hash.length


#p links.search('//a[contains(@text,"ingentaConnect")]').count


#for link in links
#  p link.text()
#end


#link = page.search('//a[text()="Access Full"]')
#link = page.search('//a[contains(text(), "Access Full")]')
#          .search('//a[text() = "wobidah"]')
#          .search('//td[text()="${nbsp}"]
#          .search('//*[contains(@id, "_divSpecialities")]')


# find the highest number in a string
#text of each a tag



#pages = %w( www.rubycentral.com
#            www.awl.com
#            www.pragmaticprogrammer.com
#           )

#threads = []

#for page in pages
#  threads << Thread.new(page) { |myPage|

#    h = Net::HTTP.new(myPage, 80)
#    puts "Fetching: #{myPage}"
#    resp, data = h.get('/')
#    puts "Got #{myPage}:  #{resp.message}"
#  }
#end

#p threads

#threads.each { |aThread|  aThread.join }



#load './jab.rb'
#bar
#fu = Jab.new
#fu.foo


##tests = [ 
##  id.search("[text()*='2012']").count ,
##  id.search("[text()*='2011']").count ,
##  id.search("[text()*='2010']").count ,
##  id.search("[text()*='2009']").count ,
##]

#@tests = []
#(2010..2012).map {|x| x="[text()*='#{x}']"; @tests << page.search(x).count}
#p @tests

#    file = Mechanize.new.get(entry['rss'])
#    @noko = Nokogiri::XML(file.content)
#    p @noko.class # => Nokogiri::XML::Document

##[1,2,3,4].map &:to_s is just short for [1,2,3,4].map { |x| x.to_s }
##p tests.any?(&:instance_of? == Nokogiri::XML::NodeSet ) 

##if x == true &&
#p   page.search("[text()*='2012']").instance_of? Nokogiri::XML::NodeSet


#file = Mechanize.new.get(entry['rss'])
#@noko = Nokogiri::XML(file.content)
#p @noko.class # => Nokogiri::XML::Document

