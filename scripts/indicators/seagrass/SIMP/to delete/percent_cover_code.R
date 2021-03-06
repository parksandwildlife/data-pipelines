setwd("~/projects/data-pipelines/scripts/indicators/seagrass/SIMP")
source("~/projects/data-pipelines/setup/ckan.R")
source("~/projects/data-pipelines/scripts/ckan_secret.R")

library(ggplot2)
#install.packages("gridExtra")
library(gridExtra)
library(plyr)

csv_rid <- "b0b546ed-ab74-4592-8429-7175cd637de4"
pdf_rid <- "95c93dc8-2eba-4bd7-9f79-14d474085300"
txt_rid <- "1c0627b7-72d0-40a4-b11b-3f6a7a41c0a7"
pdf_fn = "final.pdf"

d <- load_ckan_csv(csv_rid, date_colnames = c('date', 'Date'))

pd <- position_dodge(0.1)
graphics = theme(axis.text.x=element_text(angle=45, hjust=0.9), #rotates the x axis tick labels an angle of 45 degrees
                 axis.title.x=element_text(), #removes x axis title
                 axis.title.y=element_text(), #removes y axis title
                 axis.line=element_line(colour="black"), #sets axis lines 
                 plot.title =element_text(hjust = 0.05),
                 panel.grid.minor = element_blank(), #removes minor grid lines
                 panel.grid.major = element_blank(), #removes major grid lines
                 panel.border=element_blank(), #removes border
                 panel.background=element_blank(), #needed to ensure integrity of axis lines
                 legend.justification=c(10,10), legend.position=c(10,10), # Positions legend (x,y) in this case removes it from the graph
                 legend.title = element_text(),
                 legend.key = element_blank()
)

##################################################################################
#Percent cover calculations for all data

cover=count(d, c("Sector", "Zone", "Site", "Year", "Level5Class")) #counts number of observations per site, per year
cover_obs=count(cover, c("Site", "Year"), "freq") #counts number of observations made at each site per year
cover_add <- join(cover, cover_obs, by = c("Site", "Year")) #adds total count of site observations agains the right site/year to allow percentage calculation
pos_cover = subset(cover_add, Level5Class %in% c("Posidonia sinuosa","Posidonia australis")) #Extracts cover information only
pos_total = count(pos_cover, c("Sector","Zone", "Site", "Year", "freq.1"), "freq")
names(pos_total)[5] <- "total_count" #Rename column to make more sense
names(pos_total)[6] <- "pos_count" #Rename column to make more sense
pos_total$percent = pos_total$pos_count/pos_total$total_count *100 #Calculate percent cover

##################################################################################
#Shoalwater_south percent cover

#Creates a data frame summarised for the sites included. Repeat for each 'sector' or reporting area     
SIMP_s = subset(pos_total, Site %in% c("Becher Point", "Becher Point SZ", "Port Kennedy")) 

d_sum <- plyr::ddply(SIMP_s, .(Year, Zone), summarise,
                     N    = length(!is.na(percent)),
                     mean = mean(percent, na.rm=TRUE),
                     sd   = sd(percent, na.rm=TRUE),
                     se   = sd(percent, na.rm=TRUE) / sqrt(length(!is.na(percent)) ))

SIMP_s_plot <- ggplot(d_sum, aes(x=Year, y=mean, group=Zone, linetype=Zone, shape=Zone)) +
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.02, colour="black", position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, fill="black") + # 21 is filled circle
  scale_x_continuous(limits=c(min(d_sum$Year-0.125), max(d_sum$Year+0.125)), breaks=min(d_sum$Year):max(d_sum$Year)) +
  scale_y_continuous(limits=c(min(0), max(100)))+
  xlab("Year") +
  ylab(expression(paste("Mean percent cover", sep = ""))) +
  ggtitle("a) Becher Point")+
  theme_bw() + graphics

SIMP_s_plot

#############################################################
#Warnbro Sound percent cover
SIMP_w = subset(pos_total, Site %in% c("Warnbro Sound 2.5m" , "Warnbro Sound 3.2m", "Warnbro Sound 5.2m" , "Warnbro Sound 7.0m", "Warnbro Sound 2.0m" , "Mersey Point"))

d_sum_simpw <- plyr::ddply(SIMP_w, .(Year, Zone), summarise,
                   N    = length(!is.na(percent)),
                   mean = mean(percent, na.rm=TRUE),
                   sd   = sd(percent, na.rm=TRUE),
                   se   = sd(percent, na.rm=TRUE) / sqrt(length(!is.na(percent)) ))

SIMP_w_plot<-ggplot(d_sum_simpw, aes(x=Year, y=mean, group=Zone, linetype=Zone, shape=Zone)) +
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.02, colour="black", position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, fill="black") + # 21 is filled circle
  scale_x_continuous(limits=c(min(d_sum_simpw$Year-0.125), max(d_sum_simpw$Year+0.125)), breaks=min(d_sum_simpw$Year):max(d_sum_simpw$Year)) +
  scale_y_continuous(limits=c(min(0), max(100)))+
  xlab("Year") +
  ylab(expression(paste("Mean percent cover", sep = ""))) +
  ggtitle("b) Warnbro Sound")+
  theme_bw() + graphics

SIMP_w_plot

#################################################################
#SIMP_shoalwater Bay percent cover

SIMP_shoal = subset(pos_total, Site %in% c("Penguin Island" , "Seal Island", "Bird Island"))

d_sum_shoal <- plyr::ddply(SIMP_shoal, .(Year, Zone), summarise,
                           N    = length(!is.na(percent)),
                           mean = mean(percent, na.rm=TRUE),
                           sd   = sd(percent, na.rm=TRUE),
                           se   = sd(percent, na.rm=TRUE) / sqrt(length(!is.na(percent)) ))


SIMP_shoal_plot <- ggplot(d_sum_shoal, aes(x=Year, y=mean, group=Zone, linetype=Zone, shape=Zone)) +
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.02, colour="black", position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, fill="black") + # 21 is filled circle
  scale_x_continuous(limits=c(min(d_sum_shoal$Year-0.125), max(d_sum_shoal$Year+0.125)), breaks=min(d_sum_shoal$Year):max(d_sum_shoal$Year)) +
  scale_y_continuous(limits=c(min(0), max(100)))+
  xlab("Year") +
  ylab(expression(paste("Mean percent cover", sep = ""))) +
  ggtitle("c) Shoalwater Bay")+
  theme_bw() + graphics

SIMP_shoal_plot

###########################################################################
#SIMP_north percent cover

SIMP_n = subset(pos_total, Site %in% c("Causeway"))

d_sum_simpn <- plyr::ddply(SIMP_n, .(Year, Zone), summarise,
                           N    = length(!is.na(percent)),
                           mean = mean(percent, na.rm=TRUE),
                           sd   = sd(percent, na.rm=TRUE),
                           se   = sd(percent, na.rm=TRUE) / sqrt(length(!is.na(percent)) ))

SIMP_n_plot<-ggplot(d_sum_simpn, aes(x=Year, y=mean, group=Zone, linetype=Zone, shape=Zone)) +
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.02, colour="black", position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, fill="black") + # 21 is filled circle
  scale_x_continuous(limits=c(min(d_sum_simpn$Year-0.125), max(d_sum_simpn$Year+0.125)), breaks=min(d_sum_simpn$Year):max(d_sum_simpn$Year)) +
  scale_y_continuous(limits=c(min(0), max(100)))+
  xlab("Year") +
  ylab(expression(paste("Mean density (","0.04m", ")", sep = ""))) +
  ggtitle("d) Point Peron")+
  theme_bw() + graphics

SIMP_n_plot
#####################################################################################

# Step 4: Create PDF (will be saved to current workdir)

pdf(pdf_fn, width=8, height=7)
grid.arrange(SIMP_s_plot, SIMP_w_plot, SIMP_shoal_plot, SIMP_n_plot, ncol=2)
dev.off()


## Step 5: Upload to CKAN
ckanr::resource_update(pdf_rid, pdf_fn)
ckanr::resource_update(txt_rid, "percent_cover_code.R")

# Step 6: set workdir to main report location
setwd("~/projects/data-pipelines")
