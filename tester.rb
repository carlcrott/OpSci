require 'nokogiri'
require 'mechanize'
require 'net/http'
require 'json'
require 'net/http'


page = Mechanize.new.get('http://booksandjournals.brillonline.com/content/journals/f?perPage=100')

pages_count_by_100 = page.search('.paginator').search('a')

p pages_count_by_100.count

iters = []
for iter in pages_count_by_100

  iters << iter.text()

end

p iters



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

