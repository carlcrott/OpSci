require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'spreadsheet'
require 'json'

#f = File.open('aba journal - Google Search.html')
#html = Nokogiri::HTML(open(f))
#unf = html.xpath('/html/body/div[4]/div/div/div[4]/div[2]/div[2]/div/div[2]/div/ol/li/div/h3/a')
#p unf[0]

def google_search(query)
  agent = Mechanize.new

  agent.get('http://google.com/') do |page|
    search_result = page.form_with(:name => 'f') do |search|
      search.q = "#{query}"
    end.submit
    return search_result
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
    @index = index
  end

  def meta
    ['url'=> @url, 'index'=> @index].to_json
  end

  def hash
    @hash = "\"#{@name.chomp}\":#{meta}"
  end

end

output_file = File.open('kanz_journals_google_output.json', 'w')
output_file.write("\{\n")

journals = []
File.open('kanz_journals.txt','r').each do |j|
  journals << j
end

unparsed = []
i = 1
journals.each do |row|
  page = google_search("#{row.to_s}")

  # hack this down into real XML traversal
  begin
    first_link = page.search('#ires').search('li')[0].search('h3').search('a').first
    journal_url = first_link.attributes['href'].text().split('&')[0].split('=')[1]

    first_link = page.search('#ires').at_xpath('ol/li[@class="g"]/div')

    @publisher = Publisher.new(row, journal_url, 'checking.com') 
    puts ("#{@publisher.hash}")

    output_file.write("#{@publisher.hash}")
  rescue
    puts row
    unparsed << row
  end

  
  output_file.write(",\n") unless i == journals.count
  i += 1

  sleep(rand(8))
  i % 5 == 0 ? sleep(5) : ''

end



output_file.write("\n\}")






test_contents = File.open('kanz_journals_google_output.json', 'r').read
puts "Output verified as JSON: #{test_contents.to_s.valid_json?}"

puts "MISSED: "
puts unparsed





