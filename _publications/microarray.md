---
title: "Differential Expression Analysis for the Identification of Survival
Associated Genes in Primary Bladder Cancer using Microarray Data"
collection: publications
permalink: /publication/2021-03-04-paper-two
excerpt: ''
date: 2021-03-04
venue: 'IJURCA: International Journal of Undergraduate Research & Creative Activities'
paperurl: 'http://doi.org/10.7710/2168-0620.0306'
citation: 'Okutse, A., & Nyongesa, K. (2021). Differential Expression Analysis for the Identification of Survival Associated Genes in Primary Bladder Cancer using Microarray Data. <i>International Journal of Undergraduate Research and Creative Activities, 13</i>(1).'
---
**Keywords:** Gene expression, Primary bladder cancer survival, Prognosis, Biological markers, Transcriptomics, Bioinformatics, Survival analysis, Microarray data analysis.

## Abstract

Bladder cancer (BC) is a highly malignant and malevolent type of tumor whose incidence and
mortality worldwide remains high. This paper aimed to identify the differentially expressed genes
(DEGs) between normal and primary bladder cancer samples, which might be of prognostic value,
and evaluate their association to clinical outcomes (survival) in patients with primary bladder
cancer. 

A sample of 256 gene expression profiles, of which 10 were normal bladder mucosae,
whereas 165 were primary bladder cancer tissues, were downloaded from the gene expression
omnibus (GEO). The limma package in R was used to perform screening for DEGs after variance
reduction through quantile normalization and log2 transformation. Gene Ontology (GO), KEGG
enrichment analysis, and Network analysis were performed to determine the functions of these
DEGs. Cox proportional hazard regression model was then used to determine the association
between the top selected DEGs and overall primary bladder cancer survival. Selected genes were
then encoded as either low, middle, or high expression, and Kaplan-Meier plots were then used to
visualize the effect of these expression levels for the selected five genes on bladder cancer survival
probability. 

This study identified a total of 5 979 DEGs where 2 878 were upregulated, 3 101 were
downregulated, and 37 169 were not significantly expressed differently. Cox proportional hazard
stepwise regression models revealed several DEGs that have a statistically significant association
with bladder cancer. The selected five DEGs associated with survival were EDNRB (HR=1.9858,
95%CI 1.4965–2.6350), COL14A1 (HR=1.5335, 95%C1 1.1670–2.0151), MOXD1 (HR=1.4878,
95%CI 1.1070–1.9996), FAM107A (HR=1.4970, 95%CI 1.1162–2.0077), and REM1
(HR=1.5999, 95%CI 1.2422–2.0605). After encoding these genes as either low, middle, or high
expression, high expression of both EDNRB, COL14A1, FAM107A, and REM1 were found to
result in statistically significant reductions in survival probabilities of patients (p<0.05).
Contrastingly, high expression of MOXD1 did not contribute to a statistically significant reduction
in patients' survival probability (p>0.05). 

The genes found in this study could provide useful insight
into understanding the association between the identified DEGs and primary bladder cancer
survival, which can further inform future studies and clinical therapies.

[Download Paper](https://okutse.github.io/files/paper-two.pdf) <br>
[R Script](https://github.com/okutse/okutse.github.io/blob/main/files/paper-two-RSurv.R) <br>
[View Markdown Notebook](https://github.com/okutse/okutse.github.io/blob/main/files/paper-two-RSurv.Rmd)
