# FFT analysis

setwd(("C:/Users/Dan/Documents/GitHub/BlueEnrichedLightRepo/Analyses Scripts_R"))
# setwd(("C:/GitHub/BlueEnrichedLightRepo/Analyses Scripts_R"))

## Install relevant libraries 
library(foreign)
library(car)
library(ggplot2)
library(pastecs)
library(psych)
library(plyr)
library(multcomp)
library(reshape2)
library(compute.es)
library(ez)
library(lattice)
library(lme4)
library(png)
library(grid)


###### Import FFR data:
data <- read.csv("C:/Users/Dan/Documents/GitHub/BlueEnrichedLightRepo/Analyses Scripts_Matlab/FFT_for_R.csv", header=FALSE)
# data <- read.csv("C:/GitHub/BlueEnrichedLightRepo/Analyses Scripts_Matlab/FFT_for_R.csv", header=FALSE)


#Rename data columns:
data<-rename(data, c("V1"="ID", "V2"="Light","V3"="Frequency","V4"="Power"))


#Make the required columns into factors:
data$Light <- factor(data$Light)
data$Frequency <- factor(data$Frequency)

#Rename factor Levels:
data$Light <- revalue(data$Light, c("1"="Low", "2"="Medium", "3"="High"))


    plot(data$Frequency, data$Power)
    
    
    #Model the effects of light and frequency bin on Power
    random_intercepts_only<-glmer(Power ~ 1 + (1 | ID) +(1|Light) + (1|Frequency), data = data, family = Gamma(link = log), na.action = na.omit)
    Light<-update(random_intercepts_only, .~. + Light)
    Frequency<-update(Light, .~. + Frequency)
    LightbyFrequency<-update(Frequency, .~. + Light*Frequency)
    anova(random_intercepts_only, Light, Frequency, LightbyFrequency)
    
    #Plot Light by Frequency
    require(effects)
    plot(allEffects(LightbyFrequency))

    
    
    source("summarySE.R") 
    source("summarySEwithin.R") #function to calculate Std.Er of mean
    source("normDataWithin.R")
    cbPalette <- c("#333333", "#999999", "#CCCCCC")#grey colours
    plotdata <- summarySEwithin(data, measurevar="Power", withinvars=c("Light", "Frequency"), idvar="ID")
    plotdata$Frequency<-as.numeric(as.character(plotdata$Frequency))
    summary(plotdata$Frequency)
    #Power Group on same plot
    ggplot(plotdata, aes(x=Frequency, y=Power, color=Light,fill=Light)) + 
        geom_line(size=1.4) + #geom_ribbon(aes(ymin=Power-se, ymax=Power+se), alpha = 0.3, colour=NA) +  
        coord_cartesian(ylim = c(0, 0.2),  xlim = c(1, 35)) +
        scale_x_continuous(breaks = round(seq(min(plotdata$Frequency), max(plotdata$Frequency), by = 1),1)) +
        xlab("Frequency (Hz)") + ylab("Power (uV)") +
        theme(axis.title.x = element_text(face="bold", size=12),
              axis.text.x  = element_text(face="bold", angle=0,  size=12)) +
        theme(axis.title.y = element_text(face="bold", size=12),
              axis.text.y  = element_text(angle=0, vjust=0.5, size=12)) +
        theme(legend.title = element_text(size=12, face="bold")) +
        theme(legend.text = element_text(size = 11, face = "bold")) +
        theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
              panel.background = element_blank(), axis.line = element_line(colour = "black")) +
        ggtitle("FFT pooled from electrodes PO4 & PO8, as a function of Light:\n\n Low(~50 lux); Medium(~350 lux); High(~1400 lux)")
    
    ggsave("FFTplot.png", dpi=300)
    

    
############Calculate difference between High and low light###########
    
    #First bring Light up into wide format
    require(reshape2)
    data_wide <- dcast(data, ID + Frequency ~ Light, value.var="Power")
    
    #Now calculate 
    data_wide$High_minus_Low<-(data_wide$High-data_wide$Low)
    
    plot(data_wide$Frequency, data_wide$High_minus_Low)

    

    
    
    
    source("summarySE.R") 
    source("summarySEwithin.R") #function to calculate Std.Er of mean
    source("normDataWithin.R")
    plotdata <- summarySEwithin(data_wide, measurevar="High_minus_Low", withinvars=c("Frequency"), idvar="ID")
    plotdata$Frequency<-as.numeric(as.character(plotdata$Frequency))
    summary(plotdata$Frequency)
    #Power Group on same plot
    ggplot(plotdata, aes(x=Frequency, y=High_minus_Low)) + 
        geom_bar(position=position_dodge(.9), colour="Black", stat="identity") +
        geom_errorbar(position=position_dodge(.9), width=.25, aes(ymin=High_minus_Low-se, ymax=High_minus_Low+se)) + #can change "se" to "ci" if I want to use 95%ci instead  
        coord_cartesian(ylim = c(0, 0.02),  xlim = c(1, 35)) +
        scale_x_continuous(breaks = round(seq(min(plotdata$Frequency), max(plotdata$Frequency), by = 1),1)) +
        xlab("Frequency (Hz)") + ylab("High minus Low Light (uV)") +
        theme(axis.title.x = element_text(face="bold", size=12),
              axis.text.x  = element_text(face="bold", angle=0,  size=12)) +
        theme(axis.title.y = element_text(face="bold", size=12),
              axis.text.y  = element_text(angle=0, vjust=0.5, size=12)) +
        theme(legend.title = element_text(size=12, face="bold")) +
        theme(legend.text = element_text(size = 11, face = "bold")) +
        theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
              panel.background = element_blank(), axis.line = element_line(colour = "black")) +
        ggtitle("FFT power difference between High and Low Light:\n\n Low(~50 lux); Medium(~350 lux); High(~1400 lux)")
    
    ggsave("FFT_diff_plot_bar.png", dpi=300)
    
    
    
    source("summarySE.R") 
    source("summarySEwithin.R") #function to calculate Std.Er of mean
    source("normDataWithin.R")
    plotdata <- summarySEwithin(data_wide, measurevar="High_minus_Low", withinvars=c("Frequency"), idvar="ID")
    plotdata$Frequency<-as.numeric(as.character(plotdata$Frequency))
    summary(plotdata$Frequency)
    #Power Group on same plot
    ggplot(plotdata, aes(x=Frequency, y=High_minus_Low)) + 
        geom_line(size=1.4) + geom_errorbar(position=position_dodge(.9), width=.25, aes(ymin=High_minus_Low-se, ymax=High_minus_Low+se)) + #can change "se" to "ci" if I want to use 95%ci instead  geom_errorbar(position=position_dodge(.9), width=.25, aes(ymin=High_minus_Low-se, ymax=High_minus_Low+se)) + #can change "se" to "ci" if I want to use 95%ci instead   
        coord_cartesian(ylim = c(0, 0.02),  xlim = c(1, 35)) +
        scale_x_continuous(breaks = round(seq(min(plotdata$Frequency), max(plotdata$Frequency), by = 1),1)) +
        xlab("Frequency (Hz)") + ylab("High minus Low Light (uV)") +
        theme(axis.title.x = element_text(face="bold", size=12),
              axis.text.x  = element_text(face="bold", angle=0,  size=12)) +
        theme(axis.title.y = element_text(face="bold", size=12),
              axis.text.y  = element_text(angle=0, vjust=0.5, size=12)) +
        theme(legend.title = element_text(size=12, face="bold")) +
        theme(legend.text = element_text(size = 11, face = "bold")) +
        theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
              panel.background = element_blank(), axis.line = element_line(colour = "black")) +
        ggtitle("FFT power difference between High and Low Light:\n\n Low(~50 lux); Medium(~350 lux); High(~1400 lux)")
    
    ggsave("FFT_diff_plot_line.png", dpi=300)
    
    
    
    
    #Model the effects of light and frequency bin on Power High_minus_Low
    random_intercepts_only<-lmer(High_minus_Low ~ 1 + (1 | ID) + (1|Frequency), data = data_wide, REML = F, na.action = na.omit)
    Frequency<-update(random_intercepts_only, .~. + Frequency)
    anova(random_intercepts_only, Frequency)  
    
    require(effects)
    plot(allEffects(Frequency))
    