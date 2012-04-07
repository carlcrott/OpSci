require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'json'

__FILE__ == $0 ? ( REPO_NAME = __FILE__.split(".")[0] ) : ""

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
  journals << j.chomp
end

unparsed = final = []
output_file = open("#{REPO_NAME}_output.json",'a')

def search_loop(journals, final)
  journals.length == 0 ? (return final) : "" # breaks recursion

  for row in journals
    Thread.new(row) { |i| # http://www.ruby-doc.org/docs/ProgrammingRuby/html/tut_threads.html

      puts "fetching: %s" % i
      journals.delete(i)

      begin
        page = google_search("#{i}")
        puts "resolved: %s" % i

        first_link = page.search('#ires').search('li')[0].search('h3').search('a').first
        url = first_link.attributes['href'].text().split('&')[0].split('=')[1]
        index, rss = 'idk','idk'

        @publisher = Publisher.new(i.chomp, url, index, rss) 
        puts @publisher.hash
        final << @publisher.hash
      rescue
        puts "throttled"
        journals << i
      end

    }
  end

  # by calling .join on all the threads we're running it as blocking code
  # allowing the processing to finish
  p final.each { |f| f.join }

  puts final.length

  if journals.count > 0
    puts "recurse"
    sleep(1)
    search_loop(journals,final)
  end
end

search_loop(journals,final)

p final.each { |f| f.join }

export = final.to_json
p export
puts "VALID JSON? #{export.valid_json?}"
File.open(output_file,'a').write(export)

output_file = open("#{REPO_NAME}_output.json",'a')










