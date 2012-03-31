require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'json'

REPO_NAME = __FILE__.split(".")[0].sub(' ','')

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
  if arr[1].include? 'http://'
    temp = {
      "url"=>"#{arr[1]}",
      "rss"=>"IDK",
      "index"=>"IDK"
    }
  elsif arr[1].include? '/journal/'
    code = arr[1].split("/")[-1] 
    temp = {
      "url"=>"http://pubs.acs.org/journal/#{code}",
      "rss"=>"http://feeds.feedburner.com/acs/#{code}",
      "index"=>"http://pubs.acs.org/loi/#{code}"
    }
  elsif arr[1][0] == '/'
    temp = {
      "url"=>"http://pubs.acs.org#{arr[1]}",
      "rss"=>"IDK",
      "index"=>"IDK"
    }
  else
    p arr
  end

  p full_array

  full_array = {"#{arr[0]}"=>temp}
  return full_array

end


def main()  
  agent = Mechanize.new
  page = agent.get("http://pubs.acs.org/")

  topics = page.search('#azView').search('a')

  topics_list = []
  for u in topics 
    link = u.attributes["href"].text()#.split("/")
    name = u.text()
    if name != "" #(link.include? "http://" == true) || (link.include? "/journal/" == true)
      temp = [name,link]
      topics_list << temp
    else
#      puts link
    end
  end

  final = []
  for t in topics_list
    unf = build_json(t)

    final << unf
  end

  puts "VALID JSON? #{final.to_json.valid_json?}"
  output_file = "#{REPO_NAME}_output.json"

  puts "Writing output to file: #{output_file}"
  File.open(output_file,'a').write(final.to_json)

end

main()


#puts "Valid JSON? #{full_array.to_s.valid_json?}"

#puts full_array








