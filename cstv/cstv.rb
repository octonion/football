#!/usr/bin/ruby1.9.1

require 'mechanize'
require 'nokogiri'

Mechanize.html_parser = Nokogiri::XML

#base = 'http://livestats.www.cstv.com/livestats/data/m-basebl/'
scoreboard_base ="http://origin.livestats.www.cstv.com/scoreboards/20090905-m-footbl-scoreb.xml"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

games = 0

scoreboard_url = "#{scoreboard_base}"
begin
  page = agent.get(scoreboard_url)
rescue
  p "retry"
  retry
end

doc = Nokogiri::HTML(page.body)

doc.xpath("//scoreboard/event/@event_id").each do |id|
  event_id = id.value

  url = "http://origin.livestats.www.cstv.com/livestats/data/m-footbl/#{event_id}/play_by_play.xml"

  begin
    page = agent.get(url)
  rescue
    p "retry"
    retry
  end

  file_name = "XML/#{event_id}_event.xml"

  p file_name

  File.open(file_name,"w") do |output|
      output << page.body
  end

end
