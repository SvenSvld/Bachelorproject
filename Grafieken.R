#Libraries aanzetten
library(ggplot2)
library(dplyr)


#Waargenomen bedreiging op kans steun rechtspopulistische partij
threat <- seq(from = 0, to = 10, by = 0.1)
log_odds <- c(-4.775650+(0.622924*threat))
odds <- exp(log_odds)
kans.rechtspopulistisch <- (odds/(1+odds))

grafiek.data <- data.frame(threat,log_odds,odds,
                      kans.rechtspopulistisch)
View(grafiek.data)

kansverdeling <- ggplot(grafiek.data, aes(x=threat, y=kans.rechtspopulistisch)) + 
  geom_smooth(method = "glm",
              method.args = list(family = "binomial"),
              se = FALSE) +
  theme(axis.title.y = element_blank()) +
  theme(axis.title.x = element_blank()) + 
  theme_bw() +
  labs(x = "Waargenomen bedreiging",
       y = "Kans op steun voor rechtspopulistische partij")
plot(kansverdeling) 

#MIPEX op kans steun rechtspopulistische partij
MIPEX <- seq(from = 0, to = 100, by = 0.1)
log_odds2 <- c(1.600329+(-0.024606*MIPEX))
odds2 <- exp(log_odds2)
kans.rechtspopulistisch2 <- (odds2/(1+odds2))

grafiek.data2 <- data.frame(MIPEX,log_odds2,odds2,
                           kans.rechtspopulistisch2)
View(grafiek.data2)

kansverdeling2 <- ggplot(grafiek.data2, aes(x=MIPEX, y=kans.rechtspopulistisch2)) + 
  geom_smooth(method = "glm",
              method.args = list(family = "binomial"),
              se = FALSE) +
  theme(axis.title.y = element_blank()) +
  theme(axis.title.x = element_blank()) + 
  theme_bw() +
  labs(x = "MIPEX",
       y = "Kans op steun voor rechtspopulistische partij")
plot(kansverdeling2) 


#Exporteren grafieken
library(ggpubr)
png(filename = "Threat.png")
plot(kansverdeling)
dev.off()

png(filename = "MIPEX.png")
plot(kansverdeling2)
dev.off()
