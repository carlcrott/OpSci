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

  # arr = ["Advances in Neuroimmune Biology", "http://www.iospress.nl/journal/advances-in-neuroimmune-biology/", "http://iospress.metapress.com/content/1878-948X/"]
          ["Advances in Neuroimmune Biology", "http://www.iospress.nl/journal/advances-in-neuroimmune-biology/", "http://iospress.metapress.com/content/1878-948X/"]
  if  arr[1].split('/').length == 5 && arr[1].split('/')[2..3].join == 'www.iospress.nljournal'
    abb = arr[1].split('=')[1]

    temp = {
      "url"   => arr[1],
      "rss"   => "idk",
      "index" => arr[2]
    }
  else


    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
  p full_array
  return full_array
end









def main()
  puts "This journal has many refs to external sites with dissimilar formatting"
  page = Mechanize.new.get 'http://www.iospress.nl/journals-list/'
  journals = page.search('#content/.product-block').search('li').search('h4/a')

  topics_list = []
  for journal in journals 
    link = journal.attributes["href"].text()
    name = journal.text()
    # Index is only available by hitting above link
    index_page = Mechanize.new.get link
    begin
      index = index_page.search('//a[contains(text(),"Contents")]')[0].attributes['href'].text()
    rescue
      puts "Journal has external website: #{link}"
      index = index_page.search('.text-holder/.holder/.box').search('a')[0].attributes['href'].text()
    end

    p [name, link, index]
    topics_list << [name, link, index]
  end


  final = []

  for t in topics_list
    journal_entry = verify_data(build_json(t))
    final << journal_entry
  end

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










