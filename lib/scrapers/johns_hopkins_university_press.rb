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

  # arr = ["Library Trends", "http://www.press.jhu.edu/journals/library_trends", "http://feeds.muse.jhu.edu/journals/library_trends/latest_articles.xml"]
  if  arr[1].split('/')[-2]== 'journals'
    abb = arr[1].split('/')[-1]

    temp = {
      "url"   => arr[1],
      "rss"   => arr[2],
      "index" => "http://muse.jhu.edu/journals/#{abb}/"
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
#  p full_array
  return full_array
end









def main()  
  page = Mechanize.new.get 'http://www.press.jhu.edu/journals/titles.html'
  journals = page.search('#textwell/ul/li/a')

  rss_feeds = Mechanize.new.get('http://www.press.jhu.edu/journals/toc_feeds_rss.html').search('#textwell/.feeds_list').search('a')

  feed_hash = Hash.new
  for feed in rss_feeds
    feed_hash[feed.text()] = feed.attributes["href"].text()
  end

  

  topics_list = []
  for journal in journals 
    link = "http://www.press.jhu.edu#{journal.attributes["href"].text()}"
    name = journal.text()
    rss = feed_hash[name]

    p [name, link, rss]
    topics_list << [name, link, rss]
  end

  final = []
  for t in topics_list
    journal_entry = verify_data(build_json(t))
    final << journal_entry
    sleep(3)
  end

  puts "VALID JSON? #{final.to_json.valid_json?}"
  output_file = "#{REPO_NAME}_output.json"

  puts "Writing output to file: #{output_file}"
  File.open(output_file,'a').write(final.to_json)

  puts "VERIFYING... All outputs should be quiet"
  for entry in final
    verify_data(entry, false)
    sleep(3)
  end

end



main()










