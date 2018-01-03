sbn <- read.csv("sbn.csv")

sbn$p <- sbn$den/(sbn$den+sbn$num)

vig <- sum(sbn$p)

afc_teams <- unique(sbn$afc)
nfc_teams <- unique(sbn$nfc)

af <- data.frame()
for (team in afc_teams) {
    v <- data.frame(team,"afc",sum(sbn$p[sbn$afc==team])/vig)
    print(v)
    af <- rbind(af,v)
}
colnames(af) <- c("team","conf","p")

nf <- data.frame()
for (team in nfc_teams) {
    v <- data.frame(team,"nfc",sum(sbn$p[sbn$nfc==team])/vig)
    print(v)
    nf <- rbind(nf,v)
}
colnames(nf) <- c("team","conf","p")

af
sum(af$p)
nf
sum(nf$p)

