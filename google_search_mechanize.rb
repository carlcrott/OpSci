require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'spreadsheet'
require 'json'

#https://docs.google.com/View?id=djqqxwp_8dzv4cpcb&pli=1
#http://diyhpl.us/~bryan/irc/publishers.txt


class String
  def valid_json?
    begin
      JSON.parse(self)
      return true
    rescue Exception => e
      return false
    end
  end
end

def google_search(query)
  agent = Mechanize.new

  agent.get('http://google.com/') do |page|
    search_result = page.form_with(:name => 'f') do |search|
      search.q = "#{query}"
    end.submit
    return search_result
  end
end

def valid_json(json)
  begin  
    JSON.parse(json)  
    return true  
  rescue Exception => e  
    return false  
  end  
end 

class BibTexURL
  attr_accessor :url

  def initialize(url)
    @url = url
  end

  def url
    @url
  end

end

class Publisher
  attr_accessor :name, :url, :index

  def initialize(name, url, index)
    @name = name
    @url = url
    @index = 'www.coffee.com'
  end

  def meta
    ['url'=> @url, 'index'=> @index].to_json
  end

  def preformat_json
    @preformat_json = "#{@name}:#{meta}"
  end

end

book = Spreadsheet.open('journals.xls')
sheet1 = book.worksheet('asm-journals') # can use an index or worksheet name

output_file = File.open('trial2.json', 'a')
output_file.write("\{\n")

journal_array = []
File.open('journals.txt','r').each do |j|
  journal_array << j
end

i = 0
sheet1.each do |row|
  page = google_search("#{row[2].to_s}")

  begin
    first_link = page.search('#ires').search('li')[0].search('h3').search('a').first
    journal_url = first_link.attributes['href'].text().split('&')[0].split('=')[1]

    first_link = page.search('#ires').at_xpath('ol/li[@class="g"]/div')#.first.attributes['href'].text()

    @publisher = Publisher.new(row[2], journal_url, 'checking.com') 
    p i
    puts @publisher.preformat_json # {"ABA Journal", "http://www.abajournal.com/", "checking.com"}

    output_file.write("#{@publisher.preformat_json}")
    journal_array.delete_at(i)
  rescue
    puts page
    next
    # failed to get the information for that entry
  end



#  puts "Running query: 'site:#{@page.arr[1]} bibtex' "
#  bibtext_search = google_search("site:#{@page.arr[1]} bibtex")
#  fails = []
#  begin
#    url = bibtext_search.search('#ires').search('li')[0].search('h3').search('a').first
#    @bibtex_url = BibTexUrl.new(url)
#  rescue NoMethodError
#    puts "took a poo!"
#    fails << bibtext_search.search('#ires')
#  else
#    puts @bibtext_url.url
#  end


#  p unf[0].text()

#  for i in unf
#    puts i
#    puts "\n"
#  end

  i += 1

  # LOOP HOW MANY TIMES
  if i >= 60
    output_file.write("\n\}")
    output_file.close
    break
  else
    output_file.write(",\n")
  end

  sleep(rand(5))
  i % 5 == 0 ? sleep(5) : ''

end

test_contents = File.open('trial2.json', 'r').read
puts "Output verified as JSON: #{test_contents.to_s.valid_json?}"

puts "MISSED: "
puts journal_array






