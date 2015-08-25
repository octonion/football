#!/usr/bin/env ruby

require 'csv'

require 'nokogiri'
require 'open-uri'

require 'json'

names = Hash.new()
names["recap"] = "recap"
names["boxscore"] = "boxscore"
names["scoring-summary"] = "scoring_summary"
names["team-stats"] = "team_stats"
names["play-by-play"] = "pbp"

#http://data.ncaa.com/game/football/fbs/2014/09/06/air-force-wyoming/pbp.json

base_url = "http://data.ncaa.com/game/football"

ncaa_games = CSV.open("tsv/ncaa_team_schedules.tsv","r",{:col_sep => "\t", :headers => TRUE})

ncaa_games.each do |game|

  game_id = game["game_id"]

  if (game_id==nil)
    next
  end

  url = base_url+"/"+game_id+"/tabs.json"

  print "#{game_id}\n"

  begin
    doc = open(url,"rb","User-Agent" => "Mozilla 5.0").read
  rescue
    next
  end

  json = JSON.parse(doc)

  json.each do |line|
    type = line["type"]
    title = line["title"]
    url = base_url+line["file"]
    name = names[type]
    p [game_id, type, title, url]
  end

#  file_name = game_id.gsub("/","-")
#  File.open("pbp/#{file_name}_tabs.json","w") do |f|
#    f.write(json)
#  end

end

ncaa_games.close
