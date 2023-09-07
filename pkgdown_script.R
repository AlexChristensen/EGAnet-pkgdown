# Run once to configure package to use pkgdown
# usethis::use_pkgdown()

# Run to build the website
pkgdown::build_site()

# Iterate on colors
pkgdown::init_site()

solve(
  matrix(
    c(
      1, 0.99,
      0.99, 1
    ), nrow = 2, byrow = TRUE
  )
)
