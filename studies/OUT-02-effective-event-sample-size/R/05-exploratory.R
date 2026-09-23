## Exploratory, after the registered analysis: the same comparison restricted to
## replicates that produced an estimate, so zero-event replicates do not dominate.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
d <- d[d$ok == 1, ]
nc <- abs(d$est - d$truth) > 1.96 * d$se
auroc <- function(s, y) { r <- rank(c(s[y], s[!y])); ny <- sum(y); (sum(r[seq_len(ny)]) - ny * (ny + 1) / 2) / (ny * sum(!y)) }
out <- data.frame(diagnostic = c("EESS", "ESS x p-hat", "ESS"), n = nrow(d), noncoverage = mean(nc),
                  auroc = c(auroc(-d$eess, nc), auroc(-d$essp, nc), auroc(-d$ess, nc)))
write.csv(out, "results/exploratory-estimated-only.csv", row.names = FALSE); print(out)
