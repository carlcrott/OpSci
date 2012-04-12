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

  if  arr[1][0..10] == 'pub.cfm?id=' # regular internal link
    temp = {
      "url"   => "http://dl.acm.org/#{arr[1]}",
      "rss"   => "idk",
      "index" => "idk" # in id 'pubs'
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
  return full_array
end








def main()  
  page = Mechanize.new.get 'http://dl.acm.org/'
  journals_page = page.search('//*[contains(text(),"Journals/Transactions")]')[0].attributes['href'].text()
  page = Mechanize.new.get "http://dl.acm.org/#{journals_page}"

  trs = page.search('.text12').search('tr')

  topics_list = []
  for tr in trs
    a_element = tr.search('td')[1].search('a')[0]
    link = a_element.attributes["href"].text()
    name = a_element.text()
    p [name,link]
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








