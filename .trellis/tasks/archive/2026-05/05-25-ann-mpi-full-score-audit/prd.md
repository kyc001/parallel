# ANN MPI full-score audit and reinforcement

## Goal

Strengthen the `ann-mpi/` submission for a full-score target by checking every
assignment requirement against code, scripts, and reproducible results, then
closing high-value gaps.

## Requirements

- Produce a detailed requirement-to-evidence checklist for the MPI ANN lab.
- Preserve the already validated IVF-PQ MPI + OpenMP path.
- Preserve the already validated block-HNSW graph-index path.
- Add an IVF + HNSW nested graph-index path when it can reuse existing local
  code safely, so graph-index coverage is stronger than a single option.
- Add a low-risk HNSW-on-HNSW graph combination path to cover the assignment's
  "other combination strategy" option and document its recall-latency trade-off.
- Keep the official submission path based on manual `mpic++` build and
  `qsub_mpi.sh`; do not restore old copied `test.sh` / `qsub.sh`.
- Keep Windows local and Kunpeng runs reproducible with scripts and recorded
  result files.
- Add report-ready evidence for:
  - MPI base-vector partitioning and load balance;
  - query broadcast and candidate gather / rank-0 merge;
  - hybrid MPI + OpenMP;
  - communication plus merge overhead;
  - recall-latency trade-off;
  - cross-platform comparison.

## Acceptance Criteria

- [ ] `main.cc` supports IVF-PQ, block-HNSW, IVF+HNSW nested, and
      HNSW-on-HNSW modes with stable output fields.
- [ ] `qsub_mpi.sh` can run all selected full-score algorithms in PBS with
      parameter overrides.
- [ ] Local and Kunpeng smoke scripts include the strengthened graph-index
      coverage.
- [ ] At least one local validation run confirms the new mode compiles and
      runs.
- [ ] A detailed full-score checklist under `ann-mpi/results/` maps assignment
      bullets to file/line evidence and result files.
- [ ] No generated build artifacts remain in `ann-mpi/`.

## Notes

- User explicitly requested "目标追求满分！！详细对照要求！！".
