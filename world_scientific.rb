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

  if  arr[1][-6..-1] == '.shtml' # regular internal link
    abb = arr[1].split('/')[1]

    arr[1][0] != '/' ? ( arr[1].insert 0,'/' ): "" # some internal links are missing a leading /

    @temp = {
      "url"   => "http://www.worldscinet.com#{arr[1]}",
      "rss"   => "http://www.worldscinet.com/#{abb}/#{abb}.rss",
      "index" => "http://www.worldscinet.com/#{abb}/mkt/archive.shtml"
    }
  elsif arr[1][0..6] == 'http://'
     @temp = {
      "url"   => arr[1],
      "rss"   => "idk",
      "index" => "idk"
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => @temp['url'], "rss" => @temp['rss'], "index" => @temp['index'] }
  return full_array
end






def main()  
  page = Mechanize.new.get('http://www.worldscinet.com/alphabetical.shtml')
  journals = page.search('table')[15].search('a')

  topics_list = []
  for journal in journals 
    link = journal.attributes["href"].text()
    name = journal.text()
    name != "" ? (topics_list << [name,link]) : ""
  end

  final = []
  for t in topics_list
    build_json(t)
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








