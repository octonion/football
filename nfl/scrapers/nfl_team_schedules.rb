#!/usr/bin/ruby

require 'csv'

require 'nokogiri'
require 'open-uri'

base_sleep = 0
sleep_increment = 3
retries = 4

#http://www.nfl.com/liveupdate/game-center/2013090500/2013090500_gtd.json
#http://www.nfl.com/scores/2013/REG1

base_url = "http://www.nfl.com"

year = ARGV[0].to_i

if (year<2001)
  exit
end

standings = CSV.open("tsv/nfl_team_standings_#{year}.tsv",
                     "r",
                     {:col_sep => "\t", :headers => TRUE})

schedules = CSV.open("tsv/nfl_team_schedules_#{year}.tsv",
                     "w",
                     {:col_sep => "\t"})

# Header for team schedules

header = ["season", "team_id", "week", "date",
          "away_team_id", "away_team_url", "away_team_score",
          "home_team_id", "home_team_url", "home_team_score",
          "game_status", "game_url", "attendance", "top_passer",
          "top_passer_url", "top_passer_text", "top_rusher",
          "top_rusher_url", "top_rusher_text", "top_receiver",
          "top_receiver_url", "top_receiver_text"]

schedules << header

#Wk	Date	Game	Time (ET)	Attendance	Top Passer	Top Rusher	Top Receiver

schedules_url = "http://www.nfl.com/teams/"

schedules_xpath = '//table[@class="data-table1"]/tr[position()>2]'

standings.each do |team_season|

  team_id = team_season["team_id"]
  year = team_season["season"].to_i
#  if (year<2001)
#    next
#  end
  sleep_time = base_sleep

  url = schedules_url+"schedule?team=#{team_id}&season=#{year}&seasonType=REG"

  #print "Sleep #{sleep_time} ... "
  sleep sleep_time

  tries = 0
  begin
    doc = Nokogiri::HTML(open(url))
  rescue
    sleep_time += sleep_increment
    print "sleep #{sleep_time} ... "
    sleep sleep_time
    tries += 1
    if (tries > retries)
      next
    else
      retry
    end
  end

  sleep_time = base_sleep

  #  print "#{year} #{team_name} ..."

  doc.xpath(schedules_xpath).each do |game|

    row = [year,team_id]
    game.xpath("td").each_with_index do |field,j|
      # See String#encode
      text = field.text.strip rescue nil
      case j
      when 2
        values = field.xpath("a").flat_map do |node|
           [(node.text.strip rescue nil),
            (base_url+node.attributes["href"].text rescue nil),
            (node.next_sibling.text.gsub("@","").strip rescue nil)]
#          [(n.previous_sibling.text.strip rescue nil),
        end
        row += values
      when 3
        values = field.xpath("a").flat_map do |node|
           [(node.text.strip rescue nil),
            (base_url+node.attributes["href"].text rescue nil)]
#          [(n.previous_sibling.text.strip rescue nil),

        end
        row += values
      when 5..7
        values = field.xpath("a").flat_map do |node|
           [(node.text.strip rescue nil),
            (base_url+node.attributes["href"].text rescue nil),nil]
#            (node.next_sibling.next_sibling.text.strip rescue nil)]
#          [(n.previous_sibling.text.strip rescue nil),
        end
        row += values
      else
        row += [text]
      end

    end

    schedules << row

  end

end
