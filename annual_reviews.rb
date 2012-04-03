require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'json'

REPO_NAME = __FILE__.split(".")[0]

class String
  def valid_json?
    begin
      JSON.parse(self)
      return true
    rescue Exception => e
      return false
    end
  end
end

def build_json(arr)
  full_array = []

  if arr[1].split('/').count == 3
    abb = arr[1].split('/')[2]
    @temp = {
      "url"   => "http://www.annualreviews.org#{arr[1]}",
      "rss"   => "http://www.annualreviews.org#{arr[2]}",
      "index" => "http://www.annualreviews.org/loi/#{abb}"
    }
  else
    puts "I dont know how to build this entry: #{arr[0]}"
  end

  arr[2] == 'idk' ? ( @temp['rss'] = 'idk' ) : ""

  full_array = { "name" => arr[0], "url" => @temp['url'], "rss" => @temp['rss'], "index" => @temp['index'] }
end






def verify_data(entry, v = true)
  begin ###### Verify url
     open(entry['url']).is_a? Tempfile
  rescue
    puts "ERROR: Expecting '#{entry['url']}' to parse open-uri" unless entry['index'] == 'idk'
  end

  begin ###### Verify rss
    Mechanize.new.get(entry['rss']).content.class.is_a? Nokogiri::XML::Document
  rescue
    if entry['rss'] != 'idk' 
      puts "ERROR: Expecting '#{entry['rss']}' to parse as Mechanize::File class"
      entry['rss'] = 'idk'
    end
  end

  begin ###### Verify index
    page = Mechanize.new.get(entry['index'])
    url_tests = []
    (2008..2012).map {|x| x="[text()*='#{x}']"; url_tests << page.search(x).count}
    raise "" unless url_tests.any? != 0
  rescue
    entry['index'] == 'idk' ? "": (puts "ERROR: Expecting '#{entry['index']}' to contain strings '2008..2012'")
  end

  v ? (puts "VERIFIED: #{entry}") : ""
  sleep(1) # annual reviews has a 100 sessions / 5 minutes
  return entry
end



def build_rss_feed_array()
  rss_feeds = []
  # Annual reviews publishes their content without pretty links
  # So we pull in their RSS index
  rss_index_page = Mechanize.new.get "http://www.annualreviews.org/page/about/rssfeeds"
  rss_indexes = rss_index_page.search('.browseContent').search('ul').search('a')

  # build a index of the urls
  for rss in rss_indexes
    rss_feeds << rss.attributes['href'].text().sub('%20','') # their links are a little buggy
  end
  return rss_feeds
end

def get_rss_feed(abb, rss_feeds)
  for feed in rss_feeds
    journal = feed.split('&')[3][3..-1]
    if journal == abb
      puts "matched:  #{journal}"
      return feed
    end
  end
  puts "BLEEP! BLOOP! I couldn't find the RSS feed for #{abb}"
  return "idk"
end

def main()
  agent = Mechanize.new
  page = agent.get("http://www.annualreviews.org/")
  # only the first 4 of these divs have links to journals
  topics = page.search('.mainNavJournalList')[0..3].search('a')

  rss_feeds = build_rss_feed_array()

  final = []
  for topic in topics
    puts "topic #{topic}"
    rss = nil
    name = topic.text()
    url = topic.attributes["href"].text()
    abb = url.split('/')[-1]

    # then match individual rss urls by their journal abbreviation
    puts abb
    rss = get_rss_feed(abb, rss_feeds)

    p rss
    puts '----------------------------------------'
    temp = [name, url, rss]
    entry = build_json(temp)
    verified_journal_entry = verify_data(entry,false)
    final << verified_journal_entry
  end


  # Write out... and verify once more on quiet mode
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








