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

  # arr = [" Russian Mathematical Surveys ", "http://iopscience.iop.org/0036-0279"]
  if  arr[1].split('/')[-1].split('-').length == 2
    abb = arr[1].split('/')[-1]

    temp = {
      "url"   => "#{arr[1]}",
                # http://iopscience.iop.org/2043-6262/?rss=1
      "rss"   => "http://iopscience.iop.org/#{abb}/?rss=1",
      "index" => "#{arr[1]}"
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
  p full_array
  return full_array
end









def main()  
  page = Mechanize.new.get 'http://iopscience.iop.org/journals'
  journals = page.search('div.twoEqualCols').search('a')

  topics_list = []
  for journal in journals[1..-1] # first link is not a journal
    link = "http://iopscience.iop.org#{journal.attributes["href"].text()}".split(';')[0]
    name = journal.text()
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










