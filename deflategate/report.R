
library(lme4)

psi <- read.csv("psi.csv")

model0 <- delta ~ gauge + team:gauge + (1|ball)
model <- delta ~ team + gauge + team:gauge + (1|ball)

fit0 <- lmer(model0, data=psi)
fit0
summary(fit0)

fit <- lmer(model, data=psi)
fit
summary(fit)

anova(fit0,fit)
