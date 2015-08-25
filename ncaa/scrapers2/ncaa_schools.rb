#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

url = "http://web1.ncaa.org/stats/StatsSrv/careersearch"

results = CSV.open("tsv/ncaa_schools.tsv", "w",
                   {:col_sep => "\t"})

begin
  page = agent.get(url)
rescue
  print "  -> error, retrying\n"
  retry
end

path="//select[@name='searchOrg']/option[position()>1]"

page.parser.xpath(path).each do |option|
  school_id = option.attributes["value"].value
  school_name = option.inner_text
  results << [school_id,school_name]
  results.flush
end

results.close
