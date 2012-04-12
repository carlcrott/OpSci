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

  # arr = ["Nashim", "http://www.jstor.org/action/showPublication?journalCode=nashim"]
  if  arr[1].split('/')[-1].split('=')[0] == 'showPublication?journalCode'
    abb = arr[1].split('=')[1]

    temp = {
      "url"   => "#{arr[1]}",
                # http://www.jstor.org/action/showFeed?ui=0&mi=jvgyidf&ai=k7s&jc=africatoday&type=etoc&feed=rss
      "rss"   => "http://www.jstor.org/action/showFeed?ui=0&mi=jvgyidf&ai=k7s&jc=#{abb}&type=etoc&feed=rss",
      "index" => "#{arr[1]}"
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
  p full_array
  return full_array
end









def main()  
  page = Mechanize.new.get 'http://www.iupress.indiana.edu/pages.php?pID=20&CDpath=4'
  journals = page.search('#homepage-top').search('table').search('em/a')


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










