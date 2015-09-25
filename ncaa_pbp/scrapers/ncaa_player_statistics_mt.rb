#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

class String
  def to_nil
    self.empty? ? nil : self
  end
end

base_url = 'http://stats.ncaa.org'

box_scores_xpath = '//*[@id="contentArea"]/table[position()>4]/tr[position()>2]'

nthreads = 1

base_sleep = 0
sleep_increment = 3
retries = 4

ncaa_teams = CSV.open("tsv/ncaa_teams.tsv","r",{:col_sep => "\t", :headers => TRUE})

teams = []
ncaa_teams.each do |team|
    teams << team
end

n = teams.size
gpt = (n.to_f/nthreads.to_f).ceil

first_year = 2014
last_year = 2015

(first_year..last_year).each do |year|

  ncaa_player_statistics = CSV.open("tsv/ncaa_player_statistics_#{year}.tsv","w",{:col_sep => "\t"})

  #header = []

  #ncaa_player_statistics << header

  threads = []

  teams.each_slice(gpt).with_index do |teams_slice,i|

    threads << Thread.new(teams_slice) do |t_teams|

      agent = Mechanize.new{ |agent| agent.history.max_size=0 }

      agent.user_agent = 'Mozilla/5.0'

      # Needed for referer

      url = "http://web1.ncaa.org/stats/StatsSrv/careerteam"
      agent.get(url)

      found = 0
      n_t = t_teams.size

      t_teams.each_with_index do |team,j|

        team_id = team[2]
        team_name = team[3]
        print "#{i}:#{j}/#{n_t} - #{year}/#{team_name}\n"

        begin
          page = agent.post(url, {
                              "academicYear" => "#{year}",
                              "orgId" => team_id,
                              "sportCode" => "MFB",
                              "sortOn" => "0",
                              "doWhat" => "display",
                              "playerId" => "-100",
                              "coachId" => "-100",
                              "division" => "1",
                              "idx" => ""
                            })
        rescue
          print "  -> error, retrying\n"
          retry
        end

        page.parser.xpath("//table[5]/tr").each do |row|
          if (row.path =~ /\/tr\[[123]\]\z/)
            next
          end
          r = [team_name,team_id,year]
          row.xpath("td").each_with_index do |d,i|

            text = d.text.strip rescue nil
            if (text=="-")
              text = ""
            end

            text = text.to_nil rescue nil
            
            if (i==0) then
              id = d.inner_html.strip[/(\d+)/].to_i
              r += [text,id]
            else
              r += [text]
            end
          end
          if not(r[3]==nil)
            ncaa_player_statistics << r
          end
          #ncaa_player_statistics.flush
        end
      end

    end

  end

  threads.each(&:join)
  ncaa_player_statistics.close
end
