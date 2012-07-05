require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'json'
require './skraper_addons.rb'

__FILE__ == $0 ? ( REPO_NAME = __FILE__.split(".")[0] ) : ""

class String
  include JsonMethods
end




def build_json(arr)
  full_array = []

  # arr = [
#   "Nephron", 
#   "http://content.karger.com/ProdukteDB/produkte.asp?Aktion=JournalHome&ProduktNr=223854", 
#   "NEF", 
#   "http://content.karger.com/ProdukteDB/produkte.asp?Aktion=BackIssues&ProduktNr=223854"
  # ]

  if  arr[1].split('/')[-1].split('?')[0] == 'produkte.asp'
    abb = arr[2]

    temp = {
      "url"   => arr[1],
      "rss"   => "http://content.karger.com/ProdukteDB/rss.aspx?j=#{abb}",
      "index" => arr[3]
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
  p full_array
  return full_array
end









def main()  
  page = Mechanize.new.get 'http://content.karger.com/ProdukteDB/produkte.asp?Aktion=JournalIndex&ContentOnly=false'
  journals = page.search('/html/body/table/tr[2]/td[3]/table/tr/td/table[3]').search('span')

  topics_list = []
  for journal in journals 
    link = journal.search('a.middle1')[0].attributes["href"].text()
    name = journal.search('a.middle1')[0].text()
    abb = journal.attributes['title'].text()
    index = journal.search('a.small')[0].attributes["href"].text()
    p [name, link, abb, index]
    topics_list << [name, link, abb, index]
  end

  final = []
  for t in topics_list
    journal_entry = verify_data(build_json(t))
    final << journal_entry
  end

  puts "VALID JSON? #{final.to_json.valid_json?}"
  output_file = "#{REPO_NAME}_output.json"

  puts "Writing output to file: #{output_file}"
  File.open(output_file,'a').write(final.to_json)

  puts "VERIFYING... All outputs should be quiet"
  for entry in final
    verify_data(entry, false)
  end

end



main()










