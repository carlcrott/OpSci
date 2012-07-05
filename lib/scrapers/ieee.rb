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

  # arr = ["Advanced Packaging, IEEE Transactions on", "/xpl/RecentIssue.jsp?punumber=6040"]
  if  arr[1].split('/')[-1].split('=')[0] == 'RecentIssue.jsp?punumber'
    abb = arr[1].split('=')[1]

    temp = {
                # http://ieeexplore.ieee.org/xpl/RecentIssue.jsp?punumber=6040
      "url"   => "http://ieeexplore.ieee.org#{arr[1]}",
                # http://ieeexplore.ieee.org/rss/TOC4509581.XML
      "rss"   => "http://ieeexplore.ieee.org/rss/TOC#{abb}.XML",
                # http://ieeexplore.ieee.org/rss/TOC4509581.XML
      "index" => "http://ieeexplore.ieee.org#{arr[1]}"
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
  p full_array
  return full_array
end









def main()
  main_uri = 'http://ieeexplore.ieee.org/xpl/periodicals.jsp?rowsPerPage=300&pageNumber=1'
  page = Mechanize.new.get main_uri
  max_j_num = page.search('div.results-display/h2')[0].text()

  # gets the max number of journals the IEEE has online
  max_j_num = max_j_num.split(' ')[0].to_i

  # if there are more than 1000 journals ... up the count via URL
  if max_j_num > 1000
    main_uri = "http://ieeexplore.ieee.org/xpl/periodicals.jsp?rowsPerPage=#{max_j_num}&pageNumber=1"
    page = Mechanize.new.get main_uri
  end  

  journals = page.search('#primary-content')[0].search('.reveal-content-title-full/h3/a')

  p journals.count

  topics_list = []
  for journal in journals 
    link = journal.attributes["href"].text()
    name = journal.text().gsub(/[\r\n\t]/,'')

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










