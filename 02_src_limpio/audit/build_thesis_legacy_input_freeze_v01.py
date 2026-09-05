"""Build the immutable HB200 input cohort before any model evaluation."""

from __future__ import annotations

import csv
import hashlib
import json
import sys
from pathlib import Path

import numpy as np
from scipy.io import loadmat, savemat


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest().upper()


def nondominated(values: np.ndarray) -> np.ndarray:
    keep = np.ones(values.shape[0], dtype=bool)
    for i in range(values.shape[0]):
        for j in range(values.shape[0]):
            if i != j and np.all(values[j] <= values[i]) and np.any(values[j] < values[i]):
                keep[i] = False
                break
    return keep


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: build_thesis_legacy_input_freeze_v01.py REPO_ROOT OUTPUT_DIR")

    root = Path(sys.argv[1]).resolve()
    out = Path(sys.argv[2]).resolve()
    tables = out / "tables"
    mats = out / "mat"
    audit = out / "audit"
    figures = out / "figures"
    logs = out / "logs"
    for directory in (tables, mats, audit, figures, logs):
        directory.mkdir(parents=True, exist_ok=False if directory == tables else True)

    pop_path = root / "03_original_model" / "05_outputs_historicos" / "final_pop_HB200.mat"
    score_path = root / "03_original_model" / "05_outputs_historicos" / "scores_HB200.mat"
    population = np.asarray(loadmat(pop_path)["population"], dtype=np.float64)
    scores = np.asarray(loadmat(score_path)["scores"], dtype=np.float64)

    if population.shape != (50, 3) or scores.shape != (50, 3):
        raise RuntimeError(f"Unexpected HB200 shapes: X={population.shape}, F={scores.shape}")
    finite = np.isfinite(population).all(axis=1)
    if not finite.all():
        raise RuntimeError("HB200 contains nonfinite decision rows")

    first_by_key: dict[tuple[float, ...], int] = {}
    members_by_key: dict[tuple[float, ...], list[int]] = {}
    for row_index, row in enumerate(population):
        key = tuple(float(v) for v in row)
        first_by_key.setdefault(key, row_index)
        members_by_key.setdefault(key, []).append(row_index)

    source_rows = sorted(first_by_key.values())
    unique_x = population[source_rows, :]
    unique_f = scores[source_rows, :]
    duplicate_count = np.array(
        [len(members_by_key[tuple(float(v) for v in population[i])]) for i in source_rows], dtype=np.int64
    )

    for first in source_rows:
        members = members_by_key[tuple(float(v) for v in population[first])]
        if not np.all(scores[members, :] == scores[first, :]):
            raise RuntimeError(f"Duplicate X rows have inconsistent historical scores: {[m + 1 for m in members]}")

    hist_nd = nondominated(unique_f)
    pop_hash = sha256(pop_path)
    score_hash = sha256(score_path)
    compromise_target = np.array([0.0772835810847959, 66.83947412244014, 0.33527438350425476])
    compromise_matches = np.flatnonzero(np.all(unique_x == compromise_target, axis=1))
    if compromise_matches.size != 1:
        raise RuntimeError(f"Expected one exact thesis compromise; found {compromise_matches.size}")
    compromise_index = int(compromise_matches[0])

    fields = [
        "THESIS_ID", "SOURCE_ARCHIVE", "SOURCE_ROW", "m_max", "T_min", "r_rec",
        "historical_timing_semantics", "mapped_t_rec", "historical_F1_if_available",
        "historical_F2_if_available", "historical_F3_if_available",
        "historical_ND_status_if_recoverable", "duplicate_count", "source_file", "source_hash",
    ]
    rows: list[dict[str, object]] = []
    for i, source_index in enumerate(source_rows):
        rows.append(
            {
                "THESIS_ID": f"T{i + 1:03d}",
                "SOURCE_ARCHIVE": "HB200",
                "SOURCE_ROW": source_index + 1,
                "m_max": format(unique_x[i, 0], ".17g"),
                "T_min": format(unique_x[i, 1], ".17g"),
                "r_rec": format(unique_x[i, 2], ".17g"),
                "historical_timing_semantics": "FIXED_FROM_START",
                "mapped_t_rec": "0",
                "historical_F1_if_available": format(unique_f[i, 0], ".17g"),
                "historical_F2_if_available": format(unique_f[i, 1], ".17g"),
                "historical_F3_if_available": format(unique_f[i, 2], ".17g"),
                "historical_ND_status_if_recoverable": "YES" if hist_nd[i] else "NO",
                "duplicate_count": int(duplicate_count[i]),
                "source_file": f"{pop_path.relative_to(root).as_posix()}|{score_path.relative_to(root).as_posix()}",
                "source_hash": f"{pop_hash}|{score_hash}",
            }
        )

    csv_path = tables / "THESIS_LEGACY_INPUT_FREEZE.csv"
    with csv_path.open("x", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)

    mat_path = mats / "THESIS_LEGACY_INPUT_FREEZE.mat"
    savemat(
        mat_path,
        {
            "unique_X": unique_x,
            "historical_F": unique_f,
            "source_rows": np.asarray(source_rows, dtype=np.int64) + 1,
            "duplicate_count": duplicate_count,
            "historical_ND": hist_nd.astype(np.uint8),
            "thesis_ids": np.asarray([row["THESIS_ID"] for row in rows], dtype=object),
            "mapped_t_rec": np.zeros(len(rows)),
            "source_population_sha256": pop_hash,
            "source_scores_sha256": score_hash,
        },
        do_compression=True,
    )

    metadata = {
        "SOURCE_ARCHIVE": "HB200",
        "SOURCE_ARCHIVE_CLASS": "RECOVERED_THESIS_ERA_OPTIMIZATION_CHECKPOINT",
        "SOURCE_POPULATION_SHA256": pop_hash,
        "SOURCE_SCORES_SHA256": score_hash,
        "SOURCE_ROWS": int(population.shape[0]),
        "FINITE_SOURCE_ROWS": int(finite.sum()),
        "UNIQUE_FINITE_THESIS_DESIGNS": int(unique_x.shape[0]),
        "EXACT_DUPLICATE_SOURCE_ROWS_REMOVED": int(population.shape[0] - unique_x.shape[0]),
        "HISTORICALLY_ND_DESIGNS": int(hist_nd.sum()),
        "THESIS_REPORTED_COMPROMISE_ID": rows[compromise_index]["THESIS_ID"],
        "THESIS_REPORTED_COMPROMISE_SOURCE_ROW": int(source_rows[compromise_index] + 1),
        "THESIS_RECIRCULATION_TIMING_CONTROL": "FIXED_FROM_START",
        "THESIS_T_REC_ZERO_PHYSICAL_MEANING": "IMMEDIATE_RECIRCULATION_AFTER_INITIAL_TIME_NODE",
        "INPUT_FREEZE_CSV_SHA256": sha256(csv_path),
        "INPUT_FREEZE_MAT_SHA256": sha256(mat_path),
    }
    json_path = audit / "THESIS_LEGACY_INPUT_FREEZE_MANIFEST.json"
    with json_path.open("x", encoding="utf-8") as stream:
        json.dump(metadata, stream, indent=2)
        stream.write("\n")

    print(json.dumps({**metadata, "OUTPUT_DIR": str(out)}, indent=2))


if __name__ == "__main__":
    main()
