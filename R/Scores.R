# evaluate a score (both conditional and unconditional)
setGeneric("evaluate", function(s, design, ...) standardGeneric("evaluate"))


setClass("AbstractConditionalScore")

setMethod("evaluate", signature("AbstractConditionalScore", "Design"),
          function(s, design, x1, ...) stop("not implemented"))


setClass("ConditionalScore", representation(
        distribution = "DataDistribution",
        prior = "Prior"
    ),
    contains = "AbstractConditionalScore")

# must implement evaluate with additional argument x1!
setMethod("evaluate", signature("ConditionalScore", "Design"),
          function(s, design, x1, ...) stop("not implemented"))

# better name? integrate a conditional score with respect to X1
setGeneric("integrate",
           function(s, ...) standardGeneric("integrate")
)

# essentialy just changes class and stores conditional score to allow
# different implementation of 'evaluation'
setMethod("integrate", signature("ConditionalScore"),
          function(s, ...) new("IntegralScore", cs = s) )

setMethod("+", signature("ConditionalScore", "numeric"),
          function(e1, e2) AffineConditionalScore(list(e1), 1, e2) )
setMethod("+", signature("numeric", "ConditionalScore"),
          function(e1, e2) e2 + e1 )

## TODO: check for duplicate scores and combine!
setMethod("+", signature("ConditionalScore", "ConditionalScore"),
          function(e1, e2) AffineConditionalScore(list(e1, e2), c(1, 1), 0) )

setMethod("*", signature("ConditionalScore", "numeric"),
          function(e1, e2) AffineConditionalScore(list(e1), e2, 0) )
setMethod("*", signature("numeric", "ConditionalScore"),
          function(e1, e2) e2 * e1 )



setClass("UnconditionalScore")

setMethod("evaluate", signature("UnconditionalScore", "Design"),
          function(s, design, specific = TRUE, ...) stop("not implemented") )

# allow custom implementation of evaluate() depending on design
setGeneric(".evaluate", function(s, design, ...) standardGeneric(".evaluate"))

setMethod(".evaluate", signature("UnconditionalScore", "Design"),
          function(s, design, ...) stop("not implemented") )

setMethod("+", signature("UnconditionalScore", "numeric"),
          function(e1, e2) AffineUnconditionalScore(list(e1), 1, e2) )
setMethod("+", signature("numeric", "UnconditionalScore"),
          function(e1, e2) e2 + e1 )

## TODO: check for duplicate scores and combine!
setMethod("+", signature("UnconditionalScore", "UnconditionalScore"),
          function(e1, e2) AffineUnconditionalScore(list(e1, e2), c(1, 1), 0) )

setMethod("*", signature("UnconditionalScore", "numeric"),
          function(e1, e2) AffineUnconditionalScore(list(e1), e2, 0) )
setMethod("*", signature("numeric", "UnconditionalScore"),
          function(e1, e2) e2 * e1 )




setClass("IntegralScore", representation(
        cs = "ConditionalScore"
    ),
    contains = "UnconditionalScore")

# generic evaluation of integral score, this is where the problems lie ;)
# uses stats::integrate to integrate conditional score over Z1, not working for
# optimization - need custom implementation for signature("IntegralScore", "BSDesign")
setMethod("evaluate", signature("IntegralScore", "Design"),
          function(s, design, specific = TRUE, ...) {
              # TODO: currently ignores the possibility of early stopping/uncontinuus
              # conditional scores - might get better when checking for early stopping
              # and integrating separately!
              if (specific) { # use design-specific implementation
                  return(.evaluate(s, design, ...))
              } else {
                  # use generic approach
                  # integrand is the conditional score as function of z1 times the
                  # predictive pdf given the scores prior
                  integrand <- function(x1) evaluate(s@cs, design, x1, ...) *
                      predictive_pdf(s@cs@distribution, s@cs@prior, x1, n1(design), ...)
                  # get integration bounds as quantiles using lower and upper bounds on prior
                  x1_bounds <- c(
                      quantile(s@cs@distribution, .0005, n1(design), bounds(s@cs@prior)[1]),
                      quantile(s@cs@distribution, .9995, n1(design), bounds(s@cs@prior)[2])
                  )
                  # use adaptive quadrature to integrate - only relies on generic interface
                  # provided by 'Design', no special optimization for particular
                  # design implementation
                  return(stats::integrate(integrand, x1_bounds[1], x1_bounds[2])$value)
              }
          })