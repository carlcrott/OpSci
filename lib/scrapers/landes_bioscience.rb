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

  # arr = ["Human Vaccines & Immunotherapeutics", "http://www.landesbioscience.com/journals/vaccines/"]
  if  arr[1].split('/')[-2] == 'journals'
    abb = arr[1].split('/')[-1]

    temp = {
      "url"   => arr[1],
                # http://www.landesbioscience.com/rss/journals/adipocyte/aop/
      "rss"   => "http://www.landesbioscience.com/rss/journals/#{abb}/aop/",
                # http://www.landesbioscience.com/journals/adipocyte/archive/
      "index" => "http://www.landesbioscience.com/journals/#{abb}/archive/"
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
  p full_array
  return full_array
end









def main()  
  page = Mechanize.new.get 'http://www.landesbioscience.com/journals/'
  journals = page.search('.landes_content_center/a')

  topics_list = []
  for journal in journals 
    link = "http://www.landesbioscience.com#{journal.attributes["href"].text()}"
    name = journal.search('h3.short')[0].text()
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










