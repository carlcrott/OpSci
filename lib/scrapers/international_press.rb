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

  # arr = ["Asian Journal of Mathematics", "http://www.intlpress.com/AJM/"]
  if  arr[1].split('/')[2] == 'www.intlpress.com'
    abb = arr[1].split('/')[-1]

    temp = {
      "url"   => "#{arr[1]}",
      "rss"   => "idk",
      "index" => "http://www.intlpress.com/#{abb}/#{abb}-BrowseJournal.php"
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
  p full_array
  return full_array
end









def main()
  page = Mechanize.new.get 'http://www.intlpress.com/'
  journals = page.search('div#LeftMenu').search('li.topmenuli')

  puts journals.count

  topics_list = []
  for journal in journals[1..-1] # their first item of this type is just a heading
    link = journal.search('a')[0].attributes["href"].text()
    name = journal.search('li.submenuli/a')[0].text().gsub(/[\r\n\t]/,'')
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










