# render_species.R
source("00_setup.R")

sp <- readr::read_csv("data/species.csv", show_col_types = FALSE)

template_path <- file.path("_templates", "species-template.Rmd")
out_dir <- "species"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

for (i in seq_len(nrow(sp))) {
  params <- as.list(sp[i, ])
  rmarkdown::render(
    input          = template_path,
    output_file    = paste0(sp$slug[i], ".html"),
    output_dir     = out_dir,
    params         = params,
    envir          = new.env(),
    output_options = list(css = "../styles.css", self_contained = FALSE)
  )
}
