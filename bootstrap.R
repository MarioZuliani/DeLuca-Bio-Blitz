# bootstrap.R — create a working R Markdown website with species pages

# ---- folders ----
dir.create("data", showWarnings = FALSE)
dir.create("species", showWarnings = FALSE)
dir.create("_templates", showWarnings = FALSE)

# ---- _site.yml ----
writeLines(c(
  'name: "DeLuca BioBlitz"',
  'output_dir: "_site"',
  'navbar:',
  '  title: "DeLuca BioBlitz"',
  '  left:',
  '    - text: "Species"',
  '      href: index.html',
  'output:',
  '  html_document:',
  '    theme: cosmo',
  '    toc: true',
  '    toc_depth: 2',
  '    toc_float: true',
  '    css: styles.css',
  'exclude:',
  '  - _templates',
  '  - render_species.R',
  '  - 00_setup.R',
  '  - build_all.R'
), "_site.yml")

# ---- styles.css ----
writeLines(c(
  ".species-photo{max-width:520px;border-radius:8px;box-shadow:0 4px 14px rgba(0,0,0,.15);margin-bottom:1rem;}",
  ".button-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:.75rem;margin-top:1rem;}",
  "a.species-btn{display:inline-block;padding:.6rem .9rem;border-radius:.6rem;text-decoration:none;background:#e9f2ff;border:1px solid #cfe0ff;}",
  "a.species-btn:hover{background:#dceaff;}"
), "styles.css")

# ---- index.Rmd (home) ----
writeLines(c(
  "---",
  'title: \"Species Index\"',
  'output: html_document',
  "---",
  "",
  "Welcome to the **DeLuca BioBlitz** site.",
  "",
  "## Browse species",
  "",
  "```{r setup, include=FALSE}",
  "knitr::opts_chunk$set(echo = FALSE, message = FALSE, warning = FALSE)",
  "```",
  "",
  "```{r species_links, echo=FALSE}",
  "if (file.exists('data/species.csv')) {",
  "  suppressPackageStartupMessages({",
  "    library(readr); library(dplyr); library(htmltools)",
  "  })",
  "  sp <- readr::read_csv('data/species.csv', show_col_types = FALSE)",
  "  if (nrow(sp)) {",
  "    tags$div(class='button-grid',",
  "      lapply(seq_len(nrow(sp)), function(i)",
  "        tags$a(href = sprintf('species/%s.html', sp$slug[i]),",
  "               class='species-btn', sp$common_name[i])",
  "      )",
  "    )",
  "  }",
  "}",
  "```"
), "index.Rmd")

# ---- sample data ----
writeLines(c(
  "slug,common_name,sci_name,class,order,family,inat_photo_url,inat_species_url,iucn_url,local_profile_url,occurrence_text,conservation_state,rarity_note,natural_history",
  "eastern-bluebird,Eastern Bluebird,Sialia sialis,Aves,Passeriformes,Turdidae,https://static.inaturalist.org/photos/XXXX/original.jpg,https://www.inaturalist.org/taxa/9176-Sialia-sialis,https://www.iucnredlist.org/species/103766554,https://myfwc.com/wildlifehabitats/profiles/birds/songbirds/eastern-bluebird/,Confirmed in 2025 UF DeLuca BioBlitz (Research Grade),IUCN: Least Concern; Florida: not listed; fairly common,Frequent breeder in pastures and open woodlands,Nest cavity nester; uses nest boxes; eats insects and berries."
), "data/species.csv")

# ---- template (_templates/species-template.Rmd) ----
writeLines(c(
  "---",
  'title: \"!expr params$common_name\"',
  "site: false",
  "output:",
  "  html_document:",
  "    toc: true",
  "    toc_float: true",
  "    css: styles.css",
  "params:",
  "  slug: NULL",
  "  common_name: NULL",
  "  sci_name: NULL",
  "  class: NULL",
  "  order: NULL",
  "  family: NULL",
  "  inat_photo_url: NULL",
  "  inat_species_url: NULL",
  "  iucn_url: NULL",
  "  local_profile_url: NULL",
  "  occurrence_text: NULL",
  "  conservation_state: NULL",
  "  rarity_note: NULL",
  "  natural_history: NULL",
  "---",
  "",
  "```{r setup, include=FALSE}",
  "knitr::opts_chunk$set(echo = FALSE, message = FALSE, warning = FALSE)",
  "p <- params",
  "```",
  "",
  "# `r p$common_name` (*`r p$sci_name`*)",
  "![](`r p$inat_photo_url`){.species-photo}",
  "",
  "## Taxonomy",
  "- **Class:** `r p$class`",
  "- **Order:** `r p$order`",
  "- **Family:** `r p$family`",
  "",
  "## Occurrence at DeLuca Preserve",
  "`r p$occurrence_text`",
  "",
  "## Conservation & rarity context",
  "- `r p$conservation_state`",
  "- **Rarity note:** `r p$rarity_note`",
  "",
  "## Natural history notes",
  "`r p$natural_history`",
  "",
  "## References / links",
  "- [iNaturalist species page](`r p$inat_species_url`)",
  "- [IUCN Red List](`r p$iucn_url`)",
  "- [Local profile](`r p$local_profile_url`)"
), "_templates/species-template.Rmd")

# ---- 00_setup.R (packages only) ----
writeLines(c(
  "# 00_setup.R — install & load everything needed",
  'pkgs <- c("rmarkdown","knitr","readr","dplyr","glue","htmltools")',
  "",
  "to_install <- setdiff(pkgs, rownames(installed.packages()))",
  "if (length(to_install)) install.packages(to_install, quiet = TRUE)",
  "",
  "invisible(lapply(pkgs, require, character.only = TRUE))"
), "00_setup.R")

# ---- render_species.R (force output to /species) ----
writeLines(c(
  "# render_species.R",
  'source("00_setup.R")',
  "",
  'sp <- readr::read_csv("data/species.csv", show_col_types = FALSE)',
  'template_path <- file.path("_templates", "species-template.Rmd")',
  'out_dir <- normalizePath("species", winslash = "/", mustWork = FALSE)',
  'if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)',
  "",
  "for (i in seq_len(nrow(sp))) {",
  "  params <- as.list(sp[i, ])",
  "  rmarkdown::render(",
  "    input       = template_path,",
  "    output_file = paste0(sp$slug[i], \".html\"),",
  "    output_dir  = out_dir,",
  "    params      = params,",
  "    envir       = new.env()",
  "  )",
  "}"
), "render_species.R")

# ---- build_all.R (one-click build) ----
writeLines(c(
  "# build_all.R — build pages, then the site, then open it",
  'source("00_setup.R")',
  'source("render_species.R")',
  "rmarkdown::render_site()",
  'browseURL(file.path(\"_site\",\"index.html\"))'
), "build_all.R")

message("Bootstrap complete! Open build_all.R and click Source to build.")
