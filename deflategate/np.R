
library(lme4)

psi <- read.csv("psi.csv")

patriots <- subset(psi, team=="Patriots")
colts <- subset(psi, team=="Colts")
colts$delta <- colts$delta - 0.50

psi <- rbind(patriots, colts)

wilcox.test(delta ~ team, data=psi) 
