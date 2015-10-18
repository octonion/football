#!/usr/bin/env ruby
# coding: utf-8

bad = " "

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base_url = "http://www.sports-reference.com"

url = "http://www.sports-reference.com/cfb/conferences/"

table_xpath = '//table[@class="sortable  stats_table" and not(@data-freeze)]/tbody/tr'

out = CSV.open("csv/conferences.csv", "w", {:col_sep => "\t"})

begin
  page = agent.get(url)
rescue
  retry
end

found = 0
page.parser.xpath(table_xpath).each do |r|

  row = []
  r.xpath("td").each_with_index do |e,i|

    et = e.text
    
    et.gsub!(bad," ") rescue nil
    
    if (et.size==0)
      et = nil
    end
    row += [et]
    
    if (i==1)
      a = e.xpath("a").first
      href = a.attribute("href").to_s
      id = href.split("/")[-1]
      row += [id, base_url+a.attribute("href").to_s]
    end

  end

  if (row.size > 1 and not(row[1]==nil))
    found += 1
    out << row
  end

end

print "Found #{found}\n"
out.close
