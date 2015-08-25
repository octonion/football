#!/usr/bin/env ruby

require 'csv'

require 'nokogiri'
require 'open-uri'

require 'json'

#http://data.ncaa.com/game/football/fbs/2014/09/06/air-force-wyoming/pbp.json

base_url = "http://data.ncaa.com/game/football/"

ncaa_games = CSV.open("csv/ncaa_team_schedules.csv","r",{:col_sep => "\t", :headers => TRUE})

ncaa_games.each do |game|

  game_id = game["game_id"]

  if (game_id==nil)
    next
  end

  url = base_url+game_id+"/pbp.json"

  print "#{game_id}\n"

  begin
    pbp = open(url,"rb","User-Agent" => "Mozilla 5.0").read
  rescue
    next
  end

  json = JSON.parse(pbp)

  file_name = game_id.gsub("/","-")
  File.open("pbp/#{file_name}.json","w") do |f|
    f.write(json)
  end

end

ncaa_games.close
