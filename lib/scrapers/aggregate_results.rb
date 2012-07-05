require 'json'
require 'spreadsheet'
require 'csv'

input_read = File.open("mol_bio_journals_list.txt",'r').read().split("\n")

puts input_read.length

journals_list = []
for item in input_read
  if item[0..12] == "JournalTitle:"

    journals_list << item[14..-1]

  end
end


# open all files with _output.json

basedir = "."
contents = Dir.new(basedir).entries

json_files = []
for file in contents
  if file[-12..-1] == '_output.json'
    json_files << file
  end
end



for json in json_files
  handle = File.open(json,'r').read()
  begin
    json_info = JSON.parse(handle)
    puts json_info
  rescue
    puts "cant parse: #{json}"
  end
end






#{"name"=>"Journal of Women’s Health Physical Therapy", "url"=>"http://journals.lww.com/jwhpt/pages/default.aspx", "rss"=>"idk", "index"=>"http://journals.lww.com/jwhpt/pages/issuelist.aspx"}
CSV.open("temp.csv", "w") do |csv|
  csv << ["name", "url", "rss", "index"]

  for json in json_files
    handle = File.open(json,'r').read()
    begin
      json_info = JSON.parse(handle)
      for j in json_info
        csv << [ j["name"], j["url"], j["rss"], j["index"] ]
      end
    rescue
      puts "cant parse: #{json}"
    end
  end


end




