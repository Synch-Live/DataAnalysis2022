#install.packages(c("lme4","lmerTest"))
#install.packages(c("ggplot2", "ggpubr", "tidyverse", "broom", "AICcmodavg"))
library(lme4)
library(lmerTest)
#library(ggplot2)
#library(ggpubr)

setwd('~/PROJECTS/synch.live/code/DataAnalysis2022/analysis/')

df <- read.csv('GERF_group_player_data.csv')
df$Manual  <- as.factor(df$Manual)
df$Emerged <- as.factor(df$Emerged)
df$Outcome <- as.factor(df$Outcome)
df <- within(df, Manual  <- relevel(Manual,  ref = '0'))
df <- within(df, Emerged <- relevel(Emerged, ref = '0'))
df <- within(df, Outcome <- relevel(Outcome, ref = '0'))

summary(df)

# Generic statistics, unrelated to game outcome
summary(lm(WattsSelf   ~ DavisPerspective, data = df))
summary(lm(WattsOthers ~ DavisPerspective, data = df))
summary(lm(WattsWorld  ~ DavisPerspective, data = df))
summary(lm(WattsTotal  ~ DavisPerspective, data = df))

# Does the game outcome predict a difference in psychometrics?
t.test(WattsSelf        ~ Emerged, data = df)
t.test(WattsOthers      ~ Emerged, data = df)
t.test(WattsWorld       ~ Emerged, data = df)
t.test(WattsTotal       ~ Emerged, data = df)
t.test(DavisPerspective ~ Emerged, data = df)
# none are significant

df_no_manual  <- subset(df, Manual != 1)
df_no_emerged <- subset(df, Emerged != 1)
df_no_losing  <- subset(df, Emerged == 1 | Manual == 1)

# When excluding groups rewarded without winning, effect of game outcome
t.test(WattsSelf        ~ Emerged, data = df_no_manual) # p = 0.08
t.test(WattsOthers      ~ Emerged, data = df_no_manual)
t.test(WattsWorld       ~ Emerged, data = df_no_manual)
t.test(WattsTotal       ~ Emerged, data = df_no_manual) # p = 0.07
t.test(DavisPerspective ~ Emerged, data = df_no_manual)

# When excluding groups with a positive game outcome, effect of perceived game outcome
t.test(WattsSelf        ~ Manual, data = df_no_emerged)
t.test(WattsOthers      ~ Manual, data = df_no_emerged)
t.test(WattsWorld       ~ Manual, data = df_no_emerged)
t.test(WattsTotal       ~ Manual, data = df_no_emerged)
t.test(DavisPerspective ~ Manual, data = df_no_emerged)

# When excluding groups with a negative game outcome, effect of perceived game outcome
t.test(WattsSelf        ~ Emerged, data = df_no_losing)
t.test(WattsOthers      ~ Emerged, data = df_no_losing)
t.test(WattsWorld       ~ Emerged, data = df_no_losing)
t.test(WattsTotal       ~ Emerged, data = df_no_losing)
t.test(DavisPerspective ~ Emerged, data = df_no_losing)

# Try as ANOVA using outcome factor to capture the three possible outcomes
# No emergence:    0 <- Emerged=0 & Manual=0 
# False emergence: 1 <- Emerged=0 & Manual=1
# True emergence:  2 <- Emerged=1

summary(aov(WattsSelf         ~ Outcome, data = df))
summary(aov(WattsOthers       ~ Outcome, data = df))
summary(aov(WattsWorld        ~ Outcome, data = df))
summary(aov(WattsTotal        ~ Outcome, data = df))
summary(aov(DavisPerspective  ~ Outcome, data = df))
# all non-significant

# two-way ANOVA with duration
summary(aov(WattsSelf         ~ Outcome + Duration, data = df))
summary(aov(WattsOthers       ~ Outcome + Duration, data = df))
summary(aov(WattsWorld        ~ Outcome + Duration, data = df)) # p = 0.024
summary(aov(WattsTotal        ~ Outcome + Duration, data = df))
summary(aov(DavisPerspective  ~ Outcome + Duration, data = df))
# interactions
summary(aov(WattsOthers       ~ Outcome * Duration, data = df)) # p = 0.049
summary(aov(WattsTotal        ~ Outcome * Duration, data = df)) # p = 0.032
summary(aov(DavisPerspective  ~ Outcome * Duration, data = df))

# two-way ANOVA with empathy
summary(aov(WattsSelf   ~ Outcome + DavisPerspective, data = df)) # p = 0.062
summary(aov(WattsOthers ~ Outcome + DavisPerspective, data = df))
summary(aov(WattsWorld  ~ Outcome + DavisPerspective, data = df))
summary(aov(WattsTotal  ~ Outcome + DavisPerspective, data = df)) # p = 0.047
# interactions
summary(aov(WattsSelf   ~ Outcome * DavisPerspective, data = df)) # p = 0.062
summary(aov(WattsOthers ~ Outcome * DavisPerspective, data = df))
summary(aov(WattsWorld  ~ Outcome * DavisPerspective, data = df))
summary(aov(WattsTotal  ~ Outcome * DavisPerspective, data = df)) # p = 0.047

# two-way ANOVA with both
summary(aov(WattsSelf   ~ Outcome + Duration + DavisPerspective, data = df)) # p = 0.062
summary(aov(WattsOthers ~ Outcome + Duration + DavisPerspective, data = df))
summary(aov(WattsWorld  ~ Outcome + Duration + DavisPerspective, data = df))
summary(aov(WattsTotal  ~ Outcome + Duration + DavisPerspective, data = df)) # p = 0.047
# interactions
summary(aov(WattsSelf   ~ Outcome * Duration * DavisPerspective, data = df)) # p = 0.062
summary(aov(WattsOthers ~ Outcome * Duration * DavisPerspective, data = df))
summary(aov(WattsWorld  ~ Outcome * Duration * DavisPerspective, data = df))
summary(aov(WattsTotal  ~ Outcome * Duration * DavisPerspective, data = df)) # p = 0.047

# linear model with multiple predictors
# surprisingly WattsOthers has no significant predictors in any of the vars
summary(lm(WattsSelf   ~ Emerged + Manual + DavisPerspective + Duration, data = df))
summary(lm(WattsOthers ~ Emerged + Manual + DavisPerspective + Duration, data = df))
summary(lm(WattsWorld  ~ Emerged + Manual + DavisPerspective + Duration, data = df))
summary(lm(WattsTotal  ~ Emerged + Manual + DavisPerspective + Duration, data = df))

summary(lm(WattsSelf   ~ Outcome + DavisPerspective + Duration, data = df))
summary(lm(WattsOthers ~ Outcome + DavisPerspective + Duration, data = df))
summary(lm(WattsWorld  ~ Outcome + DavisPerspective + Duration, data = df))
summary(lm(WattsTotal  ~ Outcome + DavisPerspective + Duration, data = df))


# For studies of movement in conjuncture with questionnaires, must remove error games
df <- na.omit(df)

summary(lm(WattsSelf   ~ Psi_max, data = df))
summary(lm(WattsOthers ~ Psi_max, data = df))
summary(lm(WattsWorld  ~ Psi_max, data = df))
summary(lm(WattsTotal  ~ Psi_max, data = df))

summary(lm(WattsSelf   ~ Psi_min, data = df))
summary(lm(WattsOthers ~ Psi_min, data = df))
summary(lm(WattsWorld  ~ Psi_min, data = df))
summary(lm(WattsTotal  ~ Psi_min, data = df))

summary(lm(WattsSelf   ~ Psi_avg, data = df))
summary(lm(WattsOthers ~ Psi_avg, data = df))
summary(lm(WattsWorld  ~ Psi_avg, data = df))
summary(lm(WattsTotal  ~ Psi_avg, data = df))

summary(lm(WattsSelf   ~ Psi_var, data = df))
summary(lm(WattsOthers ~ Psi_var, data = df))
summary(lm(WattsWorld  ~ Psi_var, data = df))
summary(lm(WattsTotal  ~ Psi_var, data = df))
# none significant

# LMEs for each segment
# probably statistically unsound
df <- read.csv('GERF_group_player_segment_data.csv')
df$Manual  <- as.factor(df$Manual)
df$Emerged <- as.factor(df$Emerged)
df$Outcome <- as.factor(df$Outcome)

summary(lmer(mean_psi     ~ 1 + Outcome + (1|Segment), data = df)) 
summary(lmer(mean_psi     ~ 1 + Emerged + (1|Segment), data = df)) 

summary(lmer(vicsek_order ~ 1 + Outcome + (1|Segment), data = df)) 
summary(lmer(vicsek_order ~ 1 + Emerged + (1|Segment), data = df)) 


# LMEs for beauty!
df <- read.csv('GERF_beauty_segment_data.csv')

summary(df)

# all significant
summary(lmer(mean_psi          ~ 1 + mean_beauty + (1|Segment), data = df)) 
summary(lmer(vicsek_order      ~ 1 + mean_beauty + (1|Segment), data = df)) 
summary(lmer(err_vicsek_order  ~ 1 + mean_beauty + (1|Segment), data = df)) 

summary(lmer(var_angle         ~ 1 + mean_beauty + (1|Segment), data = df)) 

summary(lmer(mean_psi          ~ 1 + std_beauty + (1|Segment), data = df)) 
summary(lmer(vicsek_order      ~ 1 + std_beauty + (1|Segment), data = df)) 

# non-significant
summary(lmer(std_psi           ~ 1 + mean_beauty + (1|Segment), data = df))  # very significant intercept?
summary(lmer(mean_dist_cmass   ~ 1 + mean_beauty + (1|Segment), data = df)) 
summary(lmer(mean_dist_nearest ~ 1 + mean_beauty + (1|Segment), data = df)) 

summary(lmer(err_mean_dist_cmass   ~ 1 + mean_beauty + (1|Segment), data = df))
summary(lmer(err_mean_dist_nearest ~ 1 + mean_beauty + (1|Segment), data = df)) 
summary(lmer(err_var_angle         ~ 1 + mean_beauty + (1|Segment), data = df)) # very significant intercept?

# beauty as target
summary(lmer(mean_beauty ~ 1 + mean_psi + std_psi + 
               vicsek_order + err_vicsek_order +
               var_angle + err_var_angle +
               mean_dist_cmass + err_mean_dist_cmass +
               mean_dist_nearest + err_mean_dist_nearest +
               (1|Segment), data = df)) 

summary(lmer(mean_beauty ~ 1 + mean_psi +
               err_vicsek_order +
               mean_dist_cmass + err_mean_dist_cmass +
               mean_dist_nearest + err_mean_dist_nearest +
               (1|Segment), data = df)) 
