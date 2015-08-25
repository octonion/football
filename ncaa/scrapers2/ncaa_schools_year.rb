#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

# Base URL for relative school links

base_url = 'http://stats.ncaa.org'

divisions = [11, 12, 2, 3]

# Header for school file

schools_header = ["year", "year_id", "division_id", "school_id",
                  "school_name", "school_url"]

first_year = ARGV[0].to_i
last_year = ARGV[1].to_i

(first_year..last_year).each do |year|

  ncaa_schools = CSV.open("tsv/ncaa_schools_#{year}.tsv", "w",
                          {:col_sep => "\t"})

  ncaa_schools << schools_header

  found_schools = 0

  divisions.each do |division|

    year_division_url = "http://stats.ncaa.org/team/inst_team_list?sport_code=MFB&academic_year=#{year}&division=#{division}&conf_id=-1&schedule_date="

    valid_url_substring = "team/index/" ##{year_id}?org_id="

    print "\nRetrieving division #{division} schools for #{year} ... "

    doc = agent.get(year_division_url)

    doc.search("a").each do |link|

      link_url = link.attributes["href"].text

      # Valid school URLs

      if (link_url).include?(valid_url_substring)

        # NCAA year_id

        parameters = link_url.split("/")[-1]
        year_id = parameters.split("?")[0]

        # NCAA school_id

        school_id = parameters.split("=")[1]

        # NCAA school name

        school_name = link.text()

        # NCAA school URL

        school_url = base_url+link_url

        ncaa_schools << [year, year_id, division, school_id, school_name,
                         school_url]
        found_schools += 1

      end

      ncaa_schools.flush

    end

  end

  ncaa_schools.close

  print "\n\nfound #{found_schools} schools for #{year}\n\n"

end


