# build_all.R — build pages, then the site, then open it
source("00_setup.R")
source("render_species.R")
rmarkdown::render_site()
browseURL(file.path("_site","index.html"))
