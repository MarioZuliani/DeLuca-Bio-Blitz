# 00_setup.R — install & load everything needed
pkgs <- c("rmarkdown","knitr","readr","dplyr","glue","htmltools")

to_install <- setdiff(pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install, quiet = TRUE)

invisible(lapply(pkgs, require, character.only = TRUE))
