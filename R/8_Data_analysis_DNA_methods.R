### Code to analyse
## 1) Correlation among DNA quantification methods
## 2) Course of infection by DNA quantification method 

library("lifecycle", lib.loc="/usr/local/lib/R/site-library") 
library("ggplot2")
library("data.table")
library("tidyverse")
require("ggpubr")
library("dplyr")
library("plyr")
library("vegan")
library("gridExtra")
library("grid")
library("lattice")
library("pheatmap")
library("viridisLite")
library("phyloseq")
library("microbiome")
library("grid")
library("ggsci")
library("knitr")
library("kableExtra")

if(!exists("sample.data")){
  source("~/GitProjects/Eimeria_Microbiome/R/1_Data_preparation.R")
}

#if(!exists("sdt")){
#  source("~/GitProjects/Eimeria_Microbiome/R/4_Phyloseq_Multimarker.R")
#}
if(!exists("sdt")){
  sdt<- read.csv(file = "/SAN/Victors_playground/Eimeria_microbiome/Multimarker/sdt.csv")
} ## Data from test and full run merged

if(!exists("sdt18SEimMulti")){
  sdt<- read.csv(file = "/SAN/Victors_playground/Eimeria_microbiome/Multimarker/sdt18SEimMulti.csv")
} ## Data from wang.nem primers in the multimarker dataset

if(!exists("counts_multi1")){
  sdt<- read.csv(file = "/SAN/Victors_playground/Eimeria_microbiome/Multimarker/counts_full.csv")
} ## Data from multimarker dataset just full run

if(!exists("counts_multi2")){
  sdt<- read.csv(file = "/SAN/Victors_playground/Eimeria_microbiome/Multimarker/counts_test.csv")
} ## Data from multimarker dataset just test run

#if(!exists("sdt18SEim")){
#  source("~/GitProjects/Eimeria_Microbiome/R/5_Phyloseq_18S.R")
#}
if(!exists("sdt18SEim")){
  sdt18SEim<- read.csv(file = "/SAN/Victors_playground/Eimeria_microbiome/sdt18SEim.csv")
}

#if(!exists("data.inf.exp")){
#  source("~/GitProjects/Eimeria_Microbiome/R/6_qPCR_data_preparation.R")
#}
if(!exists("data.inf.exp")){
  data.inf.exp<- read.csv(file="/SAN/Victors_playground/Eimeria_microbiome/qPCR/sample_data_qPCR.csv")
}

setdiff(sample.data$labels, sdt$labels)
setdiff(sample.data$labels, sdt18SEimMulti$labels)
setdiff(sample.data$labels, sdt18SEim$labels)
setdiff(sample.data$labels, data.inf.exp$labels)
##Keep useful information
sdt%>%
  select(labels, TotalReads, ReadsEim, ReadsEimfer, ReadsEimfal, ReadsEimpap, ReadsEimtel, ReadsEimver, ReadsEimsch, ReadsEimmel, ReadsEimarn)%>%
  distinct(labels, .keep_all = TRUE)-> sdt

sdt18SEimMulti%>%
  select(labels, ReadsEim18SMulti)%>%
  distinct(labels, .keep_all = TRUE)-> sdt18SEimMulti

sdt18SEim%>%
  select(labels, Read_counts_18S, ReadsEim18S, Eimeria_abundance_18S)%>%
  distinct(labels, .keep_all = TRUE)-> sdt18SEim

##Get unique labels from qPCR data
data.inf.exp%>%
  select(labels, Qty_mean, Genome_copies_mean,Tm_mean, Infection)%>%
  distinct(labels, .keep_all = TRUE)-> data.inf.exp

### Join all the data in the same dataframe 
sdt<- join(sample.data, sdt, by="labels") ## First sample data and multimarker read data 
sdt<- join(sdt, sdt18SEim, by="labels") ## then 18S read data (Wang.Nem primer in singlemarker)
sdt<- join(sdt, sdt18SEimMulti, by="labels") ## then 18S read data (Wang.Nem primer in multimarker)
sdt<- join(sdt, data.inf.exp, by="labels") ## then qPCR data 
sdt<- join(sdt, counts_multi1, by="labels") ## Just full run metabarcoding data
sdt<- join(sdt, counts_multi2, by="labels") ## Just test run metabarcoding data

sdt$dpi<- as.factor(sdt$dpi)

###Let's start plotting and analysing the data!
### 1) Correlation among Eimeria quantification methods
####OPG vs reads Eimeria (Multiamplicon)
## Just test run
sdt%>%
  ggplot(aes(OPG, ReadsEim2))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Oocyst per gram feces (Flotation)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_y_log10("log10 Sequence reads count Multiamplicon (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "A)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  #facet_wrap(~dpi) +
  stat_cor(label.x = 5.5, label.y = 1.25, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 5.5, label.y = 1.5)+
  stat_cor(label.x = 5.5,  label.y = 1,method = "spearman")+
  annotation_logticks()-> opgrem

## Just full run
sdt%>%
  ggplot(aes(OPG, ReadsEim1))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Oocyst per gram feces (Flotation)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_y_log10("log10 Sequence reads count Multiamplicon (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "B)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  #facet_wrap(~dpi) +
  stat_cor(label.x = 5.5, label.y = 1.25, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 5.5, label.y = 1.5)+
  stat_cor(label.x = 5.5,  label.y = 1,method = "spearman")+
  annotation_logticks()-> opgrem1

## Full run + test run
sdt%>%
  ggplot(aes(OPG, ReadsEim))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Oocyst per gram feces (Flotation)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_y_log10("log10 Sequence reads count Multiamplicon (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "C)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  #facet_wrap(~dpi) +
  stat_cor(label.x = 5.5, label.y = 1.25, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 5.5, label.y = 1.5)+
  stat_cor(label.x = 5.5,  label.y = 1,method = "spearman")+
  annotation_logticks()-> opgrem2

####OPG vs reads Eimeria (18S amplicon from multimarker dataset) 
sdt%>%
  ggplot(aes(OPG, ReadsEim18SMulti))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Oocyst per gram feces (Flotation)")+
  scale_y_log10("log10 Sequence reads count 18S multi (Eimeria)")+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "B)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  #facet_wrap(~dpi) +
  stat_cor(label.x = 5.5, label.y = 1.25, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 5.5, label.y = 1.5)+
  stat_cor(label.x = 5.5,  label.y = 1,method = "spearman")

####OPG vs reads Eimeria (Single amplicon) 
sdt%>%
  ggplot(aes(OPG, ReadsEim18S))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Oocyst per gram feces (Flotation)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_y_log10("log10 Sequence reads count 18S (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "B)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  #facet_wrap(~dpi) +
  stat_cor(label.x = 5.5, label.y = 1.25, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 5.5, label.y = 1.5)+
  stat_cor(label.x = 5.5,  label.y = 1,method = "spearman")+
  annotation_logticks()-> opgres

####OPG vs qPCR 
sdt%>%
  ggplot(aes(OPG, Qty_mean))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Oocyst per gram feces (Flotation)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_y_log10(name = "log10 Number of Eimeria Oocysts (qPCR)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "C)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  stat_cor(label.x = 5.5, label.y = 1.5, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 5.5, label.y = 2)+
  stat_cor(label.x = 5.5,  label.y = 1,method = "spearman")+
  annotation_logticks()#-> opgqpcr

sdt%>%
  ggplot(aes(OPG, Genome_copies_mean))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Oocyst per gram feces (Flotation)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_y_log10(name = "log10 Eimeria genome copies (qPCR)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "C)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  stat_cor(label.x = 5.5, label.y = 2.5, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 5.5, label.y = 3)+
  stat_cor(label.x = 5.5,  label.y = 2,method = "spearman")+
  annotation_logticks()-> opgqpcr

####qPCR vs Multiamplicon
## Just test run
sdt%>%
  ggplot(aes(Genome_copies_mean, ReadsEim2))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Number of Eimeria genome copies (qPCR)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_y_log10(name = "log10 Sequence reads count Multiamplicon (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "D)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  stat_cor(label.x = 4.0, label.y = 0.75, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 4.0, label.y = 1)+
  stat_cor(label.x = 4.0,  label.y = 0.5,method = "spearman")+
  annotation_logticks()-> qpcrrem

## Just full run
sdt%>%
  ggplot(aes(Genome_copies_mean, ReadsEim1))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Number of Eimeria genome copies (qPCR)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_y_log10(name = "log10 Sequence reads count Multiamplicon (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "E)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  stat_cor(label.x = 4.0, label.y = 1.0, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 4.0, label.y = 1.25)+
  stat_cor(label.x = 4.0,  label.y = 0.75,method = "spearman")+
  annotation_logticks()-> qpcrrem1

## Full run + test run
sdt%>%
  ggplot(aes(Genome_copies_mean, ReadsEim))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Number of Eimeria genome copies (qPCR)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_y_log10(name = "log10 Sequence reads count Multiamplicon (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "F)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  stat_cor(label.x = 5.0, label.y = 0.75, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 5.0, label.y = 1)+
  stat_cor(label.x = 5.0,  label.y = 0.5,method = "spearman")+
  annotation_logticks()-> qpcrrem2

####qPCR vs 18S amplicon from Multimarker dataset
sdt%>%
  ggplot(aes(Genome_copies_mean, ReadsEim18SMulti))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Number of Eimeria genome copies (qPCR)")+
  scale_y_log10(name = "log10 Sequence reads count 18S multi (Eimeria)")+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "E)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  stat_cor(label.x = 5.5, label.y = 1.5, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 5.5, label.y = 1.75)+
  stat_cor(label.x = 5.5,  label.y = 1.25,method = "spearman")

####qPCR vs Single amplicon
sdt%>%
  ggplot(aes(Genome_copies_mean, ReadsEim18S))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Number of Eimeria genome copies (qPCR)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_y_log10(name = "log10 Sequence reads count 18S (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "E)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  stat_cor(label.x = 5.5, label.y = 1.5, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 5.5, label.y = 1.75)+
  stat_cor(label.x = 5.5,  label.y = 1.25,method = "spearman")+
  annotation_logticks()-> qpcrres

####Multiamplicon vs Single amplicon
##Just test run data
sdt%>%
  ggplot(aes(ReadsEim18S, ReadsEim2))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Sequence reads count 18S (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_y_log10(name = "log10 Sequence reads count Multiamplicon (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "F)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  stat_cor(label.x = 3.0, label.y = 0.75, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 3.0, label.y = 1)+
  stat_cor(label.x = 3.0,  label.y = 0.5,method = "spearman")+
  annotation_logticks()-> remres

##Just full run
sdt%>%
  ggplot(aes(ReadsEim18S, ReadsEim1))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Sequence reads count 18S (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_y_log10(name = "log10 Sequence reads count Multiamplicon (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "G)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  stat_cor(label.x = 3.0, label.y = 0.75, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 3.0, label.y = 1)+
  stat_cor(label.x = 3.0,  label.y = 0.5,method = "spearman")+
  annotation_logticks()-> remres1

##Full run + test run
sdt%>%
  ggplot(aes(ReadsEim18S, ReadsEim))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Sequence reads count 18S (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_y_log10(name = "log10 Sequence reads count Multiamplicon (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "H)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  stat_cor(label.x = 3.0, label.y = 0.75, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 3.0, label.y = 1)+
  stat_cor(label.x = 3.0,  label.y = 0.5,method = "spearman")+
  annotation_logticks()-> remres2

##Multi amplicon test run vs full run
sdt%>%
  ggplot(aes(ReadsEim2, ReadsEim1))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Sequence reads count Multiamplicon test (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_y_log10(name = "log10 Sequence reads count Multiamplicon full (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "I)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  stat_cor(label.x = 2.0, label.y = 0.75, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 2.0, label.y = 1)+
  stat_cor(label.x = 2.0,  label.y = 0.5,method = "spearman")+
  annotation_logticks()->rtmrfm

sdt%>%
  select(labels, Read_counts2, ReadsEim2, Read_counts1, ReadsEim1)%>%
  dplyr::mutate(Eimabund1= ReadsEim1/Read_counts1, Eimabund2= ReadsEim2/Read_counts2)

sdt%>%
  ggplot(aes(ReadsEim18S, ReadsEim18SMulti))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Sequence reads count 18S (Eimeria)")+
  scale_y_log10(name = "log10 Sequence reads count 18S Multiamplicon (Eimeria)")+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "F)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  stat_cor(label.x = 3.0, label.y = 0.75, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 3.0, label.y = 1)+
  stat_cor(label.x = 3.0,  label.y = 0.5,method = "spearman")

sdt%>%
  ggplot(aes(ReadsEim18S, ReadsEimfer1))+
  geom_smooth(method = lm)+
  scale_x_log10(name = "log10 Sequence reads count 18S (Eimeria)")+
  scale_y_log10(name = "log10 Sequence reads count Multiamplicon (E. ferrisi)")+
  geom_jitter(shape=21, position=position_jitter(0.2), size=5, aes(fill= dpi), color= "black")+
  labs(tag= "F)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  stat_cor(label.x = 1.0, label.y = 1.75, aes(label= paste(..rr.label.., ..p.label.., sep= "~`,`~"))) +
  stat_regline_equation(label.x = 1.0, label.y = 2)+
  stat_cor(label.x = 1.0,  label.y = 1.5,method = "spearman")


pdf(file = "~/AA_Microbiome/Figures/Multimarker_OPG.pdf", width = 20, height = 7)
grid.arrange(opgrem,opgrem1, opgrem2, ncol= 3, nrow= 1)
dev.off()

pdf(file = "~/AA_Microbiome/Figures/Multimarker_qPCR.pdf", width = 20, height = 7)
grid.arrange(qpcrrem,qpcrrem1, qpcrrem2, ncol= 3, nrow= 1)
dev.off()

pdf(file = "~/AA_Microbiome/Figures/Multimarker_Singlemarker.pdf", width = 25, height = 7)
grid.arrange(remres,remres1, remres2, rtmrfm, ncol= 4, nrow= 1)
dev.off()

pdf(file = "~/AA_Microbiome/Figures/Figure_2.pdf", width = 15, height = 20)
grid.arrange(opgrem, qpcrrem, opgres, qpcrres, opgqpcr, remres, ncol= 2, nrow= 3)
dev.off()

###Course of infection 
#compare_means(OPG ~ dpi,  data = sdt) #Adjust table to run it
sdt%>%
  dplyr::arrange(dpi)%>%
  filter(dpi%in%c("4", "8"))->comp ##for comparison later 

sdt%>%
  ggplot(aes(dpi, OPG))+
  geom_boxplot()+
  xlab("Day post infection")+
  scale_y_log10("log10 Oocyst per gram feces (Flotation)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=2.5, aes(fill= dpi), color= "black")+
  labs(tag= "A)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  annotation_logticks(sides = "l")-> a

sdt%>%
  dplyr::arrange(dpi)%>%
  ggplot(aes(as.numeric(as.character(dpi)), OPG, colour= EH_ID))+
  xlab("Day post infection")+
  scale_y_log10("log10 Oocyst per gram feces (Flotation)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_x_continuous(breaks = c(0,1,2,3,4,5,6,7,8,9,10))+
  geom_line(alpha= 0.5)+
  geom_jitter(shape=21, position=position_jitter(0.0), size=2.5, aes(fill= EH_ID), color= "black", alpha= 0.5)+
  labs(tag= "A)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  stat_smooth(color= "black", method = "loess")+
  annotation_logticks(sides = "l")-> a2

ggpaired(comp, x= "dpi", y= "OPG",line.color= "gray", line.size= 0.4, color= "dpi")+
  scale_y_log10("log10 Oocyst per gram feces (Flotation)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  xlab("Day post infection")+
  scale_color_npg()+
  labs(tag= "A)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  annotation_logticks(sides = "l") -> a3

sdt%>%
  ggplot(aes(dpi, ReadsEim2))+
  geom_boxplot()+
  xlab("Day post infection")+
  scale_y_log10("log10 Sequence reads count \n Multiamplicon (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=2.5, aes(fill= dpi), color= "black")+
  labs(tag= "B)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  annotation_logticks(sides = "l")-> b

sdt%>%
  ggplot(aes(dpi, ReadsEim1))+
  geom_boxplot()+
  xlab("Day post infection")+
  scale_y_log10("log10 Sequence reads count \n Multiamplicon (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=2.5, aes(fill= dpi), color= "black")+
  labs(tag= "B)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  annotation_logticks(sides = "l")-> bi

sdt%>%
  ggplot(aes(dpi, ReadsEim))+
  geom_boxplot()+
  xlab("Day post infection")+
  scale_y_log10("log10 Sequence reads count \n Multiamplicon (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=2.5, aes(fill= dpi), color= "black")+
  labs(tag= "B)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  annotation_logticks(sides = "l")-> bii

### By Eimeria species read count 
sdt%>%
  ggplot(aes(dpi, ReadsEimfer))+
  geom_boxplot()+
  xlab("Day post infection")+
  scale_y_log10("log10 Sequence reads count \n Multiamplicon (Eimeria ferrisi)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=2.5, aes(fill= dpi), color= "black")+
  labs(tag= "B)")+
  theme_bw()+
  theme(text = element_text(size=16))

sdt%>%
  dplyr::arrange(dpi)%>%
  ggplot(aes(as.numeric(as.character(dpi)), ReadsEim2, colour= EH_ID))+
  xlab("Day post infection")+
  scale_y_log10("log10 Sequence reads count \n Multiamplicon (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_x_continuous(breaks = c(0,1,2,3,4,5,6,7,8,9,10))+
  geom_line(alpha=0.5)+
  geom_jitter(shape=21, position=position_jitter(0.0), size=2.5, aes(fill= EH_ID), color= "black", alpha= 0.5)+
  labs(tag= "B)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  stat_smooth(color= "black", method = "loess")+
  annotation_logticks(sides = "l")-> b2

ggpaired(comp, x= "dpi", y= "ReadsEim2",line.color= "gray", line.size= 0.4, color= "dpi")+
  scale_y_log10("log10 Sequence reads count \n Multiamplicon (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  xlab("Day post infection")+
  scale_color_npg()+
  labs(tag= "B)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  annotation_logticks(sides = "l")-> b3

sdt%>%
  ggplot(aes(dpi, Genome_copies_mean))+
  geom_boxplot()+
  xlab("Day post infection")+
  scale_y_log10(name = "log10 Eimeria genome copies (qPCR)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+ 
  geom_jitter(shape=21, position=position_jitter(0.2), size=2.5, aes(fill= dpi), color= "black")+
  labs(tag= "B)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  annotation_logticks(sides = "l")-> c

sdt%>%
  ggplot(aes(dpi, Genome_copies_mean))+
  geom_boxplot()+
  xlab("Day post infection")+
  scale_y_log10(name = "log10 Number of Eimeria genome copies (qPCR)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+ 
  geom_jitter(shape=21, position=position_jitter(0.2), size=2.5, aes(fill= dpi), color= "black")+
  labs(tag= "C)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  annotation_logticks(sides = "l")-> c

sdt%>%
  dplyr::arrange(dpi)%>%
  ggplot(aes(as.numeric(as.character(dpi)), Genome_copies_mean, colour= EH_ID))+
  xlab("Day post infection")+
  scale_y_log10("log10 Eimeria genome copies (qPCR)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_x_continuous(breaks = c(0,1,2,3,4,5,6,7,8,9,10))+
  geom_line(alpha=0.5)+
  geom_jitter(shape=21, position=position_jitter(0.0), size=2.5, aes(fill= EH_ID), color= "black", alpha= 0.5)+
  labs(tag= "C)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  stat_smooth(color= "black", method = "loess")+
  annotation_logticks(sides = "l")-> c2

ggpaired(comp, x= "dpi", y= "Genome_copies_mean",line.color= "gray", line.size= 0.4, color= "dpi")+
  scale_y_log10("log10 Eimeria genome copies (qPCR)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  xlab("Day post infection")+
  scale_color_npg()+
  labs(tag= "C)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  annotation_logticks(sides = "l")-> c3

sdt%>%
  ggplot(aes(dpi, ReadsEim18S))+
  geom_boxplot()+
  xlab("Day post infection")+
  scale_y_log10("log10 Sequence reads count 18S (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  geom_jitter(shape=21, position=position_jitter(0.2), size=2.5, aes(fill= dpi), color= "black")+
  labs(tag= "D)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  annotation_logticks(sides = "l")-> d

sdt%>%
  dplyr::arrange(dpi)%>%
  ggplot(aes(as.numeric(as.character(dpi)), ReadsEim18S, colour= EH_ID))+
  xlab("Day post infection")+
  scale_y_log10("log10 Sequence reads count 18S (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  scale_x_continuous(breaks = c(0,1,2,3,4,5,6,7,8,9,10))+
  geom_line(alpha= 0.5)+
  geom_jitter(shape=21, position=position_jitter(0.0), size=2.5, aes(fill= EH_ID), color= "black", alpha= 0.5)+
  labs(tag= "D)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  stat_smooth(color= "black", method = "loess")+
  annotation_logticks(sides = "l")-> d2

ggpaired(comp, x= "dpi", y= "ReadsEim18S",line.color= "gray", line.size= 0.4, color= "dpi")+
  scale_y_log10("log10 Sequence reads count 18S (Eimeria)", 
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  xlab("Day post infection")+
  scale_color_npg()+
  labs(tag= "D)")+
  theme_bw()+
  theme(text = element_text(size=16))+
  annotation_logticks(sides = "l")-> d3

pdf(file = "~/AA_Microbiome/Figures/Figure_3.pdf", width = 15, height = 10)
grid.arrange(a,c,b,d, ncol= 2, nrow= 2)
dev.off()

pdf(file = "~/AA_Microbiome/Figures/Oocysts_qPCR_Manuscript/Figure_2.pdf", width = 10, height = 20)
grid.arrange(a,c,opgqpcr, ncol= 1, nrow= 3)
dev.off()

pdf(file = "~/AA_Microbiome/Figures/Figure_4.pdf", width = 15, height = 10)
grid.arrange(a2,c2,b2,d2, ncol= 2, nrow= 2)
dev.off()

pdf(file = "~/AA_Microbiome/Figures/Figure_5.pdf", width = 15, height = 10)
grid.arrange(a3,c3,b3,d3, ncol= 2, nrow= 2)
dev.off()

pdf(file = "~/AA_Microbiome/Figures/Course_inf_Multi.pdf", width = 20, height = 7)
grid.arrange(b,bi,bii, ncol= 3, nrow= 1)
dev.off()

###### Alpha and beta diversity analysis (Need an extra script)

####Normalizing data :S 
PSlog <- transform_sample_counts(PS, function(x) log(1 + x))


###Rarefaction curve 
#rarcurv <- vegan::rarecurve(otu_table(PS),
#                            label = F)

## Eliminate samples with low counts
##At 6000 reads samples have reached the species saturation (from rarecurve2!)
PSHigh <- prune_samples(sample_sums(PS)>=6000, PS)
summarize_phyloseq(PSHigh)
nsamples(PSHigh)
ntaxa(PSHigh)
sum(otu_table(PSHigh))
sum(otu_table(subset_taxa(PSHigh, superkingdom %in% "Bacteria")))/sum(otu_table(PSHigh))
sum(otu_table(subset_taxa(PSHigh, superkingdom %in% "Eukaryota")))/sum(otu_table(PSHigh))
#sum(otu_table(subset_taxa(PSHigh, genus%in%"Mus")))/sum(otu_table(PSHigh))

table(tax_table(PSHigh)[, "superkingdom"], exclude = NULL)

#rarcurv2 <- vegan::rarecurve(otu_table(PSHigh),
#                             label = F)
## Merge ASVs that have the same taxonomy at a certain taxonomic rank (in this case phylum and genus)
PS.Gen <-  tax_glom(PSHigh, "genus", NArm = F)
summarize_phyloseq(PS.Gen)

PS.Fam<-  tax_glom(PSHigh, "family", NArm = F)
summarize_phyloseq(PS.Fam)

PS.Ord <-  tax_glom(PSHigh, "order", NArm = F)
summarize_phyloseq(PS.Ord)

PS.Phy <-  tax_glom(PSHigh, "phylum", NArm = TRUE)
summarize_phyloseq(PS.Phy)

plot_bar(PS, fill="phylum") + facet_wrap(~dpi, scales= "free_x", nrow=1)
plot_richness(PS, x="dpi", color="dpi", measures=c("Chao1", "Shannon", "Simpson"))+ 
  geom_boxplot()+
  theme_bw()

alphaDiv <- phyloseq::estimate_richness(PS)

#eveAll <- evenness(PS1, c("pielou", "simpson", "evar", "bulla"))

###Difference accross DPI?
#pairwise.wilcox.test(alphaDiv$Shannon, sample_data(PS1)$dpi)

#Beta diversity 
dis <- phyloseq::distance(PS, method="bray")
#ordi <- ordinate(PS1, method="PCoA", distance="bray")
#beta.plot <- plot_ordination(PS1, ordi, color="dpi")+
#  scale_color_gradient(low="blue", high="red", name= "Mouse genotype\n(Hybrid Index)")+
#  theme_classic(base_size = 15, base_family = "Helvetica")+
#  geom_point(size=5, alpha= 0.75)+
#  labs(tag= "A)")

##Permanova
#require("vegan")
#adonis(dis ~ sample_data(PS1)$dpi)

###Using Negative Bionomial in microbiome differential abundance testing (not working check it again :( )
#require("DESeq2")
#dipdds <- phyloseq_to_deseq2(PS1.16SA, ~ dpi)
#DESeq(dipdds)

# calculate geometric means prior to estimate size factors
#gm_mean <- function(x, na.rm=TRUE){
#  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
#}
#geoMeans <- apply(counts(dipdds), 1, gm_mean)
#dipdds <- estimateSizeFactors(dipdds, geoMeans)
#dipdds <- DESeq(dipdds, fitType="local")

###Ordination
#OrdPS16SA <- ordinate(PS16SAlog, method = "MDS", distance = "wunifrac")
#evals <- out.wuf.log$values$Eigenvalues
#plot_ordination(pslog, out.wuf.log, color = "age_binned") +
#  labs(col = "Binned Age") +
#  coord_fixed(sqrt(evals[2] / evals[1]))

###Composition
PS1c <- PS1 %>%
  aggregate_taxa(level = "phylum") %>%  
  microbiome::transform(transform = "compositional")

PS1c %>%
  plot_composition(sample.sort = "Eimeria", otu.sort = "abundance", group_by= "dpi") + theme(legend.position="none")

plot_composition(PS1c,
                 average_by = "dpi")+ theme(legend.position="bottom")

pdf(file = "~/AA_Microbiome/Figures/Composition_Infection.pdf", width = 15, height = 15)
grid.arrange(g,h,i, ncol= 1, nrow= 3)
dev.off()



###Alpha diversity along infection
alphaDiv$labels<- rownames(alphaDiv)
eveAll$labels <- rownames(eveAll)

sdt<- plyr::join(sdt, alphaDiv, by= "labels")
sdt<- plyr::join(sdt, eveAll, by= "labels")

d<- ggplot(sdt, aes(dpi, Chao1, fill= dpi))+
  geom_boxplot()+
  xlab("Day post infection")+
  ylab("Richness (Chao1 Index)")+
  labs(tag= "A)")+
  theme_bw()

e<- ggplot(sdt, aes(dpi, Shannon, fill= dpi))+
  geom_boxplot()+
  xlab("Day post infection")+
  ylab("Diversity (Shannon Index)")+
  labs(tag= "B)")+
  theme_bw()

f<- ggplot(sdt, aes(dpi, pielou, fill= dpi))+
  geom_boxplot()+
  xlab("Day post infection")+
  ylab("Evenness (Pielou's Index)")+
  labs(tag= "C)")+
  theme_bw()

pdf(file = "~/AA_Microbiome/Figures/Alpha_div_Infection.pdf", width = 15, height = 15)
grid.arrange(d,e,f, ncol= 1, nrow= 3)
dev.off()


##Rarefaction curves
rarecurve(t(otu_table(PS)), step=50, cex=0.5)


sampleData(PS)$parental <- getVariable(PS, "HybridStatus") %in% "parental strains"
PSHigh <- prune_samples(sample_sums(PS)>6700, PS) ## Eliminate samples with low counts considering as limit Mean - sd 

###Alpha diversity
alphaDiv <- as.data.frame(estimate_richness(PSHigh, measures=c("Observed", "InvSimpson", "Shannon", "Chao1")))
####Add richness alpha diversity data to phyloseq 
sample_data(PSHigh)$Shannon <- alphaDiv$Shannon
sample_data(PSHigh)$InvSimpson <- alphaDiv$InvSimpson
sample_data(PSHigh)$Chao1 <- alphaDiv$Chao1
PSdata <- meta(PSHigh)


###Compair differences in Shannon idex between groups (e.g. time points)
ggplot(PSdata, aes(x= as.factor(dpi), y= Shannon, fill= as.factor(dpi)))+
  geom_boxplot()+
  geom_jitter()+
  facet_grid(HybridStatus~.)+ 
  theme_classic()

plot_regression(Shannon ~ as.factor(dpi), meta(PSHigh)) + xlab("DPI") + ylab("Diversity (Shannon)")

plot_landscape(PSHigh, "MDS", "bray", col = "dpi")


###Compositional 

PSComp <- microbiome::transform(PSHigh, "compositional")

plot_composition(PSHigh, average_by = "dpi", transform = "compositional")

plot_composition(PSComp, sample.sort = "Apicomplexa", otu.sort = "abundance") +
  # Set custom colors
  scale_fill_manual(values = default_colors("Phylum")[taxa(PSComp1)]) 


##Plot_richness
prune_species(speciesSums(PS)>0, PS)
plot_richness(PS, x= "dpi", color = "Strain" , measures = c("Chao1", "Shannon")) + geom_line()
plot_richness(PSHigh, x= as.character("dpi"), color = "Strain" , measures = c("Chao1", "Shannon"))+ geom_line()
plot_richness(PSHigh, x= "parental", color = "dpi" , measures = c("Chao1", "Shannon"))
##rarefy 
rarecurve(t(otu_table(PSHigh)), step=100, cex=0.5)
PS.rarefied <- rarefy_even_depth(PSHigh, rngseed=1, sample.size=0.9*min(sample_sums(PSHigh)), replace=F)


###Plot ASVs

plot_bar(PS, fill="phylum") + facet_wrap(~dpi, scales= "free_x", nrow=1)
plot_bar(PSHigh, fill="phylum") + facet_wrap(~dpi, scales= "free_x", nrow=1)
plot_bar(PS.rarefied, fill="phylum") + facet_wrap(~dpi, scales= "free_x", nrow=1)


##Beta diversity
# PCoA plot using the unweighted UniFrac as distance
wunifrac_dist <- distance(PSHigh, method="unifrac", weighted=F)
ordination <- ordinate(PS, method="PCoA", distance=wunifrac_dist)
plot_ordination(PS, ordination, color="dpi") + theme(aspect.ratio=1)

###Emanuel's code
nameOtuByTax <- function(PS, taxon="genus"){
  otable <- otu_table(PS)
  rownames(otable) <- make.unique(as.character(tax_table(PS)[, "genus"]))
  otable
}

ordi <- ordinate(PS, method="MDS", distance="bray")
ordi <- ordinate(PS.rarefied, method="MDS", distance="bray")

plot_ordination(PS, ordi, color="dpi")
plot_ordination(PS.rarefied, ordi, color="dpi") ##add circles by dpi 

PSHigh <- prune_samples(sample_sums(PS)>6700, PS) ## Eliminate samples with low counts considering as limit Mean - sd 


ordi2 <- ordinate(PSHigh, method="MDS", distance="bray")

plot_ordination(PSHigh, ordi2, color="OPG", label="dpi")


ordi3 <- ordinate(subset_taxa(PSHigh, !phylum%in%"Apicomplexa"),
                  method="MDS", distance="bray")

plot_ordination(subset_taxa(PSHigh, !phylum%in%"Apicomplexa"),
                ordi3, color="dpi")


ordi4 <- ordinate(PSHigh, formula = ~dpi, "MDS", "bray")
ordi4plot <- plot_ordination(PSHigh, ordi4, "Sample", color="dpi",shape="HybridStatus")


#ordi4 <- ordinate(PSHigh, method="PCoA", distance="unifrac")
#plot_ordination(PSHigh, ordi4, color="dpi") + theme(aspect.ratio=1)



plot_richness(PSHigh, "dpi", color= "OPG", measures="Shannon") + stat_smooth()

plot_richness(PSHigh, "dpi", color= "OPG", measures="Chao1") + stat_smooth()

plot_richness(PSHigh, "dpi", color= "fecweight_DNA",measures="Chao1") + stat_smooth()

sexplot <- plot_richness(PSHigh, x= "Sex") + geom_boxplot(aes(x = Sex, color = dpi), alpha = 0.1)

dpiplot <- plot_richness(PSHigh, x= "dpi") + geom_boxplot(aes(x = dpi, color = dpi), alpha = 0.1)


####

# prune to just the top 100 most abundant OTUs across all samples (crude).
PS50 <- prune_taxa(names(sort(taxa_sums(PS), TRUE))[1:50], PS)
jg <-  make_network(PS100, "taxa", "jaccard", 0.3)
plot_network(jg, PS100, "taxa", color = "phylum", line_weight = 0.4, label = NULL)


TopOTUs <- names(sort(taxa_sums(PS), TRUE)[1:50])
PS10 <- prune_taxa(TopOTUs, PS)
plot_bar(PS10, "dpi", fill = "Strain", facet_grid = ~phylum)
