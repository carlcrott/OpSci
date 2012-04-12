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

  # arr = ["Prostate Cancer", "/journals/pc/"]
  if  arr[1].split('/')[1] == 'journals'
    abb = arr[1].split('/')[2]

    temp = {
      "url"   => "http://www.hindawi.com#{arr[1]}",
      "rss"   => "idk",
              #   http://www.hindawi.com/journals/aai/contents/
      "index" => "http://www.hindawi.com/journals/#{abb}/contents/"
    }
  # arr = ["Case Reports in Anesthesiology", "/crim/anesthesiology/"]
  elsif arr[1].split('/')[1] == 'crim'
    abb = arr[1].split('/')[2]

    temp = {
      "url"   => "http://www.hindawi.com#{arr[1]}",
      "rss"   => "idk",
              #   http://www.hindawi.com/journals/aai/contents/
      "index" => "http://www.hindawi.com/crim/#{abb}/contents/"
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
  p full_array
  return full_array
end









def main()
  puts "it seems this journal publishes in a wonk way"
  page = Mechanize.new.get 'http://www.hindawi.com/journals/'
  journals = page.search('#browse_area').search('li').search('a')

  topics_list = []
  for journal in journals 
    link = journal.attributes["href"].text()
    name = journal.text()

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










