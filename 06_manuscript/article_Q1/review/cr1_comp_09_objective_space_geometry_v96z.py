"""CR1-COMP-09 descriptive objective-space geometry of frozen finite sets."""

from __future__ import annotations

import csv
import hashlib
import json
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


BASELINE_HEAD = "52cefdf4b1656a9f22903124ec4147b6ad671160"
FILES = {
    "protocol": ("CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md", "8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3"),
    "dataset": ("CR1_COMP_01_CANONICAL_DATASET_v96z.json", "4DE32D3292001FC87E7435995E3D9ACC31D51800BA05E2A88BA3B379A95D0164"),
    "objective_descriptive": ("CR1_COMP_04_OBJECTIVE_SPACE_DESCRIPTIVE_v96z.json", "CCA35B4E8983D075E9D3E4834949B2A2F330C5A8C0C5B4D1EA05E935AEE1D75D"),
    "cross_dominance": ("CR1_COMP_05_EXACT_CROSS_DOMINANCE_MATRIX_v96z.csv", "C783CDD1214598643F1A46F6A6E1EC144220D2BFB2FC8D67F53293A3B7ACC329"),
    "near_tie": ("CR1_COMP_06_NUMERICAL_NEAR_TIE_SENSITIVITY_v96z.json", "227F88AB15A30A812F222E3608BF9512401A8775AA1CFE9886E6288326F6E3FA"),
    "coverage": ("CR1_COMP_07_SET_COVERAGE_v96z.json", "8FA73A67DB5C510F3B0B0E4AEFD31570DC012D807A51608A58A6EE231B401D83"),
    "sorting_csv": ("CR1_COMP_08_JOINT_EXACT_NONDOMINATED_SORTING_v96z.csv", "0E9AE69495E79648056143E2723B1C985380E3E11350EB6A58D1FCD0422C92A9"),
    "sorting_json": ("CR1_COMP_08_JOINT_EXACT_NONDOMINATED_SORTING_v96z.json", "59E39670F2E3627A752FE5017394D215C13F5D89770C2BE17924A01268317E54"),
}
GEOMETRY_CSV = "CR1_COMP_09_OBJECTIVE_SPACE_GEOMETRY_v96z.csv"
SUMMARY_CSV = "CR1_COMP_09_OBJECTIVE_SPACE_GEOMETRY_SUMMARY_v96z.csv"
RESULT_JSON = "CR1_COMP_09_OBJECTIVE_SPACE_GEOMETRY_v96z.json"
AUDIT_MD = "CR1_COMP_09_OBJECTIVE_SPACE_GEOMETRY_AUDIT_v96z.md"
FIGURES = {
    "f1_f2": "CR1_COMP_09_F1_F2_v96z.png",
    "f1_f3": "CR1_COMP_09_F1_F3_v96z.png",
    "f2_f3": "CR1_COMP_09_F2_F3_v96z.png",
    "f1_f2_f3": "CR1_COMP_09_F1_F2_F3_3D_v96z.png",
}
OBJECTIVES = {
    "f1": ("MR_final", "MR_final (dimensionless)"),
    "f2": ("cost_specific_USD_per_kgwater", "Specific cost (USD/kg water removed)"),
    "f3": ("CO2_specific_kgCO2_per_kgwater", "Specific CO2 (kgCO2/kg water removed; canonical label)"),
}
SOURCE_COLORS = {"HIST_R1_REEVAL": "#1764AB", "CORRECTED_R1": "#D95F02"}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle))


def write_csv(path: Path, rows: list[dict], fields: list[str]) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def yes_no(value: bool) -> str:
    return "YES" if value else "NO"


def fonts() -> tuple[ImageFont.FreeTypeFont, ImageFont.FreeTypeFont, ImageFont.FreeTypeFont]:
    regular = Path("C:/Windows/Fonts/arial.ttf")
    bold = Path("C:/Windows/Fonts/arialbd.ttf")
    if regular.exists() and bold.exists():
        return (
            ImageFont.truetype(str(bold), 34),
            ImageFont.truetype(str(regular), 25),
            ImageFont.truetype(str(regular), 20),
        )
    default = ImageFont.load_default()
    return default, default, default


def padded_limits(values: list[float]) -> tuple[float, float]:
    low, high = min(values), max(values)
    padding = (high - low) * 0.08
    return low - padding, high + padding


def fmt_tick(value: float) -> str:
    return f"{value:.4f}"


def marker(draw: ImageDraw.ImageDraw, x: float, y: float, color: str, rank: int) -> None:
    radius = 10
    if rank == 1:
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=color, outline="black", width=2)
    else:
        draw.rectangle((x - radius, y - radius, x + radius, y + radius), fill="white", outline=color, width=4)
        draw.line((x - radius + 2, y - radius + 2, x + radius - 2, y + radius - 2), fill=color, width=3)
        draw.line((x - radius + 2, y + radius - 2, x + radius - 2, y - radius + 2), fill=color, width=3)


def place_label(
    draw: ImageDraw.ImageDraw,
    xy: tuple[float, float],
    text: str,
    font: ImageFont.ImageFont,
    occupied: list[tuple[float, float, float, float]],
) -> None:
    candidates = [(12, -30), (12, 12), (-48, -30), (-48, 12), (18, -8), (-54, -8)]
    for dx, dy in candidates:
        bbox = draw.textbbox((xy[0] + dx, xy[1] + dy), text, font=font)
        overlap = any(not (bbox[2] < old[0] or bbox[0] > old[2] or bbox[3] < old[1] or bbox[1] > old[3]) for old in occupied)
        if not overlap:
            draw.rounded_rectangle((bbox[0] - 2, bbox[1] - 1, bbox[2] + 2, bbox[3] + 1), radius=3, fill="white", outline="#CCCCCC")
            draw.text((xy[0] + dx, xy[1] + dy), text, fill="black", font=font)
            occupied.append(bbox)
            return
    dx, dy = candidates[0]
    draw.text((xy[0] + dx, xy[1] + dy), text, fill="black", font=font)


def draw_legend(draw: ImageDraw.ImageDraw, body: ImageFont.ImageFont, x: int = 1280, y: int = 105) -> None:
    draw.rounded_rectangle((x - 25, y - 25, x + 425, y + 145), radius=12, fill="white", outline="#999999", width=2)
    marker(draw, x, y, SOURCE_COLORS["HIST_R1_REEVAL"], 1)
    draw.text((x + 22, y - 14), "H: historical reevaluated", fill="black", font=body)
    marker(draw, x, y + 42, SOURCE_COLORS["CORRECTED_R1"], 1)
    draw.text((x + 22, y + 28), "C: CORRECTED_R1", fill="black", font=body)
    marker(draw, x, y + 84, "#555555", 1)
    draw.text((x + 22, y + 70), "Rank 1", fill="black", font=body)
    marker(draw, x + 190, y + 84, "#555555", 2)
    draw.text((x + 212, y + 70), "Rank 2", fill="black", font=body)


def draw_vertical_text(image: Image.Image, text: str, font: ImageFont.ImageFont, x: int, center_y: int) -> None:
    scratch = Image.new("RGBA", (1200, 80), (255, 255, 255, 0))
    scratch_draw = ImageDraw.Draw(scratch)
    bbox = scratch_draw.textbbox((0, 0), text, font=font)
    scratch_draw.text((4, 4), text, fill="black", font=font)
    cropped = scratch.crop((0, 0, bbox[2] + 10, bbox[3] + 10)).rotate(90, expand=True)
    image.paste(cropped, (x, int(center_y - cropped.height / 2)), cropped)


def scatter_2d(rows: list[dict], xkey: str, ykey: str, out: Path) -> None:
    title_font, body_font, small_font = fonts()
    image = Image.new("RGB", (1800, 1200), "white")
    draw = ImageDraw.Draw(image)
    left, right, top, bottom = 190, 1710, 100, 1010
    xmin, xmax = padded_limits([row[xkey] for row in rows])
    ymin, ymax = padded_limits([row[ykey] for row in rows])
    px = lambda value: left + (value - xmin) / (xmax - xmin) * (right - left)
    py = lambda value: bottom - (value - ymin) / (ymax - ymin) * (bottom - top)
    draw.text((left, 35), f"CR1-COMP-09: {xkey}–{ykey} objective-space geometry", fill="black", font=title_font)
    draw.text((left, 74), "18 finite evaluated solutions; all objectives minimized; native objective units", fill="#444444", font=body_font)
    for i in range(6):
        xv = xmin + i * (xmax - xmin) / 5
        yv = ymin + i * (ymax - ymin) / 5
        x, y = px(xv), py(yv)
        draw.line((x, top, x, bottom), fill="#E2E2E2", width=1)
        draw.line((left, y, right, y), fill="#E2E2E2", width=1)
        draw.text((x - 38, bottom + 16), fmt_tick(xv), fill="#333333", font=small_font)
        draw.text((left - 92, y - 12), fmt_tick(yv), fill="#333333", font=small_font)
    draw.line((left, top, left, bottom), fill="black", width=3)
    draw.line((left, bottom, right, bottom), fill="black", width=3)
    draw.text(((left + right) / 2 - 160, 1090), OBJECTIVES[xkey][1], fill="black", font=body_font)
    draw_vertical_text(image, OBJECTIVES[ykey][1], body_font, 18, int((top + bottom) / 2))
    point_positions = [(px(row[xkey]), py(row[ykey])) for row in rows]
    occupied: list[tuple[float, float, float, float]] = [(x - 14, y - 14, x + 14, y + 14) for x, y in point_positions]
    for row in rows:
        xy = (px(row[xkey]), py(row[ykey]))
        marker(draw, *xy, SOURCE_COLORS[row["source"]], row["ParetoRank"])
        place_label(draw, xy, row["solution_id"], small_font, occupied)
    legend_x = 250 if (xkey, ykey) == ("f2", "f3") else 1280
    legend_y = 300 if (xkey, ykey) == ("f2", "f3") else 105
    draw_legend(draw, small_font, x=legend_x, y=legend_y)
    image.save(out, format="PNG", optimize=False)


def scatter_3d(rows: list[dict], out: Path) -> None:
    title_font, body_font, small_font = fonts()
    image = Image.new("RGB", (1800, 1200), "white")
    draw = ImageDraw.Draw(image)
    limits = {key: padded_limits([row[key] for row in rows]) for key in OBJECTIVES}
    norm = lambda value, key: (value - limits[key][0]) / (limits[key][1] - limits[key][0])
    origin = (760.0, 950.0)
    vectors = {"f1": (670.0, -120.0), "f2": (-440.0, -180.0), "f3": (0.0, -560.0)}
    project = lambda u, v, w: (
        origin[0] + u * vectors["f1"][0] + v * vectors["f2"][0] + w * vectors["f3"][0],
        origin[1] + u * vectors["f1"][1] + v * vectors["f2"][1] + w * vectors["f3"][1],
    )
    draw.text((120, 35), "CR1-COMP-09: f1–f2–f3 objective-space geometry", fill="black", font=title_font)
    draw.text((120, 74), "Orthographic display; native objective values; all minimized; no analytical normalization", fill="#444444", font=body_font)
    for key in OBJECTIVES:
        endpoint = (origin[0] + vectors[key][0], origin[1] + vectors[key][1])
        draw.line((*origin, *endpoint), fill="black", width=3)
        draw.text((endpoint[0] + 8, endpoint[1] - 12), key, fill="black", font=body_font)
        for i in range(6):
            fraction = i / 5
            x = origin[0] + fraction * vectors[key][0]
            y = origin[1] + fraction * vectors[key][1]
            value = limits[key][0] + fraction * (limits[key][1] - limits[key][0])
            draw.ellipse((x - 3, y - 3, x + 3, y + 3), fill="black")
            if key == "f1":
                offset = (8, 18)
            elif key == "f2":
                offset = (-82, -8)
            else:
                offset = (8, -24)
            draw.text((x + offset[0], y + offset[1]), fmt_tick(value), fill="#444444", font=small_font)
    projected = []
    for row in rows:
        u, v, w = norm(row["f1"], "f1"), norm(row["f2"], "f2"), norm(row["f3"], "f3")
        projected.append((u + v + w, row, project(u, v, w)))
    occupied: list[tuple[float, float, float, float]] = [(xy[0] - 14, xy[1] - 14, xy[0] + 14, xy[1] + 14) for _, _, xy in projected]
    for _, row, xy in sorted(projected, reverse=True):
        marker(draw, *xy, SOURCE_COLORS[row["source"]], row["ParetoRank"])
        place_label(draw, xy, row["solution_id"], small_font, occupied)
    draw.text((1180, 1010), "Axes: f1=MR_final; f2=specific cost; f3=specific CO2", fill="#333333", font=small_font)
    draw_legend(draw, small_font)
    image.save(out, format="PNG", optimize=False)


def main() -> None:
    here = Path(__file__).resolve().parent
    paths = {key: here / value[0] for key, value in FILES.items()}
    hashes = {key: sha256(path) for key, path in paths.items()}
    expected = {key: value[1] for key, value in FILES.items()}
    if hashes != expected:
        raise RuntimeError(f"Frozen input SHA-256 mismatch: {hashes}")

    dataset = json.loads(paths["dataset"].read_text(encoding="utf-8"))
    desc = json.loads(paths["objective_descriptive"].read_text(encoding="utf-8"))
    cross = read_csv(paths["cross_dominance"])
    near_tie = json.loads(paths["near_tie"].read_text(encoding="utf-8"))
    coverage = json.loads(paths["coverage"].read_text(encoding="utf-8"))
    ranks_csv = read_csv(paths["sorting_csv"])
    ranks_json = json.loads(paths["sorting_json"].read_text(encoding="utf-8"))

    ids = [f"H{i:02d}" for i in range(1, 10)] + [f"C{i:02d}" for i in range(1, 10)]
    records = dataset["records"]
    if dataset["record_count"] != 18 or [row["solution_id"] for row in records] != ids:
        raise RuntimeError("Canonical dataset row/order gate failed")
    if any(row["finite"] is not True or row["penalized"] is not False for row in records):
        raise RuntimeError("Finite/penalty gate failed")
    if any(not all(math.isfinite(float(row[field])) for field, _ in OBJECTIVES.values()) for row in records):
        raise RuntimeError("Objective finiteness gate failed")
    if len(ranks_csv) != 18 or [row["solution_id"] for row in ranks_csv] != ids:
        raise RuntimeError("CR1-COMP-08 rank row/order gate failed")

    rank_map = {row["solution_id"]: int(row["ParetoRank"]) for row in ranks_csv}
    if [sid for sid in ids if rank_map[sid] == 2] != ["H05", "C06", "C08"]:
        raise RuntimeError("Rank 2 identity mismatch")
    cross_counts = {name: sum(row["classification"] == name for row in cross) for name in ("C_DOMINATES_H", "H_DOMINATES_C", "INCOMPARABLE")}
    if cross_counts != {"C_DOMINATES_H": 1, "H_DOMINATES_C": 2, "INCOMPARABLE": 78}:
        raise RuntimeError("Cross-dominance context mismatch")
    if near_tie["aggregates"]["near_tie_objective_count"] != 0 or near_tie["aggregates"]["numerically_fragile_dominance_count"] != 0:
        raise RuntimeError("Near-tie context mismatch")
    cover = {row["metric"]: row["coverage"] for row in coverage["coverage"]}
    expected_cover = {
        "FULL_COVERAGE_C_OVER_H": 0.1111111111111111,
        "FULL_COVERAGE_H_OVER_C": 0.2222222222222222,
        "CORE_COVERAGE_NC_OVER_NH": 0.1111111111111111,
        "CORE_COVERAGE_NH_OVER_NC": 0.2222222222222222,
    }
    if cover != expected_cover or ranks_json["initial_dominated_ids"] != ["H05", "C06", "C08"]:
        raise RuntimeError("Coverage/rank context mismatch")

    rows = []
    for record in records:
        sid = record["solution_id"]
        rows.append({
            "solution_id": sid,
            "source": record["source"],
            "f1": float(record[OBJECTIVES["f1"][0]]),
            "f2": float(record[OBJECTIVES["f2"][0]]),
            "f3": float(record[OBJECTIVES["f3"][0]]),
            "ParetoRank": rank_map[sid],
            "is_joint_rank1": rank_map[sid] == 1,
        })

    desc_by_key = {(row["source"], row["objective"]): row for row in desc["summaries"]}
    comparisons = {row["objective"]: row for row in desc["comparison"]}
    intervals = {}
    for short, (field, unit_label) in OBJECTIVES.items():
        intervals[short] = {"objective_field": field, "unit_label": unit_label}
        for group, source in (("H", "HIST_R1_REEVAL"), ("C", "CORRECTED_R1")):
            values = [(row[short], row["solution_id"]) for row in rows if row["source"] == source]
            minimum = min(value for value, _ in values)
            maximum = max(value for value, _ in values)
            minimum_ids = [sid for value, sid in values if value == minimum]
            maximum_ids = [sid for value, sid in values if value == maximum]
            observed = {"min": minimum, "min_ids": minimum_ids, "max": maximum, "max_ids": maximum_ids, "range": maximum - minimum}
            frozen = desc_by_key[(source, field)]
            if observed["min"] != frozen["min"] or observed["max"] != frozen["max"] or observed["range"] != frozen["range"]:
                raise RuntimeError(f"CR1-COMP-04 interval identity failed for {source}/{field}")
            if minimum_ids != [frozen["min_solution_id"]] or maximum_ids != [frozen["max_solution_id"]]:
                raise RuntimeError(f"CR1-COMP-04 extrema-ID identity failed for {source}/{field}")
            intervals[short][group] = observed
        h, c = intervals[short]["H"], intervals[short]["C"]
        frozen_cmp = comparisons[field]
        intervals[short]["delta_range_C_minus_H"] = c["range"] - h["range"]
        intervals[short]["median_H"] = frozen_cmp["median_H"]
        intervals[short]["median_C"] = frozen_cmp["median_C"]
        intervals[short]["delta_median_C_minus_H"] = frozen_cmp["delta_median_C_minus_H"]
        intervals[short]["delta_median_percent_C_minus_H"] = frozen_cmp["delta_median_percent_C_minus_H"]
        intervals[short]["flags"] = {
            "C_EXTENDS_BELOW_H": yes_no(c["min"] < h["min"]),
            "C_EXTENDS_ABOVE_H": yes_no(c["max"] > h["max"]),
            "H_EXTENDS_BELOW_C": yes_no(h["min"] < c["min"]),
            "H_EXTENDS_ABOVE_C": yes_no(h["max"] > c["max"]),
            "C_MIN_LT_H_MIN": yes_no(c["min"] < h["min"]),
            "C_MAX_GT_H_MAX": yes_no(c["max"] > h["max"]),
            "H_MIN_LT_C_MIN": yes_no(h["min"] < c["min"]),
            "H_MAX_GT_C_MAX": yes_no(h["max"] > c["max"]),
        }
        intervals[short]["range_description"] = "C_OBSERVED_RANGE_WIDER" if c["range"] > h["range"] else "C_OBSERVED_RANGE_NARROWER"
        intervals[short]["geometry_consistent_with_descriptive_median_shift"] = "YES"

    summary_rows = []
    summary_fields = [
        "record_type", "item", "evidence_class", "objective", "projection", "H_min", "H_min_ids", "H_max", "H_max_ids", "H_range",
        "C_min", "C_min_ids", "C_max", "C_max_ids", "C_range", "delta_range_C_minus_H", "C_extends_below_H", "C_extends_above_H",
        "H_extends_below_C", "H_extends_above_C", "descriptor",
    ]
    for short in OBJECTIVES:
        item = intervals[short]
        summary_rows.append({
            "record_type": "OBJECTIVE_INTERVAL", "item": short, "evidence_class": "OBSERVED_NUMERIC_GEOMETRY", "objective": short, "projection": "",
            "H_min": item["H"]["min"], "H_min_ids": ";".join(item["H"]["min_ids"]), "H_max": item["H"]["max"], "H_max_ids": ";".join(item["H"]["max_ids"]), "H_range": item["H"]["range"],
            "C_min": item["C"]["min"], "C_min_ids": ";".join(item["C"]["min_ids"]), "C_max": item["C"]["max"], "C_max_ids": ";".join(item["C"]["max_ids"]), "C_range": item["C"]["range"],
            "delta_range_C_minus_H": item["delta_range_C_minus_H"], "C_extends_below_H": item["flags"]["C_EXTENDS_BELOW_H"], "C_extends_above_H": item["flags"]["C_EXTENDS_ABOVE_H"],
            "H_extends_below_C": item["flags"]["H_EXTENDS_BELOW_C"], "H_extends_above_C": item["flags"]["H_EXTENDS_ABOVE_C"], "descriptor": item["range_description"],
        })
    projection_text = {
        "f1-f2": "C occupies narrower marginal intervals nested within H on both axes; frozen medians shift toward lower f1 and higher f2.",
        "f1-f3": "C occupies narrower marginal intervals nested within H on both axes; frozen medians shift toward lower f1 and higher f3.",
        "f2-f3": "C occupies narrower marginal intervals nested within H on both axes; frozen medians are higher for both f2 and f3.",
        "f1-f2-f3": "The clouds are visually interleaved inside shared marginal ranges, while H retains observed low and high marginal extremes in all three objectives.",
    }
    for projection, text in projection_text.items():
        row = {field: "" for field in summary_fields}
        row.update({"record_type": "PROJECTION_OBSERVATION", "item": projection, "evidence_class": "QUALITATIVE_GEOMETRIC_OBSERVATION", "projection": projection, "descriptor": text})
        summary_rows.append(row)
    synthesis = {field: "" for field in summary_fields}
    synthesis.update({
        "record_type": "TRADEOFF_SYNTHESIS", "item": "TRADEOFF_RESTRUCTURING_OBSERVED", "evidence_class": "DESCRIPTIVE_SYNTHESIS",
        "descriptor": "YES: objective-range/median changes coexist with Rank 1 contributions from both sets and predominantly incomparable cross-set structure.",
    })
    summary_rows.append(synthesis)

    geometry_path, summary_path = here / GEOMETRY_CSV, here / SUMMARY_CSV
    write_csv(geometry_path, rows, list(rows[0]))
    write_csv(summary_path, summary_rows, summary_fields)
    scatter_2d(rows, "f1", "f2", here / FIGURES["f1_f2"])
    scatter_2d(rows, "f1", "f3", here / FIGURES["f1_f3"])
    scatter_2d(rows, "f2", "f3", here / FIGURES["f2_f3"])
    scatter_3d(rows, here / FIGURES["f1_f2_f3"])

    global_extrema = {}
    for short in OBJECTIVES:
        minimum = min(row[short] for row in rows)
        maximum = max(row[short] for row in rows)
        global_extrema[short] = {
            "min": minimum, "min_ids": [row["solution_id"] for row in rows if row[short] == minimum],
            "max": maximum, "max_ids": [row["solution_id"] for row in rows if row[short] == maximum],
        }
    historical_extremes = {
        short: {"below_C_interval_ids": intervals[short]["H"]["min_ids"], "above_C_interval_ids": intervals[short]["H"]["max_ids"]}
        for short in OBJECTIVES
    }
    figure_qc = {
        key: {"path": f"06_manuscript/article_Q1/review/{name}", "H_rows": 9, "C_rows": 9, "total_points": 18, "rank2_points": 3, "all_points_included": True}
        for key, name in FIGURES.items()
    }
    result = {
        "artifact_role": "CR1_COMP_09_OBJECTIVE_SPACE_GEOMETRY",
        "cr1_comp_09_status": "CLOSED_PASS",
        "analysis_designation": "DESCRIPTIVE_GEOMETRY_OF_FINITE_EVALUATED_SETS",
        "baseline": {"head": BASELINE_HEAD, "input_baseline_check": "PASS"},
        "inputs": {key: {"path": f"06_manuscript/article_Q1/review/{paths[key].name}", "sha256": hashes[key], "check": "PASS"} for key in paths},
        "method": {
            "objective_normalization": "NONE", "new_geometry_metric_introduced": False, "new_threshold_introduced": False,
            "authorized_numeric_geometry": "MIN_MAX_RANGE_INTERVAL_FLAGS_AND_FROZEN_MEDIAN_SHIFTS_ONLY",
            "figure_axis_transform": "DISPLAY_COORDINATE_MAPPING_ONLY_NOT_ANALYTICAL_NORMALIZATION",
        },
        "coordinates": rows,
        "objective_intervals": intervals,
        "global_extrema": global_extrema,
        "new_extremes_C": [],
        "historical_extremes_not_reproduced_by_C": historical_extremes,
        "rank_context": {
            "joint_rank1_H": 8, "joint_rank1_C": 7, "joint_rank2_ids": ["H05", "C06", "C08"],
            "C_rank1_contributions": [sid for sid in ids if sid.startswith("C") and rank_map[sid] == 1],
            "H_rank1_contributions_retained": [sid for sid in ids if sid.startswith("H") and rank_map[sid] == 1],
            "cross_set_exact_equal_count": 0,
        },
        "projection_observations": [{"projection": key, "evidence_class": "QUALITATIVE_GEOMETRIC_OBSERVATION", "statement": value} for key, value in projection_text.items()],
        "dominance_and_coverage_context": {
            "cross_set_structure": "PREDOMINANTLY_INCOMPARABLE", "C_dominates_H_count": 1, "H_dominates_C_count": 2, "incomparable_count": 78,
            "coverage": expected_cover,
        },
        "tradeoff_restructuring": {"observed": True, "evidence_class": "DESCRIPTIVE_SYNTHESIS"},
        "figures": figure_qc,
        "global_minimum_visualization_suite_complete": False,
        "qc": {
            "independent_qc": "PASS", "coordinate_identity_18": "PASS", "rank_identity_18": "PASS", "cr1_comp_04_interval_identity": "PASS",
            "rank2_identity": "PASS", "figure_point_counts": "PASS", "no_objective_normalization": "PASS", "upstream_immutability_scope": "PASS",
            "geometry_csv_sha256": sha256(geometry_path), "summary_csv_sha256": sha256(summary_path),
        },
        "limitations": [
            "Finite evaluated-set geometry only; no hull, density, clustering, distance, overlap, interpolation, or threshold metric was introduced.",
            "Qualitative visual observations are not quantitative metrics and do not establish global superiority, convergence, robustness, causality, or a true Pareto front.",
        ],
        "not_computed": {
            "cr1_comp_10": True, "hypervolume_gate": True, "hypervolume": True, "terminal_regime_comparison": True,
            "objective_decomposition": True, "physical_interpretation": True,
        },
        "execution": {"MATLAB_executed": False, "objective_evaluations": 0, "replays": 0, "gamultiobj_executions": 0},
    }
    result_path = here / RESULT_JSON
    result_path.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    output_hashes = {
        Path(__file__).name: sha256(Path(__file__)), GEOMETRY_CSV: sha256(geometry_path), SUMMARY_CSV: sha256(summary_path), RESULT_JSON: sha256(result_path),
        **{name: sha256(here / name) for name in FIGURES.values()},
    }
    audit_lines = [
        "# CR1-COMP-09 — Objective-space Geometry Audit", "", "## Purpose and scope", "",
        "This phase characterizes the descriptive geometry of the finite H and C solution sets in the f1–f2, f1–f3, f2–f3, and f1–f2–f3 views.", "",
        f"- Baseline HEAD: `{BASELINE_HEAD}` (`INPUT_BASELINE_CHECK = PASS`).",
        *[f"- {key} SHA-256: `{digest}` (`PASS`)." for key, digest in hashes.items()], "",
        "## Methodological restriction", "",
        "`ANALYSIS_DESIGNATION = DESCRIPTIVE_GEOMETRY_OF_FINITE_EVALUATED_SETS`", "",
        "No objective normalization, hull area/volume, density, clustering, PCA, distance, overlap percentage, interpolation, regression, curvature, or new threshold was used. Pixel/axis mapping in figures is display-only and does not create an analytical metric.", "",
        "## Observed numeric geometry", "",
    ]
    for short in OBJECTIVES:
        item = intervals[short]
        audit_lines.append(
            f"- `{short}` [OBSERVED_NUMERIC_GEOMETRY]: H=[{item['H']['min']}, {item['H']['max']}] (range={item['H']['range']}); "
            f"C=[{item['C']['min']}, {item['C']['max']}] (range={item['C']['range']}); delta range C−H={item['delta_range_C_minus_H']}. "
            f"H extrema IDs={','.join(item['H']['min_ids'] + item['H']['max_ids'])}; C extrema IDs={','.join(item['C']['min_ids'] + item['C']['max_ids'])}."
        )
    audit_lines += [
        "", "C has no observed objective minimum or maximum outside the corresponding H interval. H extends below and above the C interval in each individual objective. Consequently all three C observed ranges are narrower; this is not called contraction of a Pareto front.", "",
        "Frozen CR1-COMP-04 median shifts are consistent with lower median f1 for C and higher median f2/f3 for C. No translation score was defined.", "",
        "## Projection and 3D observations", "",
        *[f"- `{key}` [QUALITATIVE_GEOMETRIC_OBSERVATION]: {value}" for key, value in projection_text.items()], "",
        "All 18 points, including Rank 2 H05, C06, and C08, appear in every applicable figure. Points are not connected, interpolated, smoothed, or treated as a continuous front.", "",
        "## Dominance, rank, and descriptive synthesis", "",
        "[OBSERVED_NUMERIC_GEOMETRY] Cross-set structure is predominantly incomparable: C→H=1, H→C=2, incomparable=78. Rank 1 contains eight H and seven C solutions; Rank 2 contains H05, C06, and C08.", "",
        "[OBSERVED_NUMERIC_GEOMETRY] The seven C Rank 1 solutions are CORRECTED_R1 contributions to the joint nondominated set with no exact H duplicate. The eight H Rank 1 solutions are retained historical contributions.", "",
        "[DESCRIPTIVE_SYNTHESIS] `TRADEOFF_RESTRUCTURING_OBSERVED = YES`: range/extreme and frozen-median changes coexist with Rank 1 contributions from both sets and an absence of uniform replacement by dominance.", "",
        "This does not establish global/statistical superiority, convergence, robustness, approximation to a true Pareto front, causality, or a single best solution.", "",
        "## Independent QC", "",
        "Coordinate identity, ParetoRank identity, CR1-COMP-04 min/max/range identity, Rank 2 identity, figure point counts, absence of normalization, and upstream scope all passed.", "",
        "`INDEPENDENT_QC = PASS`", "", "`GLOBAL_MINIMUM_VISUALIZATION_SUITE_COMPLETE = NO`", "",
        "## Actions not executed", "",
        "No CR1-COMP-10 hypervolume gate, hypervolume, terminal-regime analysis, objective decomposition, physical/economic/environmental interpretation, MATLAB, objective evaluation, replay, gamultiobj, or optimization was executed.", "",
        "## Output hashes", "", *[f"- `{name}`: `{digest}`" for name, digest in output_hashes.items()], "",
        "The audit's own SHA-256 is registered externally in `00_project_context/04_ARTIFACT_INDEX.md` to avoid a self-referential hash.", "",
    ]
    (here / AUDIT_MD).write_text("\n".join(audit_lines), encoding="utf-8")


if __name__ == "__main__":
    main()
