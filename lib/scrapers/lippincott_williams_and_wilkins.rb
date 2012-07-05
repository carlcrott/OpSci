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
  puts "skipped this one ... I need to come up with a better way to collect all the journals onto a single page"
  j_count = 300

#  uri_main = URI.escape("http://www.lww.com/webapp/wcs/stores/servlet/CatalogSearchResultCmd?storeId=11851&catalogId=9012052&langId=-1&searchTerm=journal#docType=0&pageSize=300&storeId=11851&langId=-1&catalogId=9012052&searchTerm=journal&resultCatEntryType=&beginIndex=0&sType=&searchTermScope=&facetFields=%2CpublicationDate_facet%2CpubFrequency_facet%2CauthorNames_facet%2Cprimary&filterValue=productType_facet%3A%22Journal+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%22%7C%22Journal+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%22&sortBy=productNameSort+asc")

#  uri_main = URI.escape("http://www.lww.com/webapp/wcs/stores/servlet/CatalogSearchResultCmd?storeId=11851&catalogId=9012052&langId=-1&searchTerm=journal#docType=0&pageSize=300&sortBy=productNameSort+asc++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%22|Journal&sortBy=")

  page = Mechanize.new.get 'http://bit.ly/J2wON0'

  p page

  max_j_count = page.search('#results-message').text()#.split('of')[-1].to_i
  p max_j_count
  journals = page.search('div.product').search('li').search('a')
  p journals.count

  journals = page.search('//div[contains(@id,"product")]')#.search('li').search('a')
  p journals.count


#  topics_list = []
#  for journal in journals 
#    link = "http://journals.cambridge.org/action/#{journal.attributes["href"].text()}"
#    name = journal.text()
#    p [name, link]
#    topics_list << [name, link]
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










