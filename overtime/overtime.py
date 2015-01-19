#!/usr/bin/env python

# 2014 NFL overtime rule win probability
# Assuming winner of coin flip elects to go first

# Defensive score probabilities

defensive_td = 0.02
safety = 0.001

defensive_score = defensive_td + safety

# Offensive score probabilities

field_goal = 0.118
offensive_td = 0.200

offensive_score = field_goal + offensive_td

# 1st possession no score

no_score_1 = 1.0 - offensive_td - defensive_score

# n > 1 possession no score

no_score = 1.0 - offensive_score - defensive_score

# Winning if you win toss:

# touchdown on 1st possession
# no score on 1st possession, defensive score on 2nd possession
# no score on 1st or 2nd possessions, winn in sudden death state

# win = offensive_td + no_score_1*defensive_score + no_score_1*no_score*sd_win

# Sudden death win probability:

# any offensive score
# no score, any defensive score
# two no scores, back to initial state

# sd_win = offensive_score + no_score*defensive_score + no_score**2*sd_win
# sd_win*(1-no_score**2) = offensive_score + no_score*defensive_score
# sd_win = (offensive_score + no_score*defensive_score)/(1-no_score**2)

sd_win = (offensive_score + no_score*defensive_score)/(1-no_score**2)

print("Sudden death winning probility = {0:.3f}".format(sd_win))

win = offensive_td + no_score_1*defensive_score + no_score_1*no_score*sd_win

print("Overall winning probility = {0:.3f}".format(win))
