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
  if arr[1].include? 'http://'
    @temp = {
      "url"   => "#{arr[1]}",
      "rss"   => "idk",
      "index" => "idk"
    }
  elsif arr[1].include? '/journal/'
    code = arr[1].split("/")[-1] 
    @temp = {
      "url"   => "http://pubs.acs.org/journal/#{code}",
      "rss"   => "http://feeds.feedburner.com/acs/#{code}",
      "index" => "http://pubs.acs.org/loi/#{code}"
    }

  elsif arr[1][0] == '/'
    @temp = {
      "url"   => "http://pubs.acs.org#{arr[1]}",
      "rss"   => "idk",
      "index" => "idk"
    }
  else
    puts "I dont know how to build this entry: #{arr}"
  end

  full_array = {
    "name"   => arr[0],
    "url"    => @temp['url'],
    "rss"    => @temp['rss'],
    "index"  => @temp['index']
  }

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
  agent = Mechanize.new
  page = agent.get("http://pubs.acs.org/")
  topics = page.search('#azView').search('a')

  topics_list = []
  for u in topics 
    link = u.attributes["href"].text()
    name = u.text()
    name != "" ? (topics_list << [name,link]) : ""
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



#verify_data({"name" => "ACS Chemical Biology","url" =>"http://pubs.acs.org/journal/acbcct","rss" =>"http://pubs.acs.org/journal/acbcct","index" =>"http://pubs.acs.org/loi/acbcct"})
#verify_data({"name" => "ACS Chemical Biology","url" =>"http://pubs.acs.org/journal/acbcct","rss" =>"idk","index" =>"http://pubs.acs.org/loi/acbcct"},false)

main()








