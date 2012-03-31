require 'open-uri'
require 'nokogiri'
require 'mechanize'

def download_citations(journal_topic, pull_url)
  agent = Mechanize.new
  page = agent.get(pull_url)
  form = page.form_with(:action => %r{/action/downloadCitation})

  prefix = "annualreviews_#{journal_topic}"
  Dir.chdir './citations_repo/'

  if File.directory?(journal_topic) == false
    puts "creating directory #{journal_topic}"
    Dir.mkdir(journal_topic)
  end
  
  Dir.chdir journal_topic

  ### Directory Layout
  #  - annual reviews
  #    - journal_topic ( matsci, economics )
  #      - journal volume ( volume 1, volume 2 )
  #        - citation_w_refs
  #        - citation_w_abstract


  form.radiobuttons_with(:name => 'include')[1].check
  puts "references checked? #{ form.radiobuttons_with(:name => 'include')[1].checked? }"
  form.radiobuttons_with(:name => 'format')[2].check
  puts "bibtex checked? #{ form.radiobuttons_with(:name => 'format')[2].checked? }"
  references = agent.submit(form)

  ref_filename = "#{prefix}_citation_refs.bib"
  puts "writing #{ref_filename}"
  references.save_as ref_filename



  form.radiobuttons_with(:name => 'include')[2].check
  puts "references checked? #{ form.radiobuttons_with(:name => 'include')[1].checked? }"
  form.radiobuttons_with(:name => 'format')[2].check
  puts "bibtex checked? #{ form.radiobuttons_with(:name => 'format')[2].checked? }"
  abstract = agent.submit(form)

  abstract_filename = "#{prefix}_citation_abstract.bib"
  puts "writing #{ref_filename}"
  abstract.save_as abstract_filename

end





def get_volume_citations(journal_topic, vol_url)
  agent = Mechanize.new
  page = agent.get(vol_url)

  pull_url_root = 'http://www.annualreviews.org/action/showCitFormats?'

  links = page.search('h2').search('a')

  dois = []
  for i in links
    dois << i.attributes["href"].text()
  end

  formatted_dois = []

  # /doi/abs/10.1146/annurev-matsci-062910-100359 >> doi=10.1146/annurev-matsci-062910-100453&
  for item in dois
    raise "Unexpected URL formating" unless item[0..8] == '/doi/abs/'

    temp = item[9..-1]  # 10.1146/annurev-matsci-062910-100359\
    formatted_dois << "doi=#{temp}&"
  end
  pull_url = "#{pull_url_root}#{formatted_dois.join()}"
  topic = journal_topic

  download_citations(topic, pull_url)
end

#get_volume_citations("matsci", "http://www.annualreviews.org/toc/matsci/41/1")










# this gets the corresponding URLs for each volume of a particular journal
def get_journal_volumes(all_topics)
  agent = Mechanize.new

  root_url = 'http://www.annualreviews.org/loi/'
  
  for t in all_topics
    individual_journal_url = "#{root_url}#{t}/"
    page = agent.get(individual_journal_url)

    links =  page.search(".listOfIssues").search('a')

    volume_urls = []
    for i in links
      volume_urls << "#{url}#{i.attributes["href"].text()}"
    end 

    raise "Unexpected formatting in journal topic URL: #{url}" unless url.split('/').count == 5
    journal_topic = url.split('/')[-1]

    for vol in volume_urls
      p vol
  #    get_volume_citations(journal_topic, vol)
    end

  end

end

#get_journal_volumes('http://www.annualreviews.org/loi/matsci')




def get_AR_topics()  
  agent = Mechanize.new
  page = agent.get("http://www.annualreviews.org/")

  topics = page.search('.mainNavJournalList').search('a')

  topics_list = []
  for u in topics
    raise "Expecting URL format: '/journal/ecolsys' " unless u.index('/journal/').nil?
    partial = u.attributes["href"].text().split("/")
    if partial[1] == 'journal' 
      topics_list << partial[2]
    end
  end
  get_journal_volumes(topics_list)
end

get_AR_topics()



#p page.inputs


#form = page.forms

#p agent.page.links_with(:text => 'News')[1]#.click
#agent.page.checkbox_with(:id => 'selectAllCB').check

#checkbox = agent.page.search("#selectAllCB")#.click

#checkbox.checkbox_with(:id => 'selectAllCB').check
#form = page.forms.detect { |f| f.checkbox_with(:id => "selectAllCB" )}
#p agent.page.checkboxes
#.checkbox_with('rem').check

#p checkbox.class



# select list http://rubyforge.org/pipermail/mechanize-users/2010-May/000567.html

#form.checkbox_with('rem').check

#drop_down = page.class('viewSel')

#p drop_down

dois=[]

#page.search("//a").each do |ahref| 
#  url=ahref.attributes["href"].text()
#  if url.include? "doi/abs" 
#    dois << url.split("/doi/abs/")[1].split("?")[0] 
#  end
#end



#p dois





















