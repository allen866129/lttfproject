#encoding: UTF-8”
require "json"
file = File.read(Rails.root.join('public','information','TWzipcode.json'))
TWZipCode_hash = JSON.parse(file)
