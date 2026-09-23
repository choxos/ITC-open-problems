## ---------------------------------------------------------------------------
## QBA-25: a bias parameter on the observed hazard ratio carried through survival
## extrapolation into incremental net benefit.
##
## Control survival: Weibull (shape 1.3, median 4 years) or, for the cure family,
## 30% cured plus the same Weibull for the rest. Trial follow-up 3 years; reported
## log hazard ratio LHR_HAT = log(0.75), SE 0.10. A bias b on the log hazard ratio
## (reported = true + b) is elicited on [-0.15, 0.15].
## Extrapolation families for the treatment effect after 3 years:
##   ph      the hazard ratio persists;
##   waning  it returns linearly to 1 between years 3 and 8;
##   cure    the hazard ratio acts on the uncured only, cure fraction unchanged.
## Economic model: 25-year horizon, 3.5% discounting, utility 0.75 per life-year,
## treatment cost COST_TX per year alive for the first 3 years, background cost
## 5000 per year alive in both arms, threshold 30000 per QALY. Incremental net
## benefit INB = 30000 dQALY - dCost.
## ---------------------------------------------------------------------------

LHR_HAT <- log(0.75); SE <- 0.10; B_MAX <- 0.15; FU <- 3; HOR <- 25; DT <- 1 / 52
SHAPE <- 1.3; SCALE <- 4 / log(2)^(1 / SHAPE); CURE <- 0.3; LAMBDA <- 30000; UTIL <- 0.75; COST_BG <- 5000
TT <- seq(DT, HOR, by = DT); DISC <- exp(-log(1.035) * TT)
H0 <- function(t) (t / SCALE)^SHAPE
surv <- function(lhr, family) {
  h <- if (family == "waning") { w <- pmin(pmax((TT - FU) / 5, 0), 1); cumsum(c(0, diff(H0(TT)) * exp(lhr * (1 - w[-1])))) + H0(TT[1]) * exp(lhr) } else H0(TT) * exp(lhr)
  s0 <- exp(-H0(TT)); s1 <- exp(-h)
  if (family == "cure") { s0 <- CURE + (1 - CURE) * s0; s1 <- CURE + (1 - CURE) * s1 }
  list(s0 = s0, s1 = s1)
}
inb <- function(lhr, family, cost_tx) { s <- surv(lhr, family)
  dly <- sum((s$s1 - s$s0) * DISC) * DT
  dcost <- cost_tx * sum((s$s1 * DISC)[TT <= FU]) * DT + COST_BG * dly
  LAMBDA * UTIL * dly - dcost }
FAMILIES <- c("ph", "waning", "cure")
## Treatment cost set so INB is zero at the reported estimate under the PH family,
## then scaled so the base case is favorable (INB > 0) by a declared margin.
COST_TX <- local({ f <- function(c) inb(LHR_HAT, "ph", c); 0.9 * stats::uniroot(f, c(0, 1e6))$root })
