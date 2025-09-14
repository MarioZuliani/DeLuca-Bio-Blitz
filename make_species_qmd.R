# make_species_qmd.R
library(readr)
library(glue)
library(fs)

sp <- readr::read_csv("data/species.csv", show_col_types = FALSE)

dir_create("species")

esc <- function(x) {
  x <- ifelse(is.na(x), "", x)
  gsub('"', '\\"', x, fixed = TRUE)  # escape quotes for YAML
}

# ---- ADD THIS HELPER (just once, before the loop) ----
bucket <- function(cls) {
  if (is.null(cls) || is.na(cls) || !nzchar(cls)) return("Other")
  x <- tolower(trimws(cls))
  # Plants can come from multiple botanical classes; bucket them together
  plant_classes <- c(
    "magnoliopsida","liliopsida","pinopsida","polypodiopsida",
    "gnetopsida","equisetopsida","lycopodiopsida","bryopsida"
  )
  if (x %in% plant_classes) return("Plants")
  if (x == "insecta")       return("Insects")
  # Otherwise keep zoological classes as-is (title-cased)
  tools::toTitleCase(x)   # e.g., "Aves", "Reptilia", "Mammalia", "Amphibia"
}
# ------------------------------------------------------

for (i in seq_len(nrow(sp))) {
  row <- sp[i, ]

  # robustly choose a source link (column may not exist)
  has_src <- "photo_source_url" %in% names(sp)
  photo_source <- if (has_src) row$photo_source_url else NA_character_

  source_url <- if (!is.na(photo_source) && nzchar(photo_source)) {
    photo_source
  } else if (!is.na(row$inat_species_url) && nzchar(row$inat_species_url)) {
    row$inat_species_url
  } else {
    row$inat_photo_url
  }

  # Build optional credit
  credit_html <- ""
  if (!is.na(row$photo_credit_name) && nzchar(row$photo_credit_name)) {
    name_html <- if (!is.na(row$photo_credit_url) && nzchar(row$photo_credit_url)) {
      glue('<a href="{row$photo_credit_url}">{row$photo_credit_name}</a>')
    } else {
      esc(row$photo_credit_name)
    }
    lic_html <- if (!is.na(row$photo_license) && nzchar(row$photo_license))
      glue(' ({row$photo_license})') else ""
    credit_html <- glue(
      '<figcaption class="photo-credit">Photo: {name_html}{lic_html} via <a href="{source_url}">iNaturalist</a></figcaption>'
    )
  }

  # ---- use the helper to compute the homepage heading bucket ----
  grp <- bucket(row$class)

  body <- glue('---
title: "{esc(row$common_name)} ({esc(row$sci_name)})"
slug: "{row$slug}"
group: "{grp}"
categories: ["{grp}"]
image: "{row$inat_photo_url}"        # <<< add
image-alt: "{esc(row$common_name)}"  # <<< add
freeze: true
---

<figure class="species-figure">
  <img src="{row$inat_photo_url}" alt="{esc(row$common_name)}" class="species-photo" />
  {credit_html}
</figure>

## Taxonomy
- **Class:** {esc(row$class)}
- **Order:** {esc(row$order)}
- **Family:** {esc(row$family)}

## Occurrence at DeLuca Preserve
{esc(row$occurrence_text)}

## Conservation & rarity context
- {esc(row$conservation_state)}
- **Rarity note:** {esc(row$rarity_note)}

## Natural history notes
{esc(row$natural_history)}

## References / links
- [iNaturalist species page]({row$inat_species_url})
- [IUCN Red List]({row$iucn_url})
- [Local profile]({row$local_profile_url})
')

  out_file <- file.path("species", paste0(row$slug, ".qmd"))
  writeLines(body, out_file, useBytes = TRUE)
}
