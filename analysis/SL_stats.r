#install.packages(c("lme4","lmerTest", "car"))
#install.packages(c("psych"))
#install.packages(c('ggiraph', 'ggiraphExtra', 'plyr'))

library(lme4)
library(lmerTest)
library(lmtest)
library(dplyr)
#require(ggiraph)
#require(ggiraphExtra)
#library(car)

setwd('~/PROJECTS/synch.live/code/DataAnalysis2022/analysis/')

df <- read.csv('GERF_group_player_data.csv')
df$Emerged <- as.factor(df$Emerged)
df <- within(df, Emerged <- relevel(Emerged, ref = '0'))
df <- subset(df, Manual != 1)

################################################################################
# Generic statistics, unrelated to game outcome
summary(df)

summary(lm(WattsSelf   ~ DavisPerspective, data = df)) # p = 0.02141
summary(lm(WattsOthers ~ DavisPerspective, data = df))
summary(lm(WattsWorld  ~ DavisPerspective, data = df))
summary(lm(WattsTotal  ~ DavisPerspective, data = df)) # p = 0.019

df %>% group_by(Group) %>% summarise(count = n())

################################################################################
# analysis of game outcome
win  <- subset(df, Emerged == 1)
lose <- subset(df, Emerged != 1)

# From the output, the p-value > 0.05 implying that the distribution of the data are not significantly different from normal distribution. 
shapiro.test(win$DavisPerspective)
shapiro.test(win$WattsSelf)
shapiro.test(win$WattsOthers) # not normal, p = 0.005149
shapiro.test(win$WattsWorld)  # not normal, p = 0.00368
shapiro.test(win$WattsTotal)

shapiro.test(lose$DavisPerspective)
shapiro.test(lose$WattsSelf)
shapiro.test(lose$WattsOthers)
shapiro.test(lose$WattsWorld)
shapiro.test(lose$WattsTotal) 

# perspective-taking seems Gaussian so can use t-test
t.test(lose$DavisPerspective, win$DavisPerspective, paired = FALSE)

# since win$WattsOthers is significantly non-Gaussian as per Shapiro-Wilk
# t-test assumptions not met, albeit normally SW is not enough to discredit a t-test
t.test(lose$WattsOthers, win$WattsOthers, paired = FALSE)

# t-tests reveal non-significant results, and may not be applicable due to non-normality of some groups
# so we use Mann-Whitney U test (cf. https://www.sheffield.ac.uk/media/30589/download?attachment)
group_by(df, Emerged) %>%
  summarise(
    count = n(),
    mean = mean(WattsOthers, na.rm = TRUE),
    median = median(WattsOthers, na.rm = TRUE),
    sd = sd(WattsOthers, na.rm = TRUE),
    IQR = IQR(WattsOthers, na.rm = TRUE)
  )

wilcox.test(WattsSelf   ~ Emerged, data = df, exact = FALSE)
wilcox.test(WattsOthers ~ Emerged, data = df, exact = FALSE) # p = 0.041
wilcox.test(WattsWorld  ~ Emerged, data = df, exact = FALSE)
wilcox.test(WattsTotal  ~ Emerged, data = df, exact = FALSE)

# tailed test is more significant, but not warranted by study design
wilcox.test(WattsSelf   ~ Emerged, data = df, alternative = "less", exact = FALSE) # p = 0.033
wilcox.test(WattsOthers ~ Emerged, data = df, alternative = "less", exact = FALSE) # p = 0.0205
wilcox.test(WattsWorld  ~ Emerged, data = df, alternative = "less", exact = FALSE) # p = 0.29
wilcox.test(WattsTotal  ~ Emerged, data = df, alternative = "less", exact = FALSE) # p = 0.051

################################################################################
# analysis of winning players

# first demean all data
# seems lm is the same with or without demeaning
win <- subset(df, Emerged == 1)
win$Duration         <- win$Duration         - mean(na.omit(win$Duration))
win$DavisPerspective <- win$DavisPerspective - mean(na.omit(win$DavisPerspective))
win$WattsSelf        <- win$WattsSelf        - mean(na.omit(win$WattsSelf  ))
win$WattsOthers      <- win$WattsOthers      - mean(na.omit(win$WattsOthers))
win$WattsWorld       <- win$WattsWorld       - mean(na.omit(win$WattsWorld ))
win$WattsTotal       <- win$WattsTotal       - mean(na.omit(win$WattsTotal ))

# p-value from anova is the same as summary
summary(lm(WattsSelf   ~ DavisPerspective, data = win))
summary(lm(WattsOthers ~ DavisPerspective, data = win))
summary(lm(WattsWorld  ~ DavisPerspective, data = win)) # p = 0.0387
summary(lm(WattsTotal  ~ DavisPerspective, data = win)) # p = 0.012

summary(lm(WattsSelf   ~ Duration, data = win))
summary(lm(WattsOthers ~ Duration, data = win))
summary(lm(WattsWorld  ~ Duration, data = win))
summary(lm(WattsTotal  ~ Duration, data = win))

# LM: does duration and perspective taking explain variance in connectedness to others?
lm_model <- lm(WattsOthers ~ Duration * DavisPerspective, data = win)
summary(lm_model)
anova(lm_model)

# 3-way interaction plot, use the data that was not demeaned
win0  <- subset(df, Emerged != 0)
lm0 <- lm(WattsOthers ~ DavisPerspective * Duration, data = win0)
ggPredict(lm0, interactive=TRUE)

# LMER: does duration and perspective taking explain variance in connectedness to others?
lmer_model <- lmer(WattsOthers ~ Duration * DavisPerspective + (1|Group), data = win)
summary(lmer_model)
anova(lmer_model)

anova(lmer(WattsSelf   ~ Duration * DavisPerspective + (1|Group), data = win))
anova(lmer(WattsWorld  ~ Duration * DavisPerspective + (1|Group), data = win))
anova(lmer(WattsTotal  ~ Duration * DavisPerspective + (1|Group), data = win))


lmer_model  <- lmer(WattsOthers ~ Duration * DavisPerspective + (1|Group), data = win)
lmer_model2 <- lmer(WattsOthers ~ Duration + (1|Group), data = win)
AIC(lmer_model, lmer_model2)
BIC(lmer_model, lmer_model2)
# perspective taking is making a difference
lrtest(lmer_model, lmer_model2)

lmer_model3  <- lmer(WattsOthers ~ DavisPerspective + (1|Group), data = win)
summary(lmer_model3)
anova(lmer_model3)


################################################################################
# residual analysis for winning players

# preview the residuals
plot(lm_model)
plot(lmer_model)

# compare the two model's residuals
lm_residuals <- lm_model$residuals
hist(lm_residuals)
lmer_residuals <- resid(lmer_model)
hist(lmer_residuals)

# ANOVA on the residuals using group ID
winr <- na.omit(win)
winr$LMRes  <- lm_residuals
winr$LMERes <- lmer_residuals

# check equal variance across groups - ANOVA assumption
bartlett.test(LMRes  ~ Group, data = winr) # p = 0.09 - equal var
bartlett.test(LMERes ~ Group, data = winr) # p = 0.22 - equal var
#LeveneTest(Res ~ Group, data = winr)

model <- aov(LMRes  ~ Group, data = winr)
summary(model) # p = 0.0482

model <- aov(LMERes ~ Group, data = winr)
summary(model) # p = 0.97

################################################################################
# post-hoc analysis
TukeyHSD(model)

# compute group stats
tapply(winr$LMRes, winr$Group, summary)
tapply(winr$LMRes, winr$Group, sd)

# visualise group variance
boxplot(LMRes ~ Group,
        data = winr,
        xlab = "Group",
        ylab = "Residuals from LM")

# group A_1 is an outlier, maybe because of different config of system
df1 <- subset(df, Group != 'A_1')
win1 <- subset(win, Group != 'A_1')

wilcox.test(WattsOthers ~ Emerged, data = df1) # p = 0.04694

summary(lm(WattsTotal  ~ DavisPerspective, data = win1)) # p = 0.029

lm_model <- lm(WattsOthers ~ Duration * DavisPerspective, data = win1)
summary(lm_model)
anova(lm_model)

lmer_model <- lmer(WattsOthers ~ Duration * DavisPerspective + (1|Group), data = win1)
summary(lmer_model)
anova(lmer_model)

# compare the two model's residuals
lm_residuals <- lm_model$residuals
hist(lm_residuals)
lmer_residuals <- resid(lmer_model)
hist(lmer_residuals)

# ANOVA on the residuals using group ID
winr1 <- na.omit(win1)
winr1$Res <- lm_residuals

# check equal variance across groups - not enough evidence of different var
bartlett.test(Res ~ Group, data = winr1) # p = 0.1193

model <- aov(Res ~ Group, data = winr1)
summary(model) # p = 0.0288


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
