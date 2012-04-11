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

  # arr = ["Agricultural and Forest Meteorology", "/wps/product/cws_home/503295", "http://www.sciencedirect.com/science/journal/01681923"]
  if  arr[1].split('/')[5] == 'cws_home'
    abb = arr[2].split('/')[-1]

    temp = {
               # "http://elsevier.com/wps/product/cws_home/717248"
      "url"   => "http://www.elsevier.com#{arr[1]}",
               # "http://feeds.sciencedirect.com/publication/science/1146609X"
      "rss"   => "http://feeds.sciencedirect.com/publication/science/#{abb}",
               # "http://www.sciencedirect.com/science/journal/1146609X"
      "index" => "http://www.sciencedirect.com/science/journal/#{abb}"
    }
  else
    puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
  end

  full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
  p full_array
  return full_array
end








def main()  
  page = Mechanize.new.get 'http://www.elsevier.com/wps/find/subject_area_browse.cws_home?showAll=y&SH1=0&sh1State=-H01-H02-H03-H04-H05-L01-L02-L03-L04-L05-L06-L07-L08-L09-P01-P02-P03-P04-P05-P06-P07-P08-P09-P10-P11-P12-S01-S02-S03-S04-S05-S06-S08&allParents=y'
  
  topics_list = page.search('/html/body/div/div/div[3]/div[2]/table/tr/td[2]/table/tr[2]/td/div/table/tr[2]/td[2]/table/tr[4]/td[2]/table/tr/td/table[2]/tr').search('table/tr/td').search('a')
  journals = []
  for topic in topics_list[0..1]
        # topic = /wps/find/L01_400.cws_home/main
    id = topic.attributes['href'].text().split('/')[-2..-1] # => ["L01","400"]
    sh1, num = id 

         # http://www.elsevier.com/wps/find/subject_journal_browse.cws_home/400?SH1Code=L01&showProducts=Y
    uri = "http://www.elsevier.com/wps/find/subject_journal_browse.cws_home/#{num}?SH1Code=#{sh1}&showProducts=Y"

    puts "getting: #{uri}"
    j = Mechanize.new.get(uri).search('/html/body/div/div/div[3]/div[2]/table/tr/td[2]/table/tr[2]/td/div/table/tr[2]/td[2]/table/tr[4]/td[2]/table/tr[5]/td[2]/table').search('a')
    journals << j
  end

  journals.flatten!

  issue_list = []
  for journal in journals

    name = journal.text()
    link = journal.attributes["href"].text()

        # We get lucky here...
        # It seems that you can search the pages and "Access Full" will get us to the scidirect link 
        # regardless of the page presentation
    uri = "http://www.elsevier.com#{journal.attributes["href"].text()}"
    p "opening URI: #{uri}"
    journal_page = Mechanize.new.get uri

    begin
      index = journal_page.search('//a[contains(text(), "Access Full")]')[0].attributes["href"].text()
    rescue
      puts "\nNO INDEX: #{uri}"
      index = 'idk'
    end

        # some URLs will have this referral link:
        # http://nl.sitestat.com/elsevier/elsevier-com/s?ScienceDirect&ns_type=clickout&ns_url=http://www.sciencedirect.com/science/journal/18752780
    if index[0..22] == 'http://nl.sitestat.com/'
      best_guess_url = index.split('=')[-1]
      if best_guess_url[0..28] == 'http://www.sciencedirect.com/'
        index = best_guess_url
      else
        puts "ERROR with URL #{index}"
      end
    end

    puts "\nMISSING INDEX: #{journal.text()}" unless index.length > 0

#   temp = ["Acta Oecologica", "/wps/product/cws_home/717248", "http://www.sciencedirect.com/science/journal/1146609X"]
    temp = [name, link, index]
    issue_list << temp

    puts "sleeping..."
    sleep(10)
  end

  final = []
  for i in issue_list
#    build_json(t)
    journal_entry = verify_data(build_json(i))
    final << journal_entry

    puts "sleeping..."
    sleep(10)
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








