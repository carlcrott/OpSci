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

  # arr = ["African Journal of International and Comparative Law", "http://www.euppublishing.com/journal/ajicl"]
  begin
    if  arr[1].split('/')[-2] == 'journal'
      abb = arr[1].split('/')[-1]

      temp = {
        "url"   => "#{arr[1]}",
        "rss"   => "http://www.euppublishing.com/action/showFeed?jc=#{abb}&type=etoc&feed=rss",
        "index" => "http://www.euppublishing.com/loi/#{abb}"
      }
    else
      puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
    end

    full_array = { "name" => arr[0], "url" => temp['url'], "rss" => temp['rss'], "index" => temp['index'] }
  rescue
    puts "BUSTED: #{arr}"
    full_array = ""
  end

  return full_array
end








def main()
  puts "Maxes out @ 25 sessions created in 5 minutes"
# http://www.euppublishing.com/action/showPublications?display=bySubject&pubType=journal 
# http://www.euppublishing.com/action/showPublications?activeId=&pubType=journal&category=&alphabetRange=&display=bySubject&startPage=1&pageSize=20&sortBy=
# http://www.euppublishing.com/action/showPublications?activeId=&pubType=journal&category=&alphabetRange=&display=bySubject&startPage=2&pageSize=20&sortBy= 
  page = Mechanize.new.get 'http://www.euppublishing.com/action/showPublications?activeId=&pubType=journal&category=&alphabetRange=&display=bySubject&startPage=2&pageSize=20&sortBy='
  journals = page.search('.subjectTitleListing/ul.titleListing').search('li').search('a')

  # has weird js journal browser ... so I'm ran each page individually and built this:

  topics_list = [
    ["African Journal of International and Comparative Law", "http://www.euppublishing.com/journal/ajicl"],
    ["Architectural Heritage", "http://www.euppublishing.com/journal/arch"],
    ["Archives of Natural History", "http://www.euppublishing.com/journal/anh"],
    ["Ben Jonson Journal", "http://www.euppublishing.com/journal/bjj"],
    ["Britain and the World", "http://www.euppublishing.com/journal/brw"],
    ["British Scholar", "http://www.euppublishing.com/journal/brs"],
    ["Comparative Critical Studies", "http://www.euppublishing.com/journal/ccs"],
    ["Corpora", "http://www.euppublishing.com/journal/cor"],
    ["Cultural History", "http://www.euppublishing.com/journal/cult"],
    ["Dance Research", "http://www.euppublishing.com/journal/drs"],
    ["Deleuze Studies", "http://www.euppublishing.com/journal/dls"],
    ["Derrida Today", "http://www.euppublishing.com/journal/drt"],
    ["Edinburgh Law Review", "http://www.euppublishing.com/journal/elr"],
    ["Glasgow Archaeological Journal", "http://www.euppublishing.com/journal/gas"],
    ["History and Computing", "http://www.euppublishing.com/journal/hac"],
    ["Holy Land Studies", "http://www.euppublishing.com/journal/hls"],
    ["Innes Review", "http://www.euppublishing.com/journal/inr"],
    ["International Journal of Humanities and Arts Computing", "http://www.euppublishing.com/journal/ijhac"],
    ["International Research in Children's Literature", "http://www.euppublishing.com/journal/ircl"],
    ["Irish University Review", "http://www.euppublishing.com/journal/iur"],
    ["Journal of Beckett Studies", "http://www.euppublishing.com/journal/jobs"],
    ["Journal of British Cinema and Television", "http://www.euppublishing.com/journal/jbctv"],
    ["Journal of International Political Theory", "http://www.euppublishing.com/journal/jipt"],
    ["Journal of Qur'anic Studies", "http://www.euppublishing.com/journal/jqs"],
    ["Journal of Scottish Historical Studies", "http://www.euppublishing.com/journal/jshs"],
    ["Journal of Scottish Philosophy", "http://www.euppublishing.com/journal/jsp"],
    ["Journal of the Society for the Bibliography of Natural History", "http://www.euppublishing.com/journal/jsbnh"],
    ["Katherine Mansfield Studies", "http://www.euppublishing.com/journal/kms"],
    ["Modernist Cultures", "http://www.euppublishing.com/journal/mod"],
    ["New Soundtrack", "http://www.euppublishing.com/journal/sound"],
    ["Northern Scotland", "http://www.euppublishing.com/journal/nor"],
    ["Nottingham French Studies", "http://www.euppublishing.com/journal/nfs"],
    ["Oxford Literary Review", "http://www.euppublishing.com/journal/olr"],
    ["Paragraph", "http://www.euppublishing.com/journal/para"],
    ["Psychoanalysis and History", "http://www.euppublishing.com/journal/pah"],
    ["Romanticism", "http://www.euppublishing.com/journal/rom"],
    ["Scottish Archaeological Journal", "http://www.euppublishing.com/journal/saj"],
    ["Scottish Economic & Social History", "http://www.euppublishing.com/journal/sesh"],
    ["Scottish Historical Review", "http://www.euppublishing.com/journal/shr"],
    ["Somatechnics", "http://www.euppublishing.com/journal/soma"],
    ["Studies in World Christianity", "http://www.euppublishing.com/journal/swc"],
    ["Translation and Literature", "http://www.euppublishing.com/journal/tal"],
    ["Victoriographies", "http://www.euppublishing.com/journal/vic"],
    ["Word Structure", "http://www.euppublishing.com/journal/word"],
  ]


  for journal in journals 
#    p [journal[0], journal[1]]
    topics_list << [journal[0], journal[1]]
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










