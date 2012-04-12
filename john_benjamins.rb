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

  # arr = ["Robotica", "http://journals.cambridge.org/action/displayJournal?jid=ROB"]
  if  arr[1].split('/')[-1].split('?')[0] == 'displayJournal'
    abb = arr[1].split('=')[1]

    temp = {
      "url"   => arr[1],
      "rss"   => "http://journals.cambridge.org/data/rss/feed_#{abb}_rss_2.0.xml",
      "index" => "http://journals.cambridge.org/action/displayBackIssues?jid=#{abb}"
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
  p full_array
  return full_array
end









def main()  
  puts "Ignoring this publisher as most of their journals are on ingenta connect"
  page = Mechanize.new.get 'http://journals.cambridge.org/action/browseJournalsAlphabetically'
  journals = page.search('#serieslist').search('td/.bktitle').search('a')

#  topics_list = []
#  for journal in journals
#    link = "http://benjamins.com/#{journal.attributes["href"].text()}"
#    name = journal.text()

#    index = Mechanize.new.get(link).search('//a[contains(@text,"ingentaConnect")]')

#    p [name, link]
#    topics_list << [name, link, index]
#  end

#  final = []
#  for t in topics_list
#    journal_entry = verify_data(build_json(t))
#    final << journal_entry
#  end

#  puts "VALID JSON? #{final.to_json.valid_json?}"
#  output_file = "#{REPO_NAME}_output.json"

#  puts "Writing output to file: #{output_file}"
#  File.open(output_file,'a').write(final.to_json)

#  puts "VERIFYING... All outputs should be quiet"
#  for entry in final
#    verify_data(entry, false)
#  end

end



main()










