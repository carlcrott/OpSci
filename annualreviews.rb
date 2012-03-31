require 'open-uri'
require 'nokogiri'
require 'mechanize'

REPO_NAME = 'annualreviews'

# Example
# save_citations('matsci','http://www.annualreviews.org/action/showCitFormats?doi=10.1146/annurev-ecolsys-102710-145042&doi=10.1146/annurev-ecolsys-102710-145039&doi=10.1146/annurev-ecolsys-102209-144653&doi=10.1146/annurev-ecolsys-102710-145024&doi=10.1146/annurev-ecolsys-102710-145017&doi=10.1146/annurev-ecolsys-102710-145028&doi=10.1146/annurev-ecolsys-102710-145057&doi=10.1146/annurev-ecolsys-102710-145055&doi=10.1146/annurev-ecolsys-102209-144647&doi=10.1146/annurev-ecolsys-102710-145001&doi=10.1146/annurev-ecolsys-102710-145051&doi=10.1146/annurev-ecolsys-102710-145119&doi=10.1146/annurev-ecolsys-102209-144704&doi=10.1146/annurev-ecolsys-102710-145006&doi=10.1146/annurev-ecolsys-102710-145015&doi=10.1146/annurev-ecolsys-102710-145100&doi=10.1146/annurev-ecolsys-032511-142302&doi=10.1146/annurev-ecolsys-102209-144702&doi=10.1146/annurev-ecolsys-102209-144726&doi=10.1146/annurev-ecolsys-102209-144710&doi=10.1146/annurev-ecolsys-102710-145115&doi=10.1146/annurev-ecolsys-102710-145034&')

def save_citations(file_prefix, fugly_url)
  agent = Mechanize.new
  page = agent.get(fugly_url)
  form = page.form_with(:action => %r{/action/downloadCitation})

  ### Directory Layout
  # - citations_repo
  #   - annualreviews
  #     - journal_topic ( matsci, economics )
  #       "matsci_vol_42-1_refs"
  #       "matsci_vol_42-1_abstracts"

  Dir.chdir "/home/thrive/rails_projects/ml-repo/citations_repo/#{REPO_NAME}/"

  dir = file_prefix.split('_')[0]

  ## Directory checking
  if File.directory?(dir) == false
    puts "creating new directory #{dir}"
    Dir.mkdir(dir)
  end
  
  Dir.chdir dir

  ref_name = "#{file_prefix}_refs.bib"
  abs_name = "#{file_prefix}_abstracts.bib"


  if File.exist?(ref_name) == false
    form.radiobuttons[1].check
    form.radiobuttons[5].check

    references = agent.submit(form)

    puts "writing #{ref_name}"
    references.save_as ref_name
  else
    puts "#{ref_name} already exists"
  end


  if File.exist?(abs_name) == false
    form.radiobuttons[2].check
    form.radiobuttons[5].check

    abstract = agent.submit(form)

    puts "writing #{abs_name}"
    abstract.save_as abs_name
  else
    puts "#{abs_name} already exists"
  end

end

#save_citations('matsci_vol_5-1','http://www.annualreviews.org/action/showCitFormats?doi=10.1146/annurev-ecolsys-102710-145042&doi=10.1146/annurev-ecolsys-102710-145039&')


# Typical call looks like:
# build_fugly_url("matsci_vol_15-1")
def build_fugly_url(file_prefix)
  agent = Mechanize.new
  info = file_prefix.split('_')

  # build the URL from file prefix
  vol_url = "http://www.annualreviews.org/toc/#{info[0]}/#{info[2].split('-').join('/')}"
  page = agent.get(vol_url)
  
  # links on the page contain all the doi identifiers
  links = page.search('h2').search('a')

  dois = []
  for i in links
#    p i.attributes["href"].text()
    dois << i.attributes["href"].text()
  end

  formatted_dois = []

  # /doi/abs/10.1146/annurev-matsci-062910-100359 >> doi=10.1146/annurev-matsci-062910-100453&
  for item in dois
    test = item.split('/')
    raise "Unexpected URL formating:\n#{item}" unless ( test.count == 5 )

    temp = item[9..-1]  # 10.1146/annurev-matsci-062910-100359\
    formatted_dois << "doi=#{temp}&"
  end
  fugly_url = "http://www.annualreviews.org/action/showCitFormats?#{formatted_dois.join()}"

  save_citations(file_prefix, fugly_url)
end

# working
#build_fugly_url("matsci_vol_5-1")









# Gets the URLs for each journal-volume
# Also sends the file names to build
def get_journal_volumes(all_topics)
  agent = Mechanize.new

  root_url = 'http://www.annualreviews.org/loi'
  
  for t in all_topics
    individual_journal_url = "#{root_url}/#{t}/"
    puts "#### gathering volumes from journal: #{t} @ #{individual_journal_url} ####"
    page = agent.get(individual_journal_url)

    links =  page.search(".listOfIssues").search('a')

    volume_urls = []
    for i in links
      individual_volume_url = "#{root_url}#{i.attributes["href"].text()}"
      puts "adding volume url to cue: #{individual_volume_url}"
      volume_urls << individual_volume_url
    end 


    for vol in volume_urls
      file_prefix = "#{t}_vol_#{vol.split('/')[-2..-1].join('-')}"

    # should be formatted as
    # build_fugly_url("anthro", "http://www.annualreviews.org/loi/toc/anthro/3/1")
      build_fugly_url(file_prefix)



      # Delay to prevent IP ban
      # client IP is blocked because: More than 100 sessions created in 5 minutes Blocked IPs: 067.171.066.113 - 067.171.066.113

      # 100 sessions / 300 sec >> 
      # 1 session / 3 seconds == ban rate
      
      for i in 0..3 do p i; sleep(1) end  #timer

    end

  end
end

#get_journal_volumes(['arplant'])




def main()  
  agent = Mechanize.new
  page = agent.get("http://www.annualreviews.org/")

  topics = page.search('.mainNavJournalList').search('a')

  topics_list = []
  for u in topics 
    partial = u.attributes["href"].text().split("/")
    if partial[1] == 'journal' && partial.length == 3
      topics_list << partial[2]
    else
      # its not a journal
    end
  end

  Dir.chdir "/home/thrive/rails_projects/ml-repo/citations_repo/#{REPO_NAME}/"
  existing_dirs = Dir.glob("*/").map{|x| x.sub("/","")}
  
  parse_list = []
  puts "###################### located these journals: ######################"
  for t in topics_list do
    if existing_dirs.include?(t) == false
      parse_list << t
    end
  end
  puts "#####################################################################"

  p parse_list

  get_journal_volumes(parse_list)
end

main()












