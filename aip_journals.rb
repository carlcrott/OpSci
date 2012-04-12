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
  temp = []
  full_array = []
  if arr[1].include? 'http://'
    arr[1][-1] == '/' ? arr[1].chop! : ""
    temp = [
      "url"=>"#{arr[1]}",
      "rss"=>"#{arr[1]}features/rss_feeds",
      "index"=>"#{arr[1]}browse"
    ]
  else
    p arr
  end

  arr[0] = arr[0].gsub(/[\n\t]/,"").strip.gsub(/\s+/," ")

  full_array = {"#{arr[0]}"=>temp}
  p full_array
  return full_array

end


def main()  
  agent = Mechanize.new
  page = agent.get("http://journals.aip.org/")
  topics = page.search('.jrnls').search('a')

  topics_list = []

  for u in topics 
    link = u.attributes["href"].text()#.split("/")
    name = u.text()
    if name != ""
      temp = [name,link]
#      p temp
      topics_list << temp
    else
      # its one of the duplicates
    end 
  end

  final = []

  for topic in topics_list
    final << build_json(topic)
  end

  puts "VALID JSON? #{final.to_json.valid_json?}"
  output_file = "#{REPO_NAME}_output.json"

  puts "Writing output to file: #{output_file}"
  File.open(output_file,'a').write(final.to_json)

end

main()

#http://www.rsc.org/publishing/journals/catalogue/index.asp










