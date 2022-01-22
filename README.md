DDIWAS R package
====================

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4251662.svg)](https://doi.org/10.5281/zenodo.4251662)

Introduction
============
Use this R package to perform Drug-Drug Interaction Wide Association Study (DDIWAS) experiments with electronic health record (EHR) data.  

Installation
============
To install the latest development version directly from GitHub, use:

```r
#Install required packages
install.packages(c("devtools","tidyverse","broom","glue","varhandle","logistf"))

devtools::install_github("pwatrick/ddiwas")
```

User Documentation
==================
* Documentation can be found on the [package website](https://pwatrick.github.io/ddiwas/).  
* Learn to extract EHR data for DDIWAS [vignette](https://pwatrick.github.io/ddiwas/articles/extract_ehr_data.html).  
* Learn to use the DDIWAS R package to process EHR data and statistical analysis [vignette](https://pwatrick.github.io/ddiwas/articles/ddiwas_r_package_tutorial.html).  

License
=======
Apache License 2.0  

Development
===========
This package was developed in RStudio.  

### Development status

This package is ready for use.  

Citation
===========
Patrick Wu, Scott D Nelson, Juan Zhao, Cosby A Stone Jr, QiPing Feng, Qingxia Chen, Eric A Larson, Bingshan Li, Nancy J Cox, C Michael Stein, Elizabeth J Phillips, Dan M Roden, Joshua C Denny, Wei-Qi Wei, DDIWAS: High-throughput electronic health record-based screening of drug-drug interactions, Journal of the American Medical Informatics Association, Volume 28, Issue 7, July 2021, Pages 1421–1430, https://doi.org/10.1093/jamia/ocab019
