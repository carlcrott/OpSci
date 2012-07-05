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

  # arr = ["Decision Analysis", "http://da.pubs.informs.org"]
  if  arr[1].split('/')[-1].split('.')[1..3].join == 'pubsinformsorg'
    abb = arr[1].split('/')[-1].split('.')[0]

    temp = {
      "url"   => "#{arr[1]}",
      "rss"   => "idk",
      "index" => "http://www.informs.org/Pubs/#{abb.upcase}/Past-Issues"
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
  p full_array
  return full_array
end









def main()  
  page = Mechanize.new.get 'http://www.informs.org/Find-Research-Publications/Journals'
  journals = page.search('div.publication-item')

  topics_list = []
  for journal in journals 
    link = journal.search('//a[contains(text(), "Editorial Site")]')[0].attributes["href"].text()
    name = journal.search('h3').text()
    p [name, link]
    topics_list << [name, link]
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










