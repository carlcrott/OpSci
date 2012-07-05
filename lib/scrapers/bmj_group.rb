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

  # arr = ["http://heart.bmj.com/contents-by-date.0.dtl", "Heart"]
  if  arr[1].include? '.bmj.com/'
    abb = arr[1].split('/')[2].split('.')[0]
    arr[1][-1] == '/' ? ( arr[1].chop ) : "" # ensure all URLS end without "/"
    @temp = {
      "url"   => "#{arr[1]}",
      "rss"   => "http://#{abb}.bmj.com/rss/recent.xml",
      "index" => "http://#{abb}.bmj.com/content/by/year"
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => @temp['url'], "rss" => @temp['rss'], "index" => @temp['index'] }
  return full_array
end









def main()  
  page = Mechanize.new.get('http://group.bmj.com/group/media/bmj-journals-information-centre')
  journals = page.search('#parent-fieldname-text').search('li').search('a')

  topics_list = []
  for journal in journals 
    link = journal.attributes["href"].text()
    name = journal.text()
    link[-1] == "/" ? ( link = link.chop ) : "" # ensure all URLS end without "/"
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










