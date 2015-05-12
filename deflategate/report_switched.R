
library(lme4)

psi <- read.csv("psi_switched.csv")

model0 <- delta ~ gauge + (1|ball)
model1 <- delta ~ team + gauge + (1|ball)
model2 <- delta ~ team + gauge + team:gauge + (1|ball)

#fit0 <- lmer(model0, data=psi)
#fit0
#summary(fit0)

fit1 <- lmer(model1, data=psi)
fit1
summary(fit1)

#fit2 <- lmer(model2, data=psi)
#fit2
#summary(fit2)

#anova(fit0,fit1)
#anova(fit1,fit2)
