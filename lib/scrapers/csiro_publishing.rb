require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'json'
require './skraper_addons.rb'

__FILE__ == $0 ? ( REPO_NAME = __FILE__.split(".")[0] ) : ""

class String
  include JsonMethods
end




def get_rss
  #http://www.publish.csiro.au/nid/228.htm?nid=50&aid=3704


end

def build_json(arr)
  full_array = []

  # arr = ["Emu ", "http://www.publish.csiro.au/nid/96.htm"]
  if  arr[1].split('/')[2] == 'www.publish.csiro.au'
#    abb = arr[1].split('=')[1]


    temp = {
      "url"   => "#{arr[1]}",
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
  puts "The code structure for this website is all over the place ... skipped"
  page = Mechanize.new.get 'http://www.publish.csiro.au/nid/17.htm'
  journals = page.search('#content').search('table').search('a')

#  p journals.count

  topics_list = []
  for journal in journals 
    link = "http://www.publish.csiro.au#{journal.attributes["href"].text()}"
    name = journal.text()
#    p link
#    p name
    p [name, link]
    topics_list << [name, link]
  end

#  final = []
#  for t in topics_list
##    build_json(t)
##    journal_entry = verify_data(build_json(t))
##    final << journal_entry
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










