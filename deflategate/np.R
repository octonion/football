
library(lme4)

psi <- read.csv("psi.csv")

patriots <- subset(psi, team=="Patriots")
colts <- subset(psi, team=="Colts")

# Colts at 13.0 PSI

wilcox.test(delta ~ team, data=psi)

# Colts at 13.25 PSI

colts$delta <- colts$delta - 0.25
psi <- rbind(patriots, colts)
wilcox.test(delta ~ team, data=psi)

# Colts at 13.35 PSI

colts$delta <- colts$delta - 0.10
psi <- rbind(patriots, colts)
wilcox.test(delta ~ team, data=psi)

# Colts at 13.50 PSI

colts$delta <- colts$delta - 0.25
psi <- rbind(patriots, colts)
wilcox.test(delta ~ team, data=psi) 
