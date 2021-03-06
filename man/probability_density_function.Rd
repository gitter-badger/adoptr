% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DataDistribution.R
\docType{methods}
\name{probability_density_function}
\alias{probability_density_function}
\alias{probability_density_function,Normal,numeric,numeric,numeric-method}
\title{Probability density function}
\usage{
probability_density_function(dist, x, n, theta, ...)


  \S4method{probability_density_function}{Normal,numeric,numeric,numeric}(dist,
  x, n, theta, ...)
}
\arguments{
\item{dist}{a univariate \code{\link[=DataDistribution-class]{distribution}} object}

\item{x}{outcome}

\item{n}{sample size}

\item{theta}{distribution parameter}

\item{...}{further optional arguments}
}
\description{
\code{probability_density_function} evaluates the probability density
function of a specific distribution \code{dist} at a point \code{x}.
}
\details{
If the distribution is \code{\link{Normal}}, then
  the mean is assumed to be
  \ifelse{html}{\out{&radic; n  theta}}{\eqn{\sqrt{n} theta}}.
}
\examples{
probability_density_function(Normal(), 1, 50, .3)

}
