# Run once to configure package to use pkgdown
# usethis::use_pkgdown()

# Run to build the website
pkgdown::build_site()

# Iterate on colors
# pkgdown::init_site()

# Make sure to remember to change the 
# .css 'text-muted' to be '#fff'

# PATH: ./docs/deps/bootstrap-5.3.1/bootstrap.min.css
# CHANGE: text-muted{--bs-text-opacity: 1;color:var(--bs-secondary-color) !important}
# TO: text-muted{--bs-text-opacity: 1;color:#fff !important}