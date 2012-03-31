require 'json'

file = File.open('carls_store.json','r').read

p JSON.parse(file)



