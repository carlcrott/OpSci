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

  # arr = ["Ecological Issues", "http://www.britishecologicalsociety.org/policy/ecological_issues.php"]
  if  arr[1].split('/')[-1].split('?')[0] == 'displayJournal'
    abb = arr[1].split('=')[1]

    @temp = {
      "url"   => "#{arr[1]}",
      "rss"   => "http://journals.cambridge.org/data/rss/feed_#{abb}_rss_2.0.xml",
      "index" => "http://journals.cambridge.org/action/displayBackIssues?jid=#{abb}"
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => @temp['url'], "rss" => @temp['rss'], "index" => @temp['index'] }
  p full_array
  return full_array
end








def main()
  puts "Skipped bc this journal in indexed by wiley"
  page = Mechanize.new.get('http://www.britishecologicalsociety.org/journals_publications/')
  journals = page.search('#content').search('h2').search('a')

  topics_list = []
  for journal in journals 
#    p journal.text()
#    p journal.attributes["href"].text()
    link = "http://www.britishecologicalsociety.org#{journal.attributes["href"].text()}"
    name = journal.text()
#    p [name, link]
    topics_list << [name, link]
  end

#  final = []
#  for t in topics_list
##    build_json(t)
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










