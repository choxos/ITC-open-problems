## ---------------------------------------------------------------------------
## Why the summaries overlap: decompose E1's failures by cause.
##
##   Rscript R/12-decompose.R
##
## POST HOC, written after the decision file and for the manuscript. It adds no
## scenario and changes no class; it asks which failures each summary catches.
##
## Two causes of failure exist on E1 and they are separable by design factor:
##
##   tight prior    prior SD 0.1 on interactions whose true value is 0.4, so the
##                  prior pulls the estimate toward zero. This is the failure the
##                  summaries were proposed to detect: a prior-driven coordinate.
##   misspecified   prior SD 0.5 or wider, with discordance on the ecological
##                  route or synergy on the additivity route. The data identify
##                  the wrong quantity and the prior has nothing to do with it.
##
## On the identity link with known residual variance the posterior covariance is
## (I + P0)^-1, which does not involve the outcomes, so every information summary
## is a function of the design and the prior alone. A departure that shifts only
## the mean leaves them exactly unchanged. The check below measures that rather
## than asserting it.
## ---------------------------------------------------------------------------

e <- readRDS("results/e1.rds")
e$class <- ifelse(e$coverage < 0.90, "fail",
                  ifelse(abs(e$coverage - 0.95) <= 0.01, "nominal", "neither"))
e$cause <- ifelse(e$prior_sd == 0.1, "tight prior",
                  ifelse(e$discord > 0 | e$synergy > 0, "misspecified", "none"))

## Invariance: within one design and prior, the summaries do not move with the
## departure while coverage does.
keys <- c("state", "spread", "n", "prior_sd")
g <- split(e[e$state %in% c("ecological", "additivity"), ],
           e[e$state %in% c("ecological", "additivity"), keys], drop = TRUE)
inv <- do.call(rbind, lapply(g, function(z) data.frame(
  contraction = diff(range(z$contraction)),
  target_ratio = diff(range(z$target_ratio)),
  eff_rank = diff(range(z$eff_rank)),
  coverage = diff(range(z$coverage)))))
invariance <- data.frame(quantity = names(inv),
                         max_range_within_design = vapply(inv, max, 0))
stopifnot(all(invariance$max_range_within_design[1:3] == 0))

rules <- c(contraction = "warn_contraction", target_ratio = "warn_target_ratio",
           eff_rank = "warn_eff_rank", rank_screen = "warn_rank_screen")
f <- e[e$class == "fail", ]
nom <- e[e$class == "nominal", ]
dec <- do.call(rbind, lapply(names(rules), function(r) data.frame(
  rule = r,
  caught_tight_prior = mean(f[f$cause == "tight prior", rules[[r]]]),
  caught_misspecified = mean(f[f$cause == "misspecified", rules[[r]]]),
  false_alarm_nominal = mean(nom[[rules[[r]]]]))))
counts <- as.data.frame(table(cause = f$cause, state = f$state))
counts <- counts[counts$Freq > 0, ]

dir.create("results", showWarnings = FALSE)
write.csv(dec, "results/decomposition.csv", row.names = FALSE)
write.csv(counts, "results/failure-causes.csv", row.names = FALSE)
write.csv(invariance, "results/invariance.csv", row.names = FALSE)
print(invariance); print(counts); print(dec)
