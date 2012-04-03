require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'json'

REPO_NAME = __FILE__.split(".")[0]

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
  full_array = []
  if  arr[1][0..33] == 'http://journals.berghahnbooks.com/' # regular internal link
    abb = arr[1].split('/')[-1]
    @temp = {
      "url"   => "#{arr[1]}",
      "rss"   => "http://api.ingentaconnect.com/content/berghahn/#{abb}/latest?format=rss",
      "index" => "http://berghahn.publisher.ingentaconnect.com/content/berghahn/#{abb}"
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => @temp['url'], "rss" => @temp['rss'], "index" => @temp['index'] }
  return full_array
end






def verify_data(entry, v = true)
  begin ###### Verify url
     open(entry['url']).is_a? Tempfile
  rescue
    puts "ERROR: Expecting '#{entry['url']}' to parse open-uri" unless entry['index'] == 'idk'
  end

  begin ###### Verify rss
    Mechanize.new.get(entry['rss']).content.class.is_a? Nokogiri::XML::Document
  rescue
    if entry['rss'] != 'idk' 
      puts "ERROR: Expecting '#{entry['rss']}' to parse as Mechanize::File class"
      entry['rss'] = 'idk'
    end
  end

  begin ###### Verify index 
    page = Mechanize.new.get(entry['index'])
    url_tests = []
    (2008..2012).map {|x| x="[text()*='#{x}']"; url_tests << page.search(x).count}
    raise "" unless url_tests.any? != 0
  rescue
    entry['index'] == 'idk' ? "": (puts "ERROR: Expecting '#{entry['index']}' to contain strings '2008..2012'")
  end

  v ? (puts "VERIFIED: #{entry}") : ""
  return entry
end







def main()  
  page = Mechanize.new.get('http://www.biomedcentral.com/journals')
#  journals = page.search('#leftDiv').xpath('/ul').count
  journals = page.search('h3')
  p journals.count

  topics_list = []
  for journal in journals 
    link = journal.attributes["href"].text()
    p link
    name = journal.text()
    name != "" ? (topics_list << [name,link]) : ""
  end

#  final = []
#  for t in topics_list
#    build_json(t)
#    journal_entry = verify_data(build_json(t))
#    final << journal_entry
#  end

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








