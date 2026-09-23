# Probes

## P1 null control (20 replicates)

- rmst24: RMSE of single reconstruction 0.011; sampling SD 0.483; ratio 0.024
- s12: RMSE of single reconstruction 0.0017; sampling SD 0.028; ratio 0.061
- s48: RMSE of single reconstruction 0.0034; sampling SD 0.0231; ratio 0.146

## P3 ensemble size (10 replicates, cell 4)

- rmst24: B from 20 draws / B from 60 draws, median 0.99, range 0.65 to 1.39
- s12: B from 20 draws / B from 60 draws, median 0.93, range 0.58 to 1.14
- s48: B from 20 draws / B from 60 draws, median 0.80, range 0.40 to 1.04

## P4 unit cost

- elapsed per replicate: fine 7.5 s, coarse 5.3 s (CPU 2.1 and 1.6 s) on a shared machine
- total CPU for 13 cells x 300 replicates: about 2.0 hours


P4 was timed with an earlier analyst-variant set that included the full 1500-column trace; the registered variants use at most 120 points, so the registered run is cheaper than stated.
