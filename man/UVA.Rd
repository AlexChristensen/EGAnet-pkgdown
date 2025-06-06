% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/UVA.R
\name{UVA}
\alias{UVA}
\title{Unique Variable Analysis}
\usage{
UVA(
  data = NULL,
  network = NULL,
  n = NULL,
  key = NULL,
  uva.method = c("MBR", "EJP"),
  cut.off = 0.25,
  reduce = TRUE,
  reduce.method = c("latent", "mean", "remove", "sum"),
  auto = TRUE,
  verbose = FALSE,
  ...
)
}
\arguments{
\item{data}{Matrix or data frame.
Should consist only of variables to be used in the analysis.
Can be raw data or a correlation matrix.
Defaults to \code{NULL}}

\item{network}{Symmetric matrix or data frame.
A symmetric network.
Defaults to \code{NULL}

If both \code{data} and \code{network} are provided,
then \code{UVA} will use the \code{network}
with the \code{data} (rather than estimating a
network from the \code{data})}

\item{n}{Numeric (length = 1).
Sample size if \code{data} provided is a correlation matrix.
Defaults to \code{NULL}}

\item{key}{Character vector (length = \code{ncol(data)}).
Item key for labeling variables in the results}

\item{uva.method}{Character (length = 1).
Whether the method described in Christensen, Garrido, and
Golino (2023) publication in \emph{Multivariate Behavioral Research}
(\code{"MBR"}) or Christensen, Golino, and Silvia (2020) publication
in \emph{European Journal of Personality} (\code{"EJP"}) should be used.
Defaults to \code{"MBR"}

Based on simulation and accumulating empirical evidence, the methods
described in Christensen, Golino, and Silvia (2020) such as
adaptive alpha are \strong{outdated}. Evidence supports using a
single cut-off value (regardless of continuous, polytomous, or
dichotomous data; Christensen, Garrido, & Golino, 2023)}

\item{cut.off}{Numeric (length = 1).
Cut-off used to determine when pairwise \code{\link[EGAnet]{wto}}
values are considered locally dependent (or redundant).
Must be values between \code{0} and \code{1}.
Defaults to \code{0.25}

This cut-off value is \strong{recommended} and based on extensive simulation
(Christensen, Garrido, & Golino, 2023). Printing the result will
provide a gradient of pairwise redundancies in increments of 0.20,
0.25, and 0.30. Use \code{print} or \code{summary} on the output
rather than adjusting this cut-off value}

\item{reduce}{Logical (length = 1).
Whether redundancies should be reduced in data.
Defaults to \code{TRUE}}

\item{reduce.method}{Character (length = 1).
Method to reduce redundancies.
Available options:

\itemize{

\item \code{"latent"} --- Computes latent variables using \code{\link[lavaan]{cfa}} when
there are three or more redundant variables. If variables are not
all coded in the same direction, then they will be recoded as necessary.
A warning will be produced for all variables that are flipped

\item \code{"mean"} --- Computes mean of redundant variables. If variables are not all coded in the
same direction, then they will be recoded as necessary.
A warning will be produced for all variables that are flipped

\item \code{"remove"} --- Removes all but one variable from a set of redundant variables

\item \code{"sum"} --- Computes sum of redundant variables. If variables are not all coded in the
same direction, then they will be recoded as necessary.
A warning will be produced for all variables that are flipped

}}

\item{auto}{Logical (length = 1).
Whether \code{reduce} should occur automatically. For
\code{reduce.method = "remove"}, the automated decision
process is as follows:

\itemize{

\item \code{Two variables} --- The variable with the lowest maximum \code{\link[EGAnet]{wto}}
to all other variables (other than the one it is redundant with)
is retained and the other is removed

\item \code{Three or more variables} --- The variable with the highest mean \code{\link[EGAnet]{wto}}
to all other variables that are redundant with one another
is retained and all others are removed

}}

\item{verbose}{Boolean (length = 1).
Whether messages and (insignificant) warnings should be output.
Defaults to \code{FALSE} (silent calls).
Set to \code{TRUE} to see all messages and warnings for every function call}

\item{...}{Additional arguments that should be passed on to
old versions of \code{UVA} or to
\code{\link[EGAnet]{EGA}} and
\code{\link[lavaan]{cfa}}}
}
\description{
Identifies locally dependent (redundant) variables in a
multivariate dataset using the \code{\link[EGAnet]{EBICglasso.qgraph}}
network estimation method and weighted topological overlap
(see Christensen, Garrido, & Golino, 2023 for more details)
}
\examples{
# Perform UVA
uva.wmt <- UVA(wmt2[,7:24])

# Show summary
summary(uva.wmt)

}
\references{
\strong{Most recent simulation and implementation} \cr
Christensen, A. P., Garrido, L. E., & Golino, H. (2023).
Unique variable analysis: A network psychometrics method to detect local dependence.
\emph{Multivariate Behavioral Research}.

\strong{Conceptual foundation and outdated methods} \cr
Christensen, A. P., Golino, H., & Silvia, P. J. (2020).
A psychometric network perspective on the validity and validation of personality trait questionnaires.
\emph{European Journal of Personality}, \emph{34}(6), 1095-1108.

\strong{Weighted topological overlap} \cr
Nowick, K., Gernat, T., Almaas, E., & Stubbs, L. (2009).
Differences in human and chimpanzee gene expression patterns define an evolving network of transcription factors in brain.
\emph{Proceedings of the National Academy of Sciences}, \emph{106}, 22358-22363.

\strong{Selection of CFA Estimator} \cr
Rhemtulla, M., Brosseau-Liard, P. E., & Savalei, V. (2012).
When can categorical variables be treated as continuous? A comparison of robust continuous and categorical SEM estimation methods under suboptimal conditions.
\emph{Psychological Methods}, \emph{17}(3), 354-373.
}
