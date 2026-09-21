# BimodalErrorDistribution — working notes

Resume with: "read BimodalErrorDistribution/NOTES.md and continue".
Keep this short: current state, decisions (with why), open items. Update at the end of each work block.

## ExtentErrorDetectionAnalysis.m

**What it does:** subject × EF-visit grid (rows = patients, 3 columns = 1st/2nd/3rd EF visit).
Each cell = 4 direction axes (D0 D1 / D2 D3) showing launch-aligned extent error vs time:
single trials, mean ± 2 SD band, launch phase of the mean in black. One shared y axis.
Scan of all visits is cached in the workspace as `EFGridScan` (`FORCE_RESCAN = true` to reload).

### "Didn't move" grey flag (added 2026-09-21)
- A direction axes gets a **light grey background** when the **last point of the plotted mean
  curve** (far right) is **≤ `FlagOpts.threshold`**.
- Options block `FlagOpts` near the top: `show`, `threshold`, `color`. Threshold is in `UNIT`
  (use cm values if `UNIT = 'cm'`).
- Footer (acts as the legend) gets a second line explaining the grey background, built from
  `FlagOpts`, so it always shows the current threshold.
- Console prints one line per flagged axes: `E-16 V3 D2 | flagged: mean end = -0.094 m, n = 12`.
- Implementation: `PlotMeanBand` returns `endInfo` (`meanEnd = mu(end)`, `t`, `vals` = trial
  values averaged at that last point); `IsFlaggedEnd(endInfo, flagOpts)` applies the threshold.

**Decisions / why**
- Use the end of the **mean curve**, not each raw trial's last sample (user's choice).
- First version used a one-sided t-test (mean < 0, p < 0.05, and mean < −1 cm). **Dropped**: it
  flagged panels that only slightly undershoot. The goal is to catch patients who barely moved
  (−0.1 m ≈ never left the start, target ~10 cm away), so a plain threshold fits better.
- Threshold history: −0.08 → −0.06 → **−0.05 (current)**.

### Open items
- A panel whose mean ends at ≈ −0.045 m (a V6 cell) is *not* flagged at −0.05. It is correctly
  above the threshold, but visually looks like it should be grey. Options: set the threshold to
  about −0.04, or add an option to print the mean end value of **every** panel and pick the
  threshold from the real distribution (offered, not done yet).
- Line 77 comment is out of date ("FlagOpts.threshold is the tolerance"); tidy when the
  threshold is settled.
