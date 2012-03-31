require 'json'

file1 = File.open('main_output.json','r').read #input
f1 = JSON.parse(file1)

file2 = File.open('carls_store.json','r').read #pull from
f2 = JSON.parse(file2)

file3 = File.open('out.json','a') #pull from

puts f1[0]

puts f2["american association for the advancement of science"].count
puts f2["american association for the advancement of science"][0]["sub_journals"][0].count


for i in f1
  name = [i][0]["name"]
  p f2[name][0]["sub_journals"][0].count
end


#p f2["american chemical soiety"][0]["sub_journals"][0].count # => 68



