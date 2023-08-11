
setwd('~/PROJECTS/synch.live/code/DataAnalysis2022/analysis/')

dfmc <- read.csv('GERF_metacog_poster_neutral-to-no.csv')
dfmc <-  dfmc[!(is.na(dfmc$Label) | dfmc$Label==""), ]
dfmc <- subset(dfmc, Manual == 0)

################################################################################
# Metacognition

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

