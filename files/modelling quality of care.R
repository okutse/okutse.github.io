## A Naïve Bayes Probabilistic Classifier for Modelling the Quality of Care in End of Life Patients
## Amos Ochieng Okutse
## An Undergraduate Project
##Jomo Kenyatta University of Agriculture & Technology
##########################################################
##Exploratory Data Analysis
##########################################################
library(reshape2)
library(caTools)
library(caret)
library(ggplot2)
library(dplyr)
library(data.table)
quality=read.csv("C:/Users/Amos Okutse/Desktop/Modelling Quality of Care/quality.csv",header=TRUE)
View(quality)

quality=quality[,1:13]
View(quality)
str(quality)
quality$PoorCare=as.factor(quality$PoorCare)
quality$PoorCare=ifelse(quality$PoorCare==0,"NO","YES")

##Correlation Analysis
cormat=round(cor(quality),2)
head(cormat)
#due to the fact that corr matrix have redundant info, we use only the upper or
#lower part of the matrix
#we do this by;
# Get lower triangle of the correlation matrix
get_lower_tri<-function(cormat){
  cormat[upper.tri(cormat)] <- NA
  return(cormat)
}
# Get upper triangle of the correlation matrix
get_upper_tri <- function(cormat){
  cormat[lower.tri(cormat)]<- NA
  return(cormat)
}
#usage of the function;
upper_tri <- get_upper_tri(cormat)
upper_tri

# Melt the correlation matrix
library(reshape2)
melted_cormat <- melt(upper_tri, na.rm = TRUE)
# Heatmap
library(ggplot2)
ggplot(data = melted_cormat, aes(Var2, Var1, fill = value))+
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Pearson\nCorrelation") +
  theme_minimal()+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 12, hjust = 1))+
  coord_fixed()
#negative correlations are in blue color and positive correlations in red. 
#The function scale_fill_gradient2 is used with the argument limit = c(-1,1) as correlation 
#coefficients range from -1 to 1.
#coord_fixed() : this function ensures that one unit on the x-axis is the same 
#length as one unit on the y-axis.

##reordering the correlation matrix;
reorder_cormat <- function(cormat){
  # Use correlation between variables as distance
  dd <- as.dist((1-cormat)/2)
  hc <- hclust(dd)
  cormat <-cormat[hc$order, hc$order]
}
# Reorder the correlation matrix
cormat <- reorder_cormat(cormat)
upper_tri <- get_upper_tri(cormat)
# Melt the correlation matrix
melted_cormat <- melt(upper_tri, na.rm = TRUE)
# Create a ggheatmap
ggheatmap <- ggplot(melted_cormat, aes(Var2, Var1, fill = value))+
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Pearson\nCorrelation") +
  theme_minimal()+ # minimal theme
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 12, hjust = 1))+
  coord_fixed()
# Print the heatmap
print(ggheatmap)

##adding the correlations into the heatmap;
##Use geom_text() to add the correlation coefficients on the graph
##Use a blank theme (remove axis labels, panel grids and background, and axis ticks)
##Use guides() to change the position of the legend title

##the final heatmap;
ggheatmap + 
  geom_text(aes(Var2, Var1, label = value), color = "black", size = 3) +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.grid.major = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank(),
    axis.ticks = element_blank(),
    legend.justification = c(1, 0),
    legend.position = c(0.6, 0.7),
    legend.direction = "horizontal")+
  guides(fill = guide_colorbar(barwidth = 7, barheight = 1,
                               title.position = "top", title.hjust = 0.5))

#####################################################################################################
##Inpatient Days and quality of care
ggplot(quality,aes(x=quality$InpatientDays,fill=quality$PoorCare))+
  geom_bar(position = "dodge")+
  xlab("In Patient Days")+
  ylab("Count")+
  ggtitle("Frequency of In Patient Days")+
  scale_fill_discrete(name="Poor Care",labels=c("No","Yes"))

##started on combination
ggplot(quality,aes(x=quality$StartedOnCombination,fill=quality$PoorCare))+
  geom_bar(position = "dodge")+
  xlab("Started on Combination for Diabetes Drugs")+
  ylab("Count")+
  ggtitle("Relationship Between Combination Drugs and Poor Care")+
  scale_fill_discrete(name="Poor Care",labels=c("No","Yes"))

##Total Visits and Poor Care
ggplot(quality,aes(x=quality$TotalVisits,fill=quality$PoorCare))+
  geom_density()+
  ggtitle("Number of Total Visits ")+
  xlab("Total Visits")+
  ylab("Count")+
  scale_fill_discrete(name="Poor Care",labels=c("No","Yes"))
  

## ER visits and poor care
ggplot(quality,aes(x=quality$ERVisits,fill=quality$PoorCare))+
  geom_density()+
  ggtitle("Number of ER Visits ")+
  xlab("ER Visits")+
  ylab("Count")+
  scale_fill_discrete(name="Poor Care",labels=c("No","Yes"))

##Office Visits and Quality of Care
ggplot(quality,aes(x=quality$OfficeVisits,fill=quality$PoorCare))+
  geom_density()+
  ggtitle("Number of Office Visits and Quality of Care ")+
  xlab("Office Visits")+
  ylab("Frequency")+
  scale_fill_discrete(name="Poor Care",labels=c("No","Yes"))


###converting Narcotics and Days since last visit to factors
zero<-quality[which((quality$Narcotics<20)),]
one=quality[which((quality$Narcotics>=20)&(quality$Narcotics<40)),]
two=quality[which(quality$Narcotics>60),]
narcotics=data.frame(narcotics_groups=c("zero","one","two"),
                  narcotics_count=c(NROW(zero$Narcotics),NROW(one$Narcotics),NROW(two$Narcotics)))

quality=cbind(quality,narcotics=ifelse((quality$Narcotics<20), 0, ifelse((quality$Narcotics>=20)&(quality$Narcotics<40),1,2)))
quality$narcotics=as.factor(quality$narcotics)
                    ################################
###converting days since last visit to groups
zero1<-quality[which((quality$DaysSinceLastERVisit<300)),]
one1=quality[which((quality$DaysSinceLastERVisit>=300)&(quality$DaysSinceLastERVisit<600)),]
two1=quality[which(quality$DaysSinceLastERVisit>600),]
groups=data.frame(groups_groups=c("zero1","one1","two1"),
                     groups_count=c(NROW(zero1$DaysSinceLastERVisit),NROW(one1$DaysSinceLastERVisit),NROW(two1$DaysSinceLastERVisit)))

quality=cbind(quality,groups=ifelse((quality$DaysSinceLastERVisit<300), 0, ifelse((quality$DaysSinceLastERVisit>=300)&(quality$DaysSinceLastERVisit<600),1,2)))
quality$groups=as.factor(quality$DaysSinceLastERVisit)
View(quality)
quality=subset(quality[-15])
quality

ggplot(quality,aes(x=factor(quality$narcotics),y=quality$groups,colour=quality$PoorCare))+
  geom_boxplot(stat="boxplot",position='dodge2')+
  geom_boxplot(outlier.shape = NA)+
  geom_jitter(width=0.2)+
  xlab("Number of Prescriptions the patient had for Narcotics ")+
  ylab("Number of Days since last ER Visit")+
  ggtitle("Number of Prescription Narcotics given, Number of Days since Last ER Visit & Quality of Care")+
  scale_fill_discrete(name="Poor Care",labels=c("No","Yes"))
##########################################################################################
##Naive Bayes Classifier Implementation

attach(quality)
InpatientDays=as.numeric(InpatientDays)
ERVisits=as.numeric(ERVisits)
OfficeVisits=as.numeric(OfficeVisits)
Narcotics=as.numeric(Narcotics)
Pain=as.numeric(Pain)
TotalVisits=as.numeric(TotalVisits)
ProviderCount=as.numeric(ProviderCount)
MedicalClaims=as.numeric(MedicalClaims)
ClaimLines=as.numeric(ClaimLines)
StartedOnCombination=as.numeric(StartedOnCombination)
AcuteDrugGapSmall=as.numeric(AcuteDrugGapSmall)
quality$PoorCare=as.factor(quality$PoorCare)

library(caTools)
library(e1071)
set.seed(100)
sample<-sample.split(quality$PoorCare,SplitRatio = 0.80)
train<-subset(quality,sample==TRUE)
test<-subset(quality,sample==FALSE)
nB_model<-naiveBayes(PoorCare~.,data=train)
summary(nB_model)




##making some predictions using the Naive Bayes Models;
pred<-predict(nB_model,test,type="class",prob=TRUE)

confusionMatrix(pred,test$PoorCare)


