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

  # arr = ["Accounting, Business & Financial History", "http://www.ingentaconnect.com/content/routledg/rabf"]
  if  arr[1].split('/')[0..3].join == 'http:www.ingentaconnect.comcontent'
    abb = arr[1].split('/')[-2..-1].join('/')

    temp = {
      "url"   => arr[1],
                # http://api.ingentaconnect.com/content/wb/bk18017/latest?format=rss
      "rss"   => "http://api.ingentaconnect.com/content/#{abb}/latest?format=rss",
      "index" => arr[1]
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
  p full_array
  return full_array
end









def main()  
  page_size = 20000
#  page = Mechanize.new.get 'http://www.ingentaconnect.com/content/title?j_type=online&j_startat=Aa&j_endat=Zz&j_pagesize=#1000000&j_page=1&j_availability=all'
  page = Mechanize.new.get 'http://www.ingentaconnect.com/content/title?j_type=online&j_startat=Aa&j_endat=Zz&j_pagesize=#{page_size}&j_page=1&j_availability=all'

  if page_size < page.search('div.left-col')[0].search('.rust')[0].text().to_i
    page = Mechanize.new.get 'http://www.ingentaconnect.com/content/title?j_type=online&j_startat=Aa&j_endat=Zf&j_pagesize=#{max_j}&j_page=1&j_availability=all'
  end

  journals = page.search('ul.bobby')[0].search('li/a')

  topics_list = []
  for journal in journals
    link = "http://www.ingentaconnect.com#{journal.attributes["href"].text()}".split(';')[0]
    name = journal.text().gsub(/[\n\t\r]/,"")
    p [name, link]
    topics_list << [name, link]
  end

  final = []
  for t in topics_list
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










