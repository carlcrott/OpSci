require 'nokogiri'
require 'mechanize'
require 'net/http'

def some_method(value='default', arr=[])
  puts value
  puts arr.length
end
 
some_method('something')
some_method()

#page = Mechanize.new.get('http://pubs.acs.org/loi/acbcct')
#id = page.search('#issueList')

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

