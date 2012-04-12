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

  # arr = ["Genes & Development", "http://www.genesdev.org/"]
  if  arr[1][0..10] == 'http://www.'
#    abb = arr[1].split('=')[1]
    temp = {
      "url"   => "#{arr[1]}",
      "rss"   => "#{arr[1]}rss/current.xml",
      "index" => "#{arr[1]}content/by/year"
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
  p full_array
  return full_array
end






def main()  
  page = Mechanize.new.get 'http://www.cshlpress.com/'
  journals = page.search('ul#b_navList/li')[1].search('ul/li/a')

  topics_list = []
  for journal in journals
    link = journal.attributes["href"].text()
    name = journal.text()
#    p link
#    p name
    p [name, link]
    topics_list << [name, link]
  end

  final = []
  for t in topics_list
#    build_json(t)
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










