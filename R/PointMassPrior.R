#' Univariate discrete point mass priors
#'
#' \code{PointMassPrior} is a sub-class of \code{\link[=Prior-class]{Prior}}
#' representing a univariate prior over a discrete set of points with positive
#' probability mass.
#'
#' @slot theta cf. parameter 'theta'
#' @slot mass cf. parameter 'mass'
#'
#' @seealso To represent continuous prior distributions use \code{\link{ContinuousPrior}}.
#'
#' @aliases PointMassPrior
#' @exportClass PointMassPrior
setClass("PointMassPrior", representation(
        theta = "numeric",
        mass  = "numeric"
    ),
    contains = "Prior")



#' @param theta numeric vector of pivot points with positive prior mass
#' @param mass numeric vector of probability masses at the pivot points
#'     (must sum to 1)
#'
#' @return an object of class \code{PointMassPrior}
#'
#' @examples
#' PointMassPrior(c(0, .5), c(.3, .7))
#'
#' @rdname PointMassPrior-class
#' @export
PointMassPrior <- function(theta, mass) {
    if (sum(mass) != 1)
        stop("mass must sum to one")
    new("PointMassPrior", theta = theta, mass = mass)
}


#' @examples
#' bounds(PointMassPrior(c(0, .5), c(.3, .7)))
#' # > 0.3 0.7
#'
#' @rdname bounds
#' @export
setMethod("bounds", signature("PointMassPrior"),
    function(dist, ...) range(dist@theta))


#' @examples
#' expectation(PointMassPrior(c(0, .5), c(.3, .7)), identity)
#' # > .35
#'
#' @rdname expectation
#' @export
setMethod("expectation", signature("PointMassPrior", "function"),
    function(dist, f, ...) sum(dist@mass * sapply(dist@theta, f, ...)) )


#' @examples
#' tmp <- condition(PointMassPrior(c(0, .5), c(.3, .7)), c(-1, .25))
#' expectation(tmp, identity) # 0
#'
#' @rdname condition
#' @export
setMethod("condition", signature("PointMassPrior", "numeric"),
    function(dist, interval, ...) {
        if (length(interval) != 2)
            stop("interval must be of length 2")
        if (any(!is.finite(interval)))
            stop("interval must be finite")
        if (diff(interval) < 0)
            stop("interval[2] must be larger or equal to interval[1]")
        epsilon <- sqrt(.Machine$double.eps)
        # find indices of pivots wihtin interval (up to machine precision!)
        idx <- (interval[1] - dist@theta <= epsilon) & (dist@theta - interval[2] <= epsilon)
        # re-normalize and return
        return(PointMassPrior(
            dist@theta[idx], dist@mass[idx] / sum(dist@mass[idx])
        ))
    })


#' @examples
#' predictive_pdf(Normal(), PointMassPrior(.3, 1), 1.5, 20) # ~.343
#'
#' @rdname predictive_pdf
#' @export
setMethod("predictive_pdf", signature("DataDistribution", "PointMassPrior", "numeric"),
    function(dist, prior, x1, n1, ...) {
        k   <- length(prior@theta)
        res <- numeric(length(x1))
        for (i in 1:k) {
            res <- res + prior@mass[i] * probability_density_function(dist, x1, n1, prior@theta[i]) # must be implemented
        }
        return(res)
    })


#' @examples
#' predictive_cdf(Normal(), PointMassPrior(.0, 1), 0, 20) # .5
#'
#' @rdname predictive_cdf
#' @export
setMethod("predictive_cdf", signature("DataDistribution", "PointMassPrior", "numeric"),
    function(dist, prior, x1, n1, ...) {
        k   <- length(prior@theta)
        res <- numeric(length(x1))
        for (i in 1:k) {
            res <- res + prior@mass[i] * cumulative_distribution_function(dist, x1, n1, prior@theta[i])
        }
        return(res)
    })


#' @examples
#' posterior(Normal(), PointMassPrior(0, 1), 2, 20)
#'
#' @rdname posterior
#' @export
setMethod("posterior", signature("DataDistribution", "PointMassPrior", "numeric"),
    function(dist, prior, x1, n1, ...) {
        mass <- prior@mass * sapply(prior@theta, function(theta) probability_density_function(dist, x1, n1, theta))
        mass <- mass / sum(mass) # normalize
        return(PointMassPrior(prior@theta, mass))
    })



#' @rdname PointMassPrior-class
#' @param object object of class \code{PointMassPrior}
#' @export
setMethod("show", signature(object = "PointMassPrior"),
          function(object) cat(class(object)[1]))
