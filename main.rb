require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'json'

REPO_NAME = 'main'

#publisher class + adapter
class Publisher
  attr_accessor :name, :url, :index, :rss

  def initialize(name, url, index, rss)
    @name   = name
    @url    = url
    @index  = index
    @rss    = rss
  end

  def hash
    @hash = {
      "name"  => @name,
      "url"   => @url,
      "index" => @index,
      "rss"   => @rss
    }
  end
end

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

#final_JSON_file << individual_journal_hashses

puts "opening journal stores"
journals = []
File.open('kanz_journals.txt','r').each do |j|
  journals << j
end

unparsed = []
final = []
output_file = open("#{REPO_NAME}_output.json",'a')

for row in journals
  page = google_search("#{row.to_s}")

  begin
    first_link = page.search('#ires').search('li')[0].search('h3').search('a').first
    url = first_link.attributes['href'].text().split('&')[0].split('=')[1]

    index, rss = 'idk','idk'

    @publisher = Publisher.new(row.chomp, url, index, rss) 
    puts @publisher.hash
    final << @publisher.hash

  rescue
    unparsed << row
  end

#  output_file.write("#{@publisher.hash.to_json}")

  sleep(rand(1))

end

  export = final.to_json
  puts "VALID JSON? #{export.valid_json?}"
  File.open(output_file,'a').write(export)

p unparsed


