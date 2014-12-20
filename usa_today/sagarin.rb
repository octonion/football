#!/usr/bin/env ruby

require 'csv'

require 'nokogiri'
require 'open-uri'

path = '//article[@id="sagarin"]/div/pre[2]'

sagarin = CSV.open("sagarin.csv","w",{:col_sep => "\t"})

sagarin_url = "http://www.usatoday.com/sports/ncaaf/sagarin/"

doc = Nokogiri::HTML(open(sagarin_url))

article = doc.xpath(path).first

raw = article.to_s.split("<br>")
raw = raw[5..-1]
lines = []
raw.each_with_index do |r,i|
  raw[i] = Nokogiri::HTML(raw[i]).text
  raw[i] = raw[i].gsub('&nbsp',' ')
  if !([10,11,12].include?(i%13))
    lines << raw[i]
  end
end

puts lines
