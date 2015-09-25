#!/usr/bin/env ruby

require 'csv'

require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

players_xpath = '//*[@id="stat_grid"]/tbody/tr'

#teams_xpath = '//*[@id="stat_grid"]/tfoot/tr[position()>1]'
teams_xpath = '//*[@id="stat_grid"]/tfoot/tr'

base_sleep = 0
sleep_increment = 3
retries = 4

year = ARGV[0].to_i
division = ARGV[1]

#offset = 10761-10820
offset = 0

yscs = [
  [10820,'rushing'],
  [10821,'passing'],
  [10822,'receiving'],
  [10823,'total_offense'],
  [10824,'all-purpose_yards'],
  [10825,'scoring'],
  [10826,'sacks'],
  [10827,'tackles'],
  [10828,'passes_defended'],
  [10829,'fumbles'],
  [10830,'kicking'],
  [10831,'punting'],
  [10832,'punt_returns'],
  [10833,'kickoffs_and_ko_returns'],
  [10834,'redzone'],
  [10835,'defense'],
  [10836,'turnover_margin'],
  [10837,'participation']
]

#http://stats.ncaa.org/team/roster/11540?org_id=2

# Headers for files

#ncaa_player_summaries << []

#ncaa_team_summaries << []

# Base URL for relative team links

base_url = 'http://stats.ncaa.org'

sleep_time = base_sleep

yscs.each do |ysc|

  ysc_id = ysc[0]+offset
  ysc_type = ysc[1]

  ncaa_player_summaries = CSV.open(
    "tsv/ncaa_player_summaries_#{ysc_type}_#{year}_#{division}.tsv",
    "w",
    {:col_sep => "\t"})
  
  ncaa_team_summaries = CSV.open(
    "tsv/ncaa_team_summaries_#{ysc_type}_#{year}_#{division}.tsv",
    "w",
    {:col_sep => "\t"})

  ncaa_teams = CSV.open("tsv/ncaa_teams_#{year}_#{division}.tsv",
                        "r",
                        {:col_sep => "\t", :headers => TRUE})
  
  ncaa_teams.each do |team|

    year = team[1]
    year_id = team[2]
    team_id = team[4]
    team_name = team[5]

    stat_url = "http://stats.ncaa.org/team/stats/#{year_id}?org_id=#{team_id}&year_stat_category_id=#{ysc_id}"

    #http://stats.ncaa.org/team/stats/12240?org_id=519&year_stat_category_id=10820

    #print "Sleep #{sleep_time} ... "
    sleep sleep_time

    found_players = 0
    missing_id = 0

    tries = 0
    begin
      doc = agent.get(stat_url)
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

    print "#{year} #{team_name} ..."

    doc.search(players_xpath).each do |player|

      row = [year, year_id, team_id, team_name]
      player.search("td").each_with_index do |element,i|
        case i
        when 1
          player_name = element.text.strip

          link = element.search("a").first
          if (link==nil)
            missing_id += 1
            link_url = nil
            player_id = nil
            player_url = nil
          else
            link_url = link.attributes["href"].text
            parameters = link_url.split("/")[-1]

            # player_id

            player_id = parameters.split("=")[2]

            # opponent URL

            player_url = base_url+link_url
          end

          found_players += 1
          row += [player_id, player_name, player_url]
        else
          field_string = element.text.strip

          row += [field_string]
        end
      end

      ncaa_player_summaries << row
    
    end

    print " #{found_players} players, #{missing_id} missing ID"

    found_summaries = 0
    doc.search(teams_xpath).each do |team|

      row = [year, year_id, team_id, team_name]
      team.search("td").each_with_index do |element,i|
        field_string = element.text.strip
        row += [field_string]
      end

      found_summaries += 1
      ncaa_team_summaries << row
    
    end

    print ", #{found_summaries} team summaries\n"

  end

  ncaa_teams.close

  ncaa_player_summaries.close
  ncaa_team_summaries.close

end
