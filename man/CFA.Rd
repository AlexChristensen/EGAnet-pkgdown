% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/CFA.R
\name{CFA}
\alias{CFA}
\title{CFA Fit of \code{\link[EGAnet]{EGA}} or \code{\link[EGAnet]{hierEGA}} Structure}
\usage{
CFA(ega.obj, data, estimator, plot.CFA = TRUE, layout = "spring", ...)
}
\arguments{
\item{ega.obj}{An \code{\link[EGAnet]{EGA}} object or 
an \code{\link[EGAnet]{hierEGA}}}

\item{data}{Matrix or data frame.
Should consist only of variables to be used in the analysis}

\item{estimator}{The estimator used in the confirmatory factor analysis.
'WLSMV' is the estimator of choice for ordinal variables.
'ML' or 'WLS' for interval variables.
See \code{\link[lavaan]{lavOptions}} for more details}

\item{plot.CFA}{Logical.
Should the CFA structure with its standardized loadings be plot?
Defaults to TRUE}

\item{layout}{Layout of plot (see \code{\link[semPlot]{semPaths}}).
Defaults to "spring"}

\item{...}{Arguments passed to \code{\link[lavaan]{cfa}}}
}
\value{
Returns a list containing:

\item{fit}{Output from \code{\link[lavaan]{cfa}}}

\item{summary}{Summary output from \code{\link[lavaan]{lavaan-class}}}

\item{fit.measures}{Fit measures: chi-squared,
degrees of freedom, p-value, CFI, RMSEA, GFI, and NFI.
Additional fit measures can be applied using the
\code{\link[lavaan]{fitMeasures}} function (see examples)}
}
\description{
Verifies the fit of the structure suggested by 
\code{\link[EGAnet]{EGA}} or by \code{\link[EGAnet]{hierEGA}} using 
confirmatory factor analysis
}
\examples{
# Load data
wmt <- wmt2[,7:24]

\dontrun{
# Estimate EGA
ega.wmt <- EGA(
  data = wmt,
  plot.EGA = FALSE # No plot for CRAN checks
)

# Fit CFA model to EGA results
cfa.wmt <- CFA(
  ega.obj = ega.wmt, estimator = "WLSMV",
  plot.CFA = FALSE, # No plot for CRAN checks
  data = wmt
)

# Additional fit measures
lavaan::fitMeasures(cfa.wmt$fit, fit.measures = "all")}

}
\references{
\strong{Demonstrative use} \cr
Christensen, A. P., Gross, G. M., Golino, H., Silvia, P. J., & Kwapil, T. R. (2019).
Exploratory graph analysis of the Multidimensional Schizotypy Scale.
\emph{Schizophrenia Research}, \emph{206}, 43-51.

\strong{Initial implementation} \cr
Golino, H., & Epskamp, S. (2017).
Exploratory graph analysis: A new approach for estimating the number of dimensions in psychological research.
\emph{PLoS ONE}, \emph{12}, e0174035.
}
\author{
Hudson F. Golino <hfg9s at virginia.edu>
}
