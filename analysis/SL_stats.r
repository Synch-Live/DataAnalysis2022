#install.packages(c("lme4","lmerTest"))
#install.packages(c("ggplot", "sjPlot"))
#install.packages(c("psych"))
library(lme4)
library(lmerTest)
library(psych)
library(dplyr)

setwd('~/PROJECTS/synch.live/code/DataAnalysis2022/analysis/')

df <- read.csv('GERF_group_player_data.csv')
df$Emerged <- as.factor(df$Emerged)
df <- within(df, Emerged <- relevel(Emerged, ref = '0'))
df<- subset(df, Manual != 1)

################################################################################
# Generic statistics, unrelated to game outcome
summary(lm(WattsSelf   ~ DavisPerspective, data = df))
summary(lm(WattsOthers ~ DavisPerspective, data = df))
summary(lm(WattsWorld  ~ DavisPerspective, data = df))
summary(lm(WattsTotal  ~ DavisPerspective, data = df))


################################################################################
# analysis of game outcome
win  <- subset(df, Emerged == 1)
lose <- subset(df, Emerged != 1)

t.test(lose$WattsOthers, win$WattsOthers, paired = FALSE)

# t-tests reveal non-significant results, and may not be applicable, 
# so we use Mann-Whitney U test (cf. https://www.sheffield.ac.uk/media/30589/download?attachment)
wilcox.test(WattsSelf   ~ Emerged, data = df)
wilcox.test(WattsOthers ~ Emerged, data = df) # p = 0.041
wilcox.test(WattsWorld  ~ Emerged, data = df)
wilcox.test(WattsTotal  ~ Emerged, data = df)

wilcox.test(DavisPerspective  ~ Emerged, data = df)


################################################################################
# analysis of winning players

# first demean all data
win  <- subset(df, Emerged != 0)
win$Duration         <- win$Duration         - mean(na.omit(win$Duration))
win$DavisPerspective <- win$DavisPerspective - mean(na.omit(win$DavisPerspective))
win$WattsSelf        <- win$WattsSelf        - mean(na.omit(win$WattsSelf  ))
win$WattsOthers      <- win$WattsOthers      - mean(na.omit(win$WattsOthers))
win$WattsWorld       <- win$WattsWorld       - mean(na.omit(win$WattsWorld ))
win$WattsTotal       <- win$WattsTotal       - mean(na.omit(win$WattsTotal ))

# p-value from anova is the same as summary
summary(lm(WattsSelf   ~ DavisPerspective, data = win))
summary(lm(WattsOthers ~ DavisPerspective, data = win))
summary(lm(WattsWorld  ~ DavisPerspective, data = win))
summary(lm(WattsTotal  ~ DavisPerspective, data = win))

# does duration and perspective taking explain variance in connectedness to others?
model <- lm(WattsOthers ~ Duration * DavisPerspective, data = win)
summary(model)
anova(model)


################################################################################
# analysis of psi

df <- read.csv('GERF_group_player_psi_data.csv')
df <- subset(df, Manual != 1)
df$Emerged <- as.factor(df$Emerged)

# For studies of movement in conjuncture with questionnaires, must remove error games
df <- na.omit(df)

anova(lm(WattsTotal ~ Psi_max, data = df)) # p = 0.0329
anova(lm(WattsTotal ~ Psi_min, data = df))
anova(lm(WattsTotal ~ Psi_avg, data = df))
anova(lm(WattsTotal ~ Psi_std, data = df))

anova(lm(DavisPerspective ~ Psi_max, data = df))
anova(lm(DavisPerspective ~ Psi_min, data = df))
anova(lm(DavisPerspective ~ Psi_avg, data = df))
anova(lm(DavisPerspective ~ Psi_std, data = df))

# ANOVA for each segment
df <- read.csv('GERF_beauty_segment_data.csv')
df <- subset(df, Manual != 1)
df$Emerged <- as.factor(df$Emerged)
df <- within(df, Emerged <- relevel(Emerged, ref = '0'))

summary(lm(mean_psi              ~ Emerged, data = df))  # p < 0.0001
summary(lm(std_psi               ~ Emerged, data = df))  # negative p < 0.0001
summary(lm(vicsek_order          ~ Emerged, data = df))  # negative p < 0.0001
summary(lm(var_angle             ~ Emerged, data = df))
summary(lm(mean_dist_cmass       ~ Emerged, data = df))  # negative p = 0.001
summary(lm(mean_dist_nearest     ~ Emerged, data = df))  # negative p = 0.001
summary(lm(err_mean_dist_nearest ~ Emerged, data = df))  # negative p = 0.002


summary(lm(mean_beauty ~ mean_psi             , data = df))  # p < 0.0001
summary(lm(mean_beauty ~ std_psi              , data = df))
summary(lm(mean_beauty ~ vicsek_order         , data = df))  # negative p < 0.0001
summary(lm(mean_beauty ~ std_vicsek_order     , data = df))  # negative p < 0.0001
summary(lm(mean_beauty ~ var_angle            , data = df))  # p = 0.04
summary(lm(mean_beauty ~ std_var_angle        , data = df))
summary(lm(mean_beauty ~ mean_dist_cmass      , data = df))
summary(lm(mean_beauty ~ std_mean_dist_cmass  , data = df))  # negative p = 0.0002
summary(lm(mean_beauty ~ mean_dist_nearest    , data = df))  # negative p = 0.001
summary(lm(mean_beauty ~ std_mean_dist_nearest, data = df))  # negative p = 0.0004

anova(lmer(mean_beauty ~ 1 + mean_psi + std_psi + 
               vicsek_order + std_vicsek_order +
               var_angle + std_var_angle +
               mean_dist_cmass + std_mean_dist_cmass +
               mean_dist_nearest + std_mean_dist_nearest +
               (1|Group), data = df)) 
