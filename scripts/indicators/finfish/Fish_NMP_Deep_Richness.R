setwd("~/projects/data-pipelines/scripts/indicators/finfish")
#source("~/projects/data-pipelines/setup/ckan.R")
library(ggplot2)
library(plyr)
library(gridExtra)
library(reshape)

#Load CSV

dat <- read.csv("NMP_BRUV_Deep_All Data.csv")

#Check column names

colnames (dat)

#Limit to those columns that are important for this analysis

dat.ab <- subset(dat, select=c("Year", "Zone", "Site", "Period", "Genus.Species", "Family", "MaxN"))
dat.ab$MaxN <- as.character(dat.ab$MaxN)
dat.ab$MaxN <- as.integer(dat.ab$MaxN)

#Remove any 'NA' values from dataset

dat.ab <- dat.ab[!is.na(dat.ab$Period),]
dat.ab = droplevels(dat.ab)

#Remove cryptic families from dataset

#dat.ab.filter <- subset(dat.ab, Family != c("Apogonidae", "Blennidae", "Gobiidae"))
#dat.ab.filter2 <- subset(dat.ab.filter, Family != c("Holocentridae", "Pempheridae", "Pseudochromidae"))
#dat.ab.filter3 <- subset(dat.ab.filter2, Family != c("Pempherididae"))
#dat.ab.filter4 <- subset(dat.ab.filter3, Family != c("Plotosidae"))

#Sum abundance values for individual species within site and period

dat.ab.total <- ddply(dat.ab, .(Year, Zone, Site, Period, Genus.Species), summarise,
                      total = sum(MaxN))

#Remove 0 values and sum unique Genus.species names to provide a Species Richness score for every transect

dat.ab.removezero <- subset(dat.ab.total, total > 0)
dat.ab.richness <- ddply(dat.ab.removezero, .(Year, Zone, Site, Period), summarise,
                         richness = length(unique(Genus.Species)))

#Obtain mean and SE values for species Richness at zone level

RichnessNMP <- ddply(dat.ab.richness, .(Year, Zone), summarise,
                     N    = length(richness),
                     mean = mean(richness),
                     sd   = sd(richness),
                     se   = sd(richness) / sqrt(length(richness)) )

#Create figure for all NMP

pd <- position_dodge(0.25)
limits <- aes(ymax = mean + se, ymin = mean - se)
RichnessNMPFig <- ggplot(RichnessNMP, aes(x=Year, y=mean, group=Zone, linetype=Zone, shape=Zone)) +
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.25, position=pd) + # error bars
  #geom_line(position=pd) +                      # line
  geom_point(position=pd, size=4) +             # points
  #stat_smooth(method = "lm", colour = "black", se = FALSE) +
  xlab("Survey Year") +
  ylab(expression(paste("Species Richness per BRUV drop +/- SE", sep = ""))) +
  scale_x_continuous(limits=c(min(RichnessNMP$Year-0.25),max(RichnessNMP$Year+0.25)), breaks=min(RichnessNMP$Year):max(RichnessNMP$Year)) +
  theme_bw() +
  theme(axis.text=element_text(size=14),                  #rotates the x axis tick labels an angle of 45 degrees
        axis.text.x=element_text(angle=45, vjust=0.4),
        axis.title.x=element_text(size=16,face="bold", vjust=-1),                #removes x axis title
        axis.title.y=element_text(size=16,face="bold"),               #removes y axis title
        axis.line=element_line(colour="black"),   #sets axis lines
        panel.grid.minor=element_blank(),          #removes minor grid lines
        panel.grid.major=element_blank(),          #removes major grid lines
        panel.border=element_blank(),                #removes border
        panel.background=element_blank(),            #needed to ensure integrity of axis lines
        plot.title=element_text(hjust=1,size=14,face="bold"),
        #legend.position="none",
        legend.justification=c(1,1), legend.position=c(0.8,1), # Positions legend (x,y) in this case removes it from the graph
        legend.title=element_blank(),
        legend.key=element_blank(),
        legend.text=element_text(size=18),
        legend.background=element_rect(size=0.5, linetype="solid", colour="black"))

png(filename = "Richness_DeepNMP.png",
    width = 600, height = 400, units = "px", pointsize = 6)
RichnessNMPFig
dev.off()
