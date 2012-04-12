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

  if arr[1][0..9] == '/journals/' # regular internal link
    temp = {
      "url"   => "http://www.begellhouse.com#{arr[1]}",
      "rss"   => "idk",
      "index" => "http://www.begellhouse.com#{arr[1]}" # in .volume_list
    }
  elsif arr[1][0..6] == 'http://' # external link
    temp = {
      "url"   => "#{arr[1]}",
      "rss"   => "idk",
      "index" => "idk"
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
  return full_array
end







def main()  
  page = Mechanize.new.get('http://www.begellhouse.com/journals/')
  # Grab the index URL for each topic
  trs = page.search('table.list_journal')[0].search('tr')

  topics_list = []
  for tr in trs[1..-1] # the first tr has no information in it
    td = tr.search('td')
    link = td.search('a')[0].attributes["href"].text()
    name = td.text()
    topics_list << [name,link]
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








