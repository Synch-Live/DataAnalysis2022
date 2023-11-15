
setwd('~/PROJECTS/synch.live/code/DataAnalysis2022/analysis/')


################################################################################
# Metacognition

dfmc <- read.csv('GERF_metacog_labelled.csv')
dfmc <-  dfmc[!(is.na(dfmc$Label) | dfmc$Label==""), ]
dfmc <- subset(dfmc, Manual == 0)

# chi-squared test
plt_df <- table (dfmc$Label, dfmc$Emerged)
plt_df
barplot(plt_df, legend.text = TRUE,
        beside = TRUE,
        col  = c('#E6AA15','#3d8af9'),
        xlab = "Were you aware\n your strategy worked?",
        ylab = "Number of players",
        args.legend=list(x='top', title = "Emerged")
)
chisq.test(plt_df, correct = FALSE)


# per-group test
dfmcg <- read.csv('GERF_metacog_groups.csv')
dfmcg <- subset(dfmcg, Manual == 0)
wilcox.test(Aware ~ Emerged, data = dfmcg)
wilcox.test(Aware_ratio ~ Emerged, data = dfmcg)




################################################################################
# 3 labels - yes, no, neutral - not used
dfmc <- read.csv('GERF_metacog_3labels.csv')
dfmc <-  dfmc[!(is.na(dfmc$Label) | dfmc$Label==""), ]
dfmc <- subset(dfmc, Manual != 1)

plt_df <- table (dfmc$Label, dfmc$Emerged)
plt_df
barplot(plt_df, legend.text = TRUE,
        beside = TRUE,
        col  = c('#1930B0','#E6AA15','#3d8af9'),
        xlab = "Emerged?",
        ylab = "Number of players",
        args.legend=list(x='top', title = 'Were you aware your strategy works?')
)
chisq.test(plt_df, correct = TRUE)

