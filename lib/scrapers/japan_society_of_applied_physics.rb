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

  # arr = ["APEX - Applied Physics Express", "http://apex.ipap.jp/", "http://apex.jsap.jp/rss/apex.xml"]
  if  arr[1][0..6] == 'http://'
    abb = arr[1].split('/')[2].split('.')[0]

    temp = {
      "url"   => arr[1],
      "rss"   => arr[2],
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
  page = Mechanize.new.get 'http://www.jsap.or.jp/english/journals/index.html'
  journals = page.search('div.block-cont').search('a')
  rss_page_links = Mechanize.new.get('http://jjap.jsap.jp/rss/index.html').search('a')
  topics_list = []
  for journal in journals[1..-1]
    link = journal.attributes["href"].text()
    name = journal.text()

    for rss_link in rss_page_links[4..7]
      begin
        if rss_link.text().include? name.split('-')[0].gsub(" ","")
          rss = rss_link.attributes["href"].text()
        end
      rescue
        rss = 'idk'
      end
    end


    p [name, link, rss]
    topics_list << [name, link, rss]
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










