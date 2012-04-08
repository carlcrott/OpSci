require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'json'

__FILE__ == $0 ? ( REPO_NAME = __FILE__.split(".")[0] ) : ""

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

  # running w error handling bc its a big ass project
  begin
    # arr = ["Advanced Composite Materials", "http://booksandjournals.brillonline.com/content/15685519"]
    if  arr[1].split('/')[2] == 'booksandjournals.brillonline.com' # standard formatting
      abb = arr[1].split('/')[-1]

      @temp = {
        "url"   => "#{arr[1]}",
        "rss"   => "http://booksandjournals.brillonline.com/rss/content/#{abb}/latest?fmt=rss",
        "index" => "#{arr[1]}"
      }
    else
      puts "BLEEP! BLOOP! I dont know how to build this entry: #{arr}"
    end

    full_array = { "name" => arr[0], "url" => @temp['url'], "rss" => @temp['rss'], "index" => @temp['index'] }
  rescue
    full_array = "ERROR @ #{arr[1]}"    
  end

  
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
  journals = []

#  url_param = ('a'..'z').to_a << 'number'
  url_param = ['a']
  for param in url_param
    puts "getting '#{param}' journals"
    # open the first page of every parameter: ['a'..'z','number']
    page = Mechanize.new.get("http://booksandjournals.brillonline.com/content/all/#{param}?perPage=100")

    p "should find %s journals" % page.search('.publistwrapper').search('p')[0].text().split(' ')[-2]

    # figure out how many iterations are present within the page for that param
    # FIXME: ghetto rigged
    iteration_links = page.search('.paginator').search('a')
    iters = []
    for link in iteration_links
      iters << link.text().to_i # all words will evaluate to 0
    end

    # loop through each iteration
    # Ex: (1..4)
    for param_iter in (1..iters.max)
      page_iteration = Mechanize.new.get("http://booksandjournals.brillonline.com/content/all/#{param}?perPage=100&page=#{param_iter}")
      links = page_iteration.search('.separated-list').search('li').search('h5').search('a')
      for link in links
        journals << [ link.text(), link.attributes['href'].text().split(';')[0] ]
      end
    end
    iters = []
  end

  # after building the list of journals
  # there will be duplicates >> page indexing is buggy
  puts "Initial length of 'journals' var: %s" % journals.length
  journals = journals.uniq
  puts "After journals.uniq %s" % journals.length

  topics_list = []
  for journal in journals 
    name = journal[0]
    # NOTE: each of these pages has a bibtex link
    link = "http://booksandjournals.brillonline.com#{journal[1]}"
    topics_list << [name, link]
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










