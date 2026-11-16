# Dataset Guide

## Selection summary
| Dataset | Real human data | Signal | Fatigue labels | Size | Access |
|---|---|---|---|---|---|
| **DUO-GAIT** (Zenodo 8244887) | yes, 16 healthy adults | 9 IMUs, 6-min walks, gait parameters | **yes**: rested vs fatigued, single vs dual task | processed.zip 2.6 MB; interim 3.0 GB; raw 3.4 GB | open download |
| **Long-term Gait Dynamics** (PhysioNet `umwdb`) | yes, 10 healthy young men | 1-hour stride-interval series, 6 conditions | no (spontaneous vs metronome-paced only) | about 1 MB | open download |
| Gait in Aging and Disease (PhysioNet `gaitdb`) | yes | stride intervals, 15 people | no | tiny | its own page says it is a teaching collection, not for research |
| K2MUSE (arXiv 2504.14602) | yes, 30 adults | kinematics, force, EMG, ultrasound | has a muscle-fatigue condition | large, not assessed | not checked for direct download |
| Re²Load | - | - | - | - | no public source found; not available here |

**Choice.** DUO-GAIT is the only open dataset found that has documented fatigue conditions, so it is the primary
fatigue experiment. `umwdb` is the secondary real dataset: long stride series suited to DFA, SampEn, RQA and Lyapunov
analysis, but with no fatigue labels, so its task is "spontaneous vs paced walking" and the report says so.

## What `python main.py` does per dataset
1. If `output/real/<name>/features.csv` exists it is reused (no download). 2. Otherwise download to a temp folder (resumable,
checksum-checked). 3. Extract one member at a time, compute windowed features, delete the member. 4. Save features, tables,
figures, report, model. 5. Remove the temp folder (unless `preserve_raw: true` or `--no-cleanup`).
Peak extra disk use is the archive (2.6 MB for the default DUO-GAIT file) or one stride file at a time for `umwdb`.

## Sources, citations, licences
- **DUO-GAIT**: Zhou L, Fischer E, Brahms CM, Granacher U, Arnrich B. *DUO-GAIT: A gait dataset for walking under dual-task and fatigue conditions with inertial measurement units.* Sci Data 10, 543 (2023). doi:10.1038/s41597-023-02391-w. Data: doi:10.5281/zenodo.8244887 (v3). **Licence: the record has a LICENSE file whose text I could not read. Read it before use.**
- **umwdb**: Hausdorff JM et al. *Fractal dynamics of human gait: stability of long-range correlations in stride interval fluctuations.* J Appl Physiol 80:1448-1457 (1996); PhysioNet (Goldberger et al., Circulation 101(23):e215-e220, 2000). The licence was not stated on the page I could read; check the dataset page.

## Variables and labels
- `umwdb`: files `si01`-`si10` x extensions `norm/slow/fast` (spontaneous) and `metnrm/metslw/metfst` (metronome-paced). One stride interval (seconds) per stride. Label = condition from the extension.
- `duo_gait`: the processed archive holds per-stride files such as `processed/OG_st_fatigue/sub_13/left_foot_core_params.csv` (seen on a real run). Only `*foot_core_params.csv` files are analysed (`aggregate_params.csv` is one summary row).
  Labels come from `label_rules` applied to the path: folders `OG_st_fatigue`/`OG_dt_fatigue` = fatigued; `OG_st_control`/`OG_dt_control` = rested (names confirmed from a real run; `st` = single task, `dt` = dual task is inferred from the paper). If the run prints a `[labels] ... matched NO label rule` line, or only one class is found, run `python main.py --inspect duo_gait`, look at the folder names, and edit `label_rules`.
  Signals: stride time is derived from the `timestamps` column (difference between consecutive values) plus the first non-counter column (e.g. stride length). Counter columns such as `stride_index` are ignored automatically. One 6-minute walk has only about 300 strides per foot, so this dataset uses 128-stride windows.
- `duo_gait_raw` (3.4 GB, disabled by default): read straight from Zenodo using HTTP range requests, so the archive is never stored; only `max_members` files are processed. Needs `--yes` because it exceeds the size limit.

## Integrity checks
- `umwdb`: SHA-256 from the server's `SHA256SUMS`; if unreachable, a warning is printed.
- `duo_gait`: MD5 from the Zenodo record (processed.zip `59262239edaab480115ee5dd553587ee`). Range-read archives rely on per-file CRC checks.

## Your own / authorised data (for example Re²Load, if you obtain it)
Set `datasets: [local_folder]`, fill in `path`, `subject_regex`, `label_rules`, `fs` in `config/datasets.yaml`. Files are read in place, never copied or deleted. Do not use data you are not authorised to hold.

## Limitations
- Saved features are reused only while the dataset settings are unchanged; any change to settings recomputes automatically.
- 10 to 16 participants: wide uncertainty; leave-one-subject-out is used to avoid leakage.
- DUO-GAIT fatigue is induced by a lab protocol in healthy adults; results do not transfer automatically to load carriage or clinical fatigue.
- `umwdb` has no fatigue labels: do not interpret its results as fatigue prediction. Fatigue-labelled long stride series, or Re²Load data, would be needed.
- Nonlinear estimates on 256-sample windows are noisy; defaults (m, r, window) are adjustable in `config/config.yaml`.
- Not implemented: LSTM, multiscale entropy, partial-dependence plots and independent-dataset validation (needs a second labelled dataset). SHAP and XGBoost are used when installed; otherwise skipped with a message.

## Secure handling of authorised data
See the encryption section of `README.md` (AES-256-GCM, key kept outside the project, plaintext only in a temporary folder and wiped after use).
