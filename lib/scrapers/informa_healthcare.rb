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

  # arr = ["Stress", "http://informahealthcare.com/journal/sts"]
  if  arr[1].split('/')[2] == 'informahealthcare.com'
    abb = arr[1].split('/')[-1]

    temp = {
      "url"   => "#{arr[1]}",
      "rss"   => "http://informahealthcare.com/action/showFeed?ui=0&mi=3w36vt&ai=1lgs&jc=#{abb}&type=etoc&feed=rss",
      "index" => "http://informahealthcare.com/loi/#{abb}"
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
  p full_array
  return full_array
end







 


def main()
  puts "Informa bans @ > 25 sessions / 5 minutes AKA 5sess/min"
  
  page = Mechanize.new.get 'http://informahealthcare.com/action/showPublications?display=byAlphabet&pubType=journal'
  journals = page.search('div#content').search('a')

  topics_list = []
  for journal in journals 
    link = "http://informahealthcare.com#{journal.attributes["href"].text()}"
    name = journal.text()

    p [name, link]
    topics_list << [name, link]
  end

  final = []
  for t in topics_list
    journal_entry = verify_data(build_json(t))
    final << journal_entry
    sleep(60) # needs to be under 5 sessions / min
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










