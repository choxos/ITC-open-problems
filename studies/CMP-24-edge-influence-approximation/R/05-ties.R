## Post hoc, exploratory: are top-study disagreements at tau = 0 near-ties, and which
## studies does the diagonal calculation promote? First 150 networks of cells 2 and 8,
## same seeds as the registered run. Writes results/ties.csv.
source("R/00-model.R"); g <- build_grid()
res <- lapply(c(2L, 8L), function(ci) { cc <- g[ci, ]
  do.call(rbind, lapply(1:150, function(k) { set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    tryCatch({ st <- simulate_y(draw_network(cc), cc$tau); full <- gls_fit(st, 0); di <- diag_influence(st, 0)
      imp <- vapply(seq_along(st), function(i) { s <- st[-i]; if (!estimable(s)) return(1); 1 - full$var / gls_fit(s, 0)$var }, 0)
      o <- sort(imp, decreasing = TRUE)
      data.frame(cell = ci, agree = which.max(di) == which.max(imp), ref_rank_of_diag_top = rank(-imp)[which.max(di)],
                 rel_gap = (imp[which.max(imp)] - imp[which.max(di)]) / imp[which.max(imp)], ties1 = sum(imp == 1), diag3 = length(st[[which.max(di)]]$arms) == 3, ref3 = length(st[[which.max(imp)]]$arms) == 3, share3 = mean(vapply(st, function(s) length(s$arms) == 3, TRUE))) }, error = function(e) NULL) })) })
r <- do.call(rbind, res)
out <- do.call(rbind, lapply(c(2L, 8L), function(ci) { z <- r[r$cell == ci, ]; w <- z[!z$agree, ]
  data.frame(cell = ci, n = nrow(z), top_disagree = mean(!z$agree), diag_top_in_ref_top2 = mean(z$ref_rank_of_diag_top <= 2),
             median_rel_gap_when_disagree = stats::median(w$rel_gap), share_rel_gap_lt_0.1_when_disagree = mean(w$rel_gap < 0.1), diag_top_three_arm_when_disagree = mean(w$diag3),
             ref_top_three_arm_when_disagree = mean(w$ref3), share_studies_three_arm = mean(z$share3)) }))
write.csv(out, "results/ties.csv", row.names = FALSE); print(out)
