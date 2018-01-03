sbn <- read.csv("sbn.csv")

sbn$p <- sbn$den/(sbn$den+sbn$num)

s <- sum(sbn$p)
sbn$p <- log(sbn$p/s)

model <- p ~ afc + nfc - 1

fit <- lm(model, data=sbn)
fit
summary(fit)

c <- data.frame(exp(coef(fit)))
colnames(c) <- c("exp")

af <- data.frame(1.0)
rownames(af) <- c("nfcAtlanta Falcons")
colnames(af) <- c("exp")

c <- rbind(c,af)

afc <- subset(c,startsWith(row.names(c), "afc"))
nfc <- subset(c,startsWith(row.names(c), "nfc"))

afc$p <- afc$exp/sum(afc$exp)
nfc$p <- nfc$exp/sum(nfc$exp)

afc
nfc
