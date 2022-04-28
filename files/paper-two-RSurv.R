# Survival Modeling using DEGS and microarray data: Data was obtained from the GEO with accession GSE13507
## The Code will be updated to an .Rmd file later
#setwd("F:\\Biostatistics\\An analysis of DEGs and their impact on colorectal cancer survival")
#load the required libraries
library(Biobase)
library(GEOquery)

# load series and platform data from GEO
gset <- getGEO('GSE13507', GSEMatrix =TRUE, getGPL=FALSE)
x <- exprs(gset[[1]])

#remove affymetrix control probes

#x<-x[-grep('^AFFx',rownames(x)),]

pData(gset[[1]])
colnames(pData(gset[[1]]))
class(pData(gset[[1]])$"strain:ch1")
pData(gset[[1]])$"strain:ch1"
# transform the expression data to Z scores
x <- t(scale(t(x)))
#removing extra rows from the x data
#write.csv(x,file="x.csv")
x<-x[,69:233]

#extract information of interest from the phenotype data (pdata)
idx <- which(colnames(pData(gset[[1]])) %in%
               c('age:ch1', 'grade:ch1', 'survival month:ch1',
                 'SEX:ch1','progression:ch1', 'overall survival:ch1'))
metadata <- data.frame(pData(gset[[1]])[,idx],
                       row.names = rownames(pData(gset[[1]])))
metadata<-metadata[69:233,]


# remove samples from the pdata that have any NA value
#discard <- apply(metadata, 1, function(x) any( is.na(x) ))
#metadata <- metadata[!discard,]

# filter the Z-scores expression data to match the samples in our pdata
x <- x[,which(colnames(x) %in% rownames(metadata))]

# check that sample names match exactly between pdata and Z-scores 
all((colnames(x) == rownames(metadata)) == TRUE)
## [1] TRUE

# create a merged pdata and Z-scores object
coxdata <- data.frame(metadata, t(x))
age<-read.csv("age.csv",header=TRUE)
coxdata$age.ch1<-age$age
#head(str(coxdata))
##convert variables to factors and numeric as necessary
coxdata$age.ch1<-as.numeric(coxdata$age.ch1)
coxdata$grade.ch1<-as.factor(coxdata$grade.ch1)
coxdata$survival.month.ch1<-as.numeric(coxdata$survival.month.ch1)
coxdata$SEX.ch1<-as.factor(coxdata$SEX.ch1)
coxdata$progression.ch1<-as.factor(coxdata$progression.ch1)
coxdata$overall.survival.ch1<-as.factor(coxdata$overall.survival.ch1)
coxdata$overall.survival.ch1<-as.numeric(coxdata$overall.survival.ch1)
# tidy column names
colnames(coxdata)[1:6] <- c('Age', 'Grade', 'Overall_survival',
                            'Progression', 'Sex', 'Survival_time')
# prepare phenotypes
#str(coxdata)
levels(coxdata$Grade)<-c(1,2)
#levels(coxdata$Overall_survival)<-c(1,2)
levels(coxdata$Progression)<-c(1,2)
levels(coxdata$Sex)<-c(1,2)

str(coxdata)
#coxdata$Distant.RFS <- as.numeric(coxdata$Distant.RFS)
#coxdata$Time.RFS <- as.numeric(gsub('^KJX|^KJ', '', coxdata$Time.RFS))
#coxdata$ER <- factor(coxdata$ER, levels = c(0, 1))
#coxdata$Grade <- factor(coxdata$Grade, levels = c(1, 2, 3))
################################################################################
##Testing each gene independently via cox regression

library(survival)
library(RegParallel)

res <- RegParallel(
  data = coxdata,
  formula = 'Surv(Survival_time, Overall_survival) ~ [*]',
  FUN = function(formula, data)
    coxph(formula = formula,
          data = data,
          ties = 'breslow',
          singular.ok = TRUE),
  FUNtype = 'coxph',
  variables = colnames(coxdata)[7:ncol(coxdata)],
  blocksize = 2000,
  cores = 2,
  nestedParallel = FALSE,
  conflevel = 95)
res <- res[!is.na(res$P),]
res
write.csv(res, file="cox proportional hazard ratio.csv",row.names=FALSE,
          quote=FALSE)
###################################################################################
#Annotate top hits with bioMaRt
res <- res[order(res$LogRank, decreasing = FALSE),]
final <- subset(res, LogRank < 0.01)
write.table(final,file="CoxPH Model Reduced Results.txt",quote=FALSE,
            row.names = FALSE,sep = ",")
probes <- gsub('^X', '', final$Variable)

library(biomaRt)
mart <- useMart('ensembl', host='ensembl.org')
mart <- useDataset("hsapiens_gene_ensembl", mart)
annotLookup <- getBM(attributes = c('illumina_humanht_12_v3',
                                    'entrezgene_id',
                                    'gene_biotype',
                                    'external_gene_name'),
                     filter = 'illumina_humanht_12_v3',
                     values = probes,
                     mart = mart,
                     uniqueRows = TRUE)

annotLookup
View(annotLookup)
#subsetannot300<-annotLookup[1:300,]
#subsetannot300
#write the annotation results to external file
write.csv(annotLookup, file="annotated top hits with entrez id.csv",
          row.names=FALSE)

listAttributes(mart)
#listFilters(mart)
#?getBM
#####################################################################
#####################################################################
##encode statistically significant genes and plot survival curves
##check which DEGs have been reported through the annotation
#load the DEG data with entrez Ids
DEG<-read.csv("Top 300 complete expression table.csv",header=T)
head(DEG)
entrezid<-DEG$ENTREZID
entrezid_from_coxph<-annotLookup$entrezgene_id
top_survival_genes<-intersect(entrezid,entrezid_from_coxph)
top_survival_genes   #these are the genes found from the coxph
##write this genes together with whether they are up regulated 
##or downregulated and whether there pvalue from cox is significant

# extract RFS and probe data for downstream analysis
survplotdata <- coxdata[,c('Survival_time', 'Overall_survival',
                           'ILMN_1675100', 'ILMN_1786598','ILMN_1761788',
                           'ILMN_1743445','ILMN_1719811')]

colnames(survplotdata) <- c('Survival_time', 'Overall_survival',
                            'EDNRB', 'COL14A1','MOXD1','FAM107A','REM1')

# set Z-scale cut-offs for high and low expression for the 5 most DE genes
highExpr <- 1.0
lowExpr <- -1.0
survplotdata$EDNRB <- ifelse(survplotdata$EDNRB >= highExpr, 'High',
                              ifelse(survplotdata$EDNRB <= lowExpr, 'Low', 'Mid'))
survplotdata$COL14A1 <- ifelse(survplotdata$COL14A1 >= highExpr, 'High',
                             ifelse(survplotdata$COL14A1 <= lowExpr, 'Low', 'Mid'))
survplotdata$MOXD1 <- ifelse(survplotdata$MOXD1 >= highExpr, 'High',
                               ifelse(survplotdata$MOXD1 <= lowExpr, 'Low', 'Mid'))
survplotdata$FAM107A <- ifelse(survplotdata$FAM107A >= highExpr, 'High',
                               ifelse(survplotdata$FAM107A <= lowExpr, 'Low', 'Mid'))
survplotdata$REM1 <- ifelse(survplotdata$REM1 >= highExpr, 'High',
                               ifelse(survplotdata$REM1 <= lowExpr, 'Low', 'Mid'))
# relevel the factors to have mid as the ref level
survplotdata$EDNRB <- factor(survplotdata$EDNRB,
                              levels = c('Mid', 'Low', 'High'))
survplotdata$COL14A1 <- factor(survplotdata$COL14A1,
                             levels = c('Mid', 'Low', 'High'))
survplotdata$MOXD1 <- factor(survplotdata$MOXD1,
                               levels = c('Mid', 'Low', 'High'))
survplotdata$FAM107A <- factor(survplotdata$FAM107A,
                               levels = c('Mid', 'Low', 'High'))
survplotdata$REM1 <- factor(survplotdata$REM1,
                               levels = c('Mid', 'Low', 'High'))

library(survminer)
##PLOT 1 EDNRB
ggsurvplot(survfit(Surv(Survival_time, Overall_survival) ~ EDNRB,
                   data = survplotdata),
           data = survplotdata,
           risk.table = TRUE,
           pval = TRUE,
           break.time.by = 10,
           ggtheme = theme_minimal(),
           risk.table.y.text.col = TRUE,
           risk.table.y.text = FALSE)
##################################################################
##exporting the plot
jpeg("Expression of EDNRB impact on bladder cancer survival.jpeg",
     height = 6,width = 8,units = 'in',res=720)
ggsurvplot(survfit(Surv(Survival_time, Overall_survival) ~ EDNRB,
                   data = survplotdata),
           data = survplotdata,
           risk.table = TRUE,
           pval = TRUE,
           break.time.by = 10,
           ggtheme = theme_minimal(),
           risk.table.y.text.col = TRUE,
           risk.table.y.text = FALSE)
dev.off()
##PLOT2 COL14A1
jpeg("Expression of COL14A1 impact on bladder cancer survival.jpeg",
     height = 6,width = 8,units = 'in',res=720)
ggsurvplot(survfit(Surv(Survival_time, Overall_survival) ~ COL14A1,
                   data = survplotdata),
           data = survplotdata,
           risk.table = TRUE,
           pval = TRUE,
           break.time.by = 10,
           ggtheme = theme_minimal(),
           risk.table.y.text.col = TRUE,
           risk.table.y.text = FALSE)
dev.off()
###############################################################
##PLOT3 MOXD1
jpeg("Expression of MOXD1 impact on bladder cancer survival.jpeg",
     height = 6,width = 8,units = 'in',res=720)
ggsurvplot(survfit(Surv(Survival_time, Overall_survival) ~ MOXD1,
                   data = survplotdata),
           data = survplotdata,
           risk.table = TRUE,
           pval = TRUE,
           break.time.by = 10,
           ggtheme = theme_minimal(),
           risk.table.y.text.col = TRUE,
           risk.table.y.text = FALSE)
dev.off()

################################################################
jpeg("Expression of FAM107A impact on bladder cancer survival.jpeg",
     height = 6,width = 8,units = 'in',res=720)
ggsurvplot(survfit(Surv(Survival_time, Overall_survival) ~ FAM107A,
                   data = survplotdata),
           data = survplotdata,
           risk.table = TRUE,
           pval = TRUE,
           break.time.by = 10,
           ggtheme = theme_minimal(),
           risk.table.y.text.col = TRUE,
           risk.table.y.text = FALSE)
dev.off()

################################################################
jpeg("Expression of REM1 impact on bladder cancer survival.jpeg",
     height = 6,width = 8,units = 'in',res=720)
ggsurvplot(survfit(Surv(Survival_time, Overall_survival) ~ REM1,
                   data = survplotdata),
           data = survplotdata,
           risk.table = TRUE,
           pval = TRUE,
           break.time.by = 10,
           ggtheme = theme_minimal(),
           risk.table.y.text.col = TRUE,
           risk.table.y.text = FALSE)
dev.off()

###############################################################
