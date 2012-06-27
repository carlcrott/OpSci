require 'open-uri'
require 'nokogiri'
require 'mechanize'
#require 'spreadsheet' # if you're parsing spreadsheets

__FILE__ == $0 ? ( REPO_NAME = __FILE__.split(".")[0] ) : ""

def google_search(query)
  agent = Mechanize.new

  agent.get('http://google.com/') do |page|
    search_result = page.form_with(:name => 'f') do |search|
      search.q = "#{query}"
    end.submit
    return search_result
  end
end

journals = File.open('journals_complete_list.txt').read().split("\n")

unparsed, final = [], []
output_file = File.open("#{REPO_NAME}_output.json", 'w')

for journal in journals
  final << Thread.new(journal) { |j|

    puts "fetching: %s" % j
    page = google_search("#{j}")
    puts "resolved: %s" % j

    journal_url = page.search('#ires').search('li')[0].search('h3').search('a')[0].attributes['href'].text().split('&')[0].split('=')[1]
  
    output_file.write("#{URI::decode(journal_url)}\n")

  }
end

final.each { |f| f.join }






