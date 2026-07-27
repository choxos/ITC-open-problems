## Figures.
.f <- grep("^--file=", commandArgs(FALSE), value = TRUE)
STUDY <- if (length(.f)) dirname(dirname(normalizePath(sub("^--file=","",.f[1])))) else normalizePath(".")
here <- function(...) file.path(STUDY, ...)
suppressPackageStartupMessages(library(ggplot2))
FIG <- here("results","figures"); dir.create(FIG, recursive=TRUE, showWarnings=FALSE)
s <- utils::read.csv(here("results","summary.csv"), stringsAsFactors=FALSE)
s$harmful <- s$coverage < 0.90
RULES <- c("fire_r_contraction","fire_r_prioronly","fire_r_powerscale","fire_r_refit","fire_composite")
LB <- c("Contraction","Prior-only","Power-scaling","Tight/loose refit","Composite")
theme_set(theme_bw(base_size=10) + theme(panel.grid.minor=element_blank(),
  strip.background=element_rect(fill="grey93", color=NA), legend.position="bottom"))

## 1. The core failure: coverage against whether the warning fired.
long <- do.call(rbind, lapply(seq_along(RULES), function(i)
  data.frame(s[,c("geometry","prior","gamma_C","mu_target","n_arm","coverage","positive_control")],
             rule=LB[i], fires=s[[RULES[i]]] >= 0.5)))
p1 <- ggplot(long, aes(100*coverage, fill=fires)) +
  annotate("rect", xmin=-Inf, xmax=90, ymin=-Inf, ymax=Inf, fill="grey88", alpha=0.7) +
  geom_histogram(binwidth=5, boundary=0, color="white", linewidth=0.2) +
  facet_wrap(~ rule, nrow=1) +
  scale_fill_manual(values=c("grey60","#b2182b"), name="warning fires") +
  labs(x="scenario coverage (%)", y="scenarios",
       title="Do the warnings land on the analyses that are wrong?",
       subtitle="Shaded region is coverage below 90%, the study's definition of harm. Red is where the diagnostic fired.")
ggsave(file.path(FIG,"fig1-coverage-vs-warning.png"), p1, width=10, height=3.4, dpi=200)

## 2. Operating characteristics.
oc <- utils::read.csv(here("results","operating-characteristics.csv"), stringsAsFactors=FALSE)
oc$rule <- factor(LB[match(oc$rule, c("r_contraction","r_prioronly","r_powerscale","r_refit","composite"))], LB)
p2 <- ggplot(oc, aes(false_warning, sensitivity, label=rule)) +
  geom_abline(slope=1, intercept=0, linetype=3, linewidth=0.3) +
  geom_errorbar(aes(ymin=sensitivity-1.96*sens_mcse, ymax=sensitivity+1.96*sens_mcse), width=0, alpha=0.5) +
  geom_errorbarh(aes(xmin=false_warning-1.96*fwr_mcse, xmax=false_warning+1.96*fwr_mcse), height=0, alpha=0.5) +
  geom_point(size=2.4, color="#b2182b") +
  ggrepel::geom_text_repel(size=3, seed=1) +
  coord_fixed(xlim=c(0,1), ylim=c(0,1)) +
  labs(x="false-warning rate among clean scenarios", y="sensitivity among harmful scenarios",
       title="Operating characteristics", subtitle="The dotted line is chance. Bars are 95% Monte Carlo intervals.")
ggsave(file.path(FIG,"fig2-operating-characteristics.png"), p2, width=6, height=6, dpi=200)

## 3. The mechanism: more data silences the warning while the answer stays wrong.
d3 <- s[s$geometry=="disconnected" & s$gamma_C==0.40 & s$par=="Delta_CB", ]
p3 <- ggplot(d3, aes(factor(n_arm), 100*coverage, color=prior, group=prior)) +
  geom_hline(yintercept=95, linewidth=0.3) + geom_line() + geom_point(size=2) +
  geom_text(aes(label=sprintf("warn %.2f", fire_composite)), vjust=-1, size=2.8, show.legend=FALSE) +
  facet_wrap(~ paste0("target mean X = ", mu_target)) +
  labs(x="participants per arm", y="coverage (%)", color="prior scale",
       title="Where the diagnostics go quiet as the answer stays wrong",
       subtitle="Disconnected evidence, true interaction 0.40 against a zero-centred prior. Labels are how often the composite warned.")
ggsave(file.path(FIG,"fig3-mechanism.png"), p3, width=8, height=4, dpi=200)
cat("wrote 3 figures\n")
