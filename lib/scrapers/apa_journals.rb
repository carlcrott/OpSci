require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'json'
require './skraper_addons.rb'

__FILE__ == $0 ? ( REPO_NAME = __FILE__.split(".")[0] ) : ""

class String
  include JsonMethods
end






def main()  
  agent = Mechanize.new
  page = agent.get("http://www.apa.org/rss/index.aspx")
  tds = page.search('table').search('td')

  topics_list = []

  for td in tds 
    one = td.search('a')[0]
    two = td.search('a')[1]

    if td.search('a').count == 2 # normally indexed journals
      link = "http://www.apa.org#{one.attributes["href"].text()}"
      name = one.text()
      rss = two.attributes["href"].text()
      abbrev = rss.split("/")[-1][0..2]
      

      temp = {
        "url"=> link,
        "rss"=> rss,
        "index"=>"http://content.apa.org/journals/#{abbrev}"
      }

      puts temp

      topics_list <<  { 
        "name" => name, 
        "url" => temp['url'], 
        "rss" => temp['rss'], 
        "index" => temp['index'] 
      }




    elsif td.search('a').count > 2 # has extra blank tags 
      link,name,rss,temp = nil,nil,nil,[] # wipe everything to start

      for i in td.search('a')

        # within every td element is contained a full entry
        # links will be either rss or http/html
        # there will be bad links ( filter them out with below )
        next unless (i.text() != "") # skips empty links

        # on every loop it will find either:
        # an RSS feed
        if i.attributes["href"].text()[-4..-1] == '.rss'
          rss = i.attributes["href"].text()
          abbrev = rss.split("/")[-1][0..2]
        end
        # OR
        # a link
        if i.attributes["href"].text()[0] == '/' #treat as internal
          link = "http://www.apa.org#{i.attributes["href"].text()}"
          name = i.text()
        elsif i.attributes["href"].text()[0..10] == 'http://www.' #treat as external
          link = i.attributes["href"].text()
          name = i.text()
        end

      

        # once every item is accounted for, export it and clear for the next
#        unless [name, link, rss].any?(&:nil?)
        if (name != nil) && (link != nil) && (rss != nil)
          temp = {
            "url"=> link,
            "rss"=> rss,
            "index"=>"http://content.apa.org/journals/#{abbrev}"
          }

          topics_list <<  { 
            "name" => name, 
            "url" => temp['url'], 
            "rss" => temp['rss'], 
            "index" => temp['index'] 
          }
          # save entry
          link,name,rss,temp = nil,nil,nil,[]
        end
      end



    else
      puts "wtf"
    end 
  end

  final = []

  for t in topics_list
#    build_json(t)
    journal_entry = verify_data(t)
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











