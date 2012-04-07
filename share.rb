require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'spreadsheet'
require 'json'

__FILE__ == $0 ? ( REPO_NAME = __FILE__.split(".")[0] ) : ""

def google_search(query)
  agent = Mechanize.new

  agent.get('http://google.com/') do |page|
    search_result = page.form_with(:name => 'f') do |search|
      search.q = "#{query}"
    end.submit
    return search_result
  end
end

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

class Publisher
  attr_accessor :name, :url, :index

  def initialize(name, url, index)
    @name = name
    @url = url
    @index = index
  end

  def meta
    ['url'=> @url, 'index'=> @index].to_json
  end

  def hash
    @hash = "\"#{@name.chomp}\":#{meta}"
  end

end


journals = [
  'american association for the advancement of science',
  'american chemical society',
  'royal chemical society',
  'amerian geophysial union',
  'american institute of physics',
  'american psychological association',
  'annual reviews',
  'association for computing machinery',
  'association for symbolic logic',
  'begell house',
  'bentham science',
  'berghahn books',
  'biomed central',
  'bmj group',
  'brill publishers',
  'british ecological soiety',
  'cambridge university press',
  'cell press',
  'cold spring harbor laboratory',
  'siro publishing',
  'edinburgh university press',
  'edp sciences',
  'elsevier',
  'europena mathematical society',
  'harvard university',
  'hindawi publishing',
  'ieee',
  'indiana university press',
  'informa',
  'informs',
  'international press',
  'iop publishing',
  'ios press',
  'japan society of applied physics',
  'john benjamins',
  'john wiley & sons',
  'johns hopkins university press',
  'karger',
  'landes bioscience',
  'lippincott williams & wilkins',
  'maney publishing',
  'mary ann liebert',
  'mathematical sciences publishers',
  'medknow publications',
  'mit press',
  'multidisciplinary digital publishing institute',
  'national research university higher school of economics',
  'nature publishing group',
  'nauka',
  'nrc research press',
  'optical society of america',
  'oxford university press',
  'penn state university press',
  'philosophy documentation center',
  'polish academy of sciences',
  'royal society of chemistry',
  'sage',
  'siam',
#  'SociÃ©tÃ© MathÃ©matique de France',
  'springer',
  'taylor & francis',
  'thieme',
  'Universitetsforlaget',
  'university of california press',
  'university of chicago press',
  'university of illinois press',
  'walter de gruyter',
  'wiley-blackwell',
  'wiley-liss',
  'wolters kluwer',
  'world scientific'
]



final = []

for journal in journals
  final << Thread.new(journal) { |i|

      puts "fetching: %s" % i

    begin
      page = google_search("#{i}")
      puts "resolved: %s" % i

      journal_url = page.search('#ires').search('li')[0].search('h3').search('a')[0].attributes['href'].text().split('&')[0].split('=')[1]

      first_link = page.search('#ires').at_xpath('ol/li[@class="g"]/div')

      @publisher = Publisher.new(row, journal_url, 'checking.com') 
      puts ("#{@publisher.hash}")
      return "#{@publisher.hash}"
  #    return first_link.to_s

    rescue LocalJumpError
      return "LJE"
    rescue
      return "narf"

    end
  }
end

p final.each { |f| f.join }
