require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'json'

__FILE__ == $0 ? ( REPO_NAME = __FILE__.split(".")[0] ) : ""

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

  temp = []
  full_array = []

  if arr[1].include? 'http://' #["Earth Interactions", "http://earthinteractions.org/"]
    temp = [
      "url"=>"#{arr[1]}",
      "rss"=>"IDK",
      "index"=>"IDK"
    ]
  elsif arr[1].split("/").count == 3 #["Geochemistry, Geophysics, Geosystems", "/journals/gc/"]
    temp = [
      "url"=>"http://www.agu.org/journals{arr[1]}",
      "rss"=>"http://www.agu.org/pubs/rss/#{arr[1].split('/')[-1]}_rss.xml",
      "index"=>"http://www.agu.org/journals/#{arr[1].split('/')[-1]}/mp364.shtml"
    ]
  elsif arr[1].include? '/pubs/' #["Personal Choice", "/pubs/journals/virtual/personal_choice.shtml"]
    temp = [
      "url"=>"#{arr[1]}",
      "rss"=>"IDK",
      "index"=>"IDK"
    ]
  else
    p arr
  end

  full_array = {"#{arr[0]}"=>temp}
  return full_array

end


def main()  
  agent = Mechanize.new
  page = agent.get("http://www.agu.org/pubs/journals/")
  topics = page.search('.list-tight').search('a')

  topics_list = []

  for u in topics 
    link = u.attributes["href"].text()#.split("/")
    name = u.text()
    if true
      temp = [name,link]
      p temp
      topics_list << temp
    else
      puts link
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










