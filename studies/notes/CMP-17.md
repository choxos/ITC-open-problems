OUT-13 measured whether repeated reconstructions from a published Kaplan-Meier curve carry the right
uncertainty. They did not, and the direction depended on the functional. Observation-model draws, which
redraw each step's pixel position and each censoring's time within its risk-table interval, overstated
the reconstruction error of RMST to 24 months by a factor of 2 to 13 and understated it for Weibull
survival extrapolated to 48 months (ratio 0.15 to 0.77; their 90% intervals covered the true-data value
in 42% to 77% of replicates). The error itself concentrated in the tail: a single reconstruction's RMSE
was 2% to 8% of the sampling SD for RMST and 11% to 26% for 48-month survival.

Not answered: how that tail error propagates into a population-adjusted or component comparison. OUT-13
used one arm and no downstream model, so the propagation this entry asks about is untested; an ensemble
built from these draws would not repair it, since it understates exactly the component that matters there.
