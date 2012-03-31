require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'json'

REPO_NAME = 'apa_journals'

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


def main()  
  agent = Mechanize.new
  page = agent.get("http://www.apa.org/rss/index.aspx")
  tds = page.search('table').search('td')

  final = []

#http://content.apa.org/journals/amp
#http://content.apa.org/journals/aap
#http://content.apa.org/journals/bne

  for td in tds 
    one = td.search('a')[0]
    two = td.search('a')[1]

    if td.search('a').count == 2 # normally indexed journals
      link = 
      link = "http://www.apa.org#{one.attributes["href"].text()}"
      name = one.text()
      rss = two.attributes["href"].text()
      temp = [
        "url"=> link,
        "rss"=> rss,
        "index"=>"IDK"
      ]
      p temp

      final << {"#{arr[0]}"=>temp}

    temp = [
      "url"=>"#{arr[1]}",
      "rss"=>"IDK",
      "index"=>"IDK"
    ]


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
        if (name != nil) && (link != nil) && (rss != nil)
          temp = [name,link,rss]
          p temp
          final << temp
          # save entry
          link,name,rss,temp = nil,nil,nil,[]
        end
      end
    else
      puts "wtf"
    end 
  end

  for line in final
    raise "\nUNEXPECTED:\nItem 1 should not contain 'http://' or '.rss':\n#{line}" unless ((line[0].include? 'http://') == false) && ((line[0].include? '.rss') == false)
    raise "\nUNEXPECTED:\nItem 2 does not contain 'http://':\n#{line}" unless line[1][0..6] == 'http://'
    raise "\nUNEXPECTED:\nItem 3 does not end in '.rss':\n#{line}" unless line[2][-4..-1] == '.rss'
  end


  puts "VALID JSON? #{final.to_json.valid_json?}"
  output_file = "#{REPO_NAME}_output.json"

  puts "Writing output to file: #{output_file}"
  File.open(output_file,'a').write(final.to_json)

end

main()











