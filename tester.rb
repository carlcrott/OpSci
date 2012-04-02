require 'nokogiri'
require 'mechanize'
require 'net/http'

a = [
"/action/showFeed?ui=45mu4&mi=3fndc3&ai=6690&jc=anchem&type=etoc&feed=rss", 
"/action/showFeed?ui=45mu4&mi=3fndc3&ai=sz&jc=anthro&type=etoc&feed=rss", 
"/action/showFeed?ui=45mu4&mi=3fndc3&ai=s3&jc=astro&type=etoc&feed=rss", 
"/action/showFeed?ui=45mu4&mi=3fndc3&ai=se&jc=biochem&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=sb&jc=bioeng&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=s7&jc=biophys&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=sg&jc=cellbio&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=68uv&jc=chembioeng&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=18f&jc=clinpsy&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=68t8&jc=conmatphys&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=s0&jc=earth&type=etoc&feed=rss%20", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=sh&jc=ecolsys&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=67b7&jc=economics&type=etoc&feed=rss%20", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=si&jc=ento&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=su&jc=energy&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=67c8&jc=financial&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=sv&jc=fluid&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=68da&jc=food&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=sj&jc=genet&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=sk&jc=genom&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=sl&jc=immunol&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=1k4&jc=lawsocsci&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=6726&jc=marine&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=sw&jc=matsci&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=sm&jc=med&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=sn&jc=micro&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=s2&jc=neuro&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=sx&jc=nucl&type=etoc&feed=rss%20", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=rz&jc=nutr&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=1xd&jc=pathmechdis&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=so&jc=pharmtox&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=sy&jc=physchem&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=sp&jc=physiol&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=sq&jc=phyto&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=sr&jc=arplant&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=rx&jc=polisci&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=s1&jc=psych&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=ss&jc=publhealth&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=67c9&jc=resource&type=etoc&feed=rss", "/action/showFeed?ui=45mu4&mi=3fndc3&ai=t0&jc=soc&type=etoc&feed=rss%20"]

for i in a
  p i.split('&')[3] 
#  if i.include? 'arcompsci'
#    puts 'yar'
#  end 
end

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

