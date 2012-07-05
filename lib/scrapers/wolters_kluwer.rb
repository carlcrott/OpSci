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

  p arr
#  http://journals.lww.com/co-allergy/pages/default.aspx
#  http://journals.lww.com/co-allergy/pages/issuelist.aspx
#  http://journals.lww.com/co-allergy/pages/issuelist.aspx

  if arr[1][0..23] == "http://journals.lww.com/"
    abb = arr[1].split('/')[3]
    # Only RSS feeds were 'Editors pics' and 'Most viewed' 
    # SO ... nixing those
    @temp = {
      "url"   => "#{arr[1]}",
      "rss"   => "idk",
      "index" => "http://journals.lww.com/#{abb}/pages/issuelist.aspx"
    }
  else
    puts "I dont know how to build this entry: #{arr}"
  end

  full_array = { 
    "name"   => arr[0],
    "url"    => @temp['url'],
    "rss"    => @temp['rss'],
    "index"  => @temp['index']
  }
  p full_array
end







def main()
  # Open the publishers index by topic
  page = Mechanize.new.get('http://journals.lww.com/pages/default.aspx?journalsBySpeciality=true')
  # Grab the index URL for each topic
  topic_urls = page.search('//*[contains(@id, "_divSpecialities")]')[0].search('a')

  final = []
  # each topic_url has multiple journals
  for topic in topic_urls
    url = topic.attributes["href"].text()
    p url 
    topic_index = Mechanize.new.get(url)
    topic_journals = topic_index.search('.ej-article-table-fluid').search('h4').search('a')

    for journal in topic_journals
      temp = [ journal.text(), journal.attributes["href"].text() ]
      # then build out those json entries ... and verify them
      journal_entry = verify_data(build_json(temp))
      final << journal_entry
    end
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








