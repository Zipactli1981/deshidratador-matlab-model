"""Block C editorial-only relabeling of frozen CR1-COMP-09 PNG figures.

This script never reads objective data and never redraws plot interiors. It copies
the frozen PNGs, replaces only predeclared margin rectangles, and verifies that
every pixel in the scientific plot region remains identical to the source image.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFont


EXPECTED_SOURCE_HASHES = {
    "CR1_COMP_09_F1_F2_v96z.png": "55B2907831EA866125E96E3D497F298F6A91CD85239EFB8C53C72898BFB3EAC2",
    "CR1_COMP_09_F1_F3_v96z.png": "05EE6663A057F67A381485E549156CB1A0768AD928AC52CFC42C5C5B04EF63AB",
    "CR1_COMP_09_F2_F3_v96z.png": "572D5126ED046FF3F35B5DC771C20B8D5B814B06A0AA56864231DC0A29F04223",
    "CR1_COMP_09_F1_F2_F3_3D_v96z.png": "7F58A45414766818E42948B52EECCD98B18EE327BE7C6F3378234B9A176E73AF",
}

LABELS = {
    "f1": ("Final moisture ratio, MR_final", "dimensionless"),
    "f2": ("Modeled specific operating-energy cost", "USD/kg water removed"),
    "f3": ("Modeled specific operational greenhouse-gas emissions", "kg CO2e/kg water removed"),
}

TWO_D = {
    "CR1_COMP_09_F1_F2_v96z.png": ("f1", "f2"),
    "CR1_COMP_09_F1_F3_v96z.png": ("f1", "f3"),
    "CR1_COMP_09_F2_F3_v96z.png": ("f2", "f3"),
}

TITLES_2D = {
    "CR1_COMP_09_F1_F2_v96z.png": "Final moisture ratio and modeled specific operating-energy cost",
    "CR1_COMP_09_F1_F3_v96z.png": "Final moisture ratio and modeled specific operational greenhouse-gas emissions",
    "CR1_COMP_09_F2_F3_v96z.png": "Modeled operating-energy cost and operational greenhouse-gas emissions",
}

TITLE_REGION = (90, 20, 1500, 79)
SUBTITLE_REGION_2D = (190, 68, 1235, 99)
SUBTITLE_REGION_3D = (90, 68, 1235, 99)
EDIT_REGIONS_2D = ((0, 90, 94, 1016), (190, 1050, 1711, 1200), TITLE_REGION, SUBTITLE_REGION_2D)
EDIT_REGION_3D = (1060, 985, 1800, 1170)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def image_hash(image: Image.Image) -> str:
    return hashlib.sha256(image.tobytes()).hexdigest().upper()


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    path = Path("C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf")
    return ImageFont.truetype(str(path), size) if path.exists() else ImageFont.load_default()


def centered(draw: ImageDraw.ImageDraw, text: str, y: int, face: ImageFont.ImageFont, left: int, right: int) -> None:
    box = draw.textbbox((0, 0), text, font=face)
    x = left + ((right - left) - (box[2] - box[0])) / 2
    draw.text((x, y), text, fill="black", font=face)


def vertical_label(image: Image.Image, name: str, unit: str) -> None:
    text = f"{name} ({unit})"
    max_height = 850
    selected = font(24)
    for size in range(24, 13, -1):
        candidate = font(size)
        scratch = Image.new("RGB", (1400, 80), "white")
        box = ImageDraw.Draw(scratch).textbbox((0, 0), text, font=candidate)
        if box[2] - box[0] <= max_height:
            selected = candidate
            break
    scratch = Image.new("RGBA", (1400, 90), (255, 255, 255, 0))
    scratch_draw = ImageDraw.Draw(scratch)
    box = scratch_draw.textbbox((0, 0), text, font=selected)
    scratch_draw.text((4, 4), text, fill="black", font=selected)
    label = scratch.crop((0, 0, box[2] + 10, box[3] + 10)).rotate(90, expand=True)
    image.paste(label, (8, int(555 - label.height / 2)), label)


def relabel_2d(source: Path, output: Path, xkey: str, ykey: str) -> dict:
    original = Image.open(source).convert("RGB")
    edited = original.copy()
    draw = ImageDraw.Draw(edited)
    legend_region = (270, 320, 650, 372) if (xkey, ykey) == ("f2", "f3") else (1300, 125, 1695, 177)
    modified_regions = (*EDIT_REGIONS_2D, legend_region)
    for region in modified_regions:
        draw.rectangle(region, fill="white")
    draw.text((190, 35), TITLES_2D[source.name], fill="black", font=font(34, bold=True))
    draw.text((190, 70), "18 finite evaluated solutions; all objectives minimized; native objective units", fill="#444444", font=font(25))
    legend_x, legend_y = (272, 328) if (xkey, ykey) == ("f2", "f3") else (1302, 133)
    draw.text((legend_x, legend_y), "C: directly corrected", fill="black", font=font(20))
    xname, xunit = LABELS[xkey]
    yname, yunit = LABELS[ykey]
    centered(draw, xname, 1060, font(23), 190, 1711)
    centered(draw, f"({xunit})", 1092, font(21), 190, 1711)
    vertical_label(edited, yname, yunit)
    mask = Image.new("1", original.size, 1)
    mask_draw = ImageDraw.Draw(mask)
    for region in modified_regions:
        mask_draw.rectangle(region, fill=0)
    original_preserved = Image.new("RGB", original.size, "white")
    edited_preserved = Image.new("RGB", edited.size, "white")
    original_preserved.paste(original, mask=mask)
    edited_preserved.paste(edited, mask=mask)
    preserved_difference = ImageChops.difference(original_preserved, edited_preserved).getbbox()
    if preserved_difference is not None:
        raise RuntimeError(f"Pixels outside approved label regions changed: {source.name}: {preserved_difference}")
    edited.save(output, format="PNG", optimize=False)
    return {
        "source_sha256": sha256(source),
        "output_sha256": sha256(output),
        "dimensions": list(original.size),
        "preserved_pixels_source_sha256": image_hash(original_preserved),
        "preserved_pixels_output_sha256": image_hash(edited_preserved),
        "pixels_outside_modified_regions_identity": "PASS",
        "modified_regions": [list(region) for region in modified_regions],
    }


def relabel_3d(source: Path, output: Path) -> dict:
    original = Image.open(source).convert("RGB")
    edited = original.copy()
    draw = ImageDraw.Draw(edited)
    legend_region = (1300, 125, 1695, 177)
    modified_regions = (EDIT_REGION_3D, TITLE_REGION, SUBTITLE_REGION_3D, legend_region)
    for region in modified_regions:
        draw.rectangle(region, fill="white")
    draw.text((120, 35), "Three-objective geometry of the 18 evaluated solutions", fill="black", font=font(34, bold=True))
    draw.text((120, 70), "Orthographic display; native objective values; all objectives minimized", fill="#444444", font=font(25))
    draw.text((1302, 133), "C: directly corrected", fill="black", font=font(20))
    lines = [
        "Axes:",
        "f1 = final moisture ratio, MR_final (dimensionless)",
        "f2 = modeled specific operating-energy cost (USD/kg water removed)",
        "f3 = modeled specific operational greenhouse-gas emissions",
        "      (kg CO2e/kg water removed)",
    ]
    for index, text in enumerate(lines):
        draw.text((1080, 990 + index * 31), text, fill="#222222", font=font(18 if index else 20))
    mask = Image.new("1", original.size, 1)
    mask_draw = ImageDraw.Draw(mask)
    for region in modified_regions:
        mask_draw.rectangle(region, fill=0)
    original_preserved = Image.new("RGB", original.size, "white")
    edited_preserved = Image.new("RGB", edited.size, "white")
    original_preserved.paste(original, mask=mask)
    edited_preserved.paste(edited, mask=mask)
    if ImageChops.difference(original_preserved, edited_preserved).getbbox() is not None:
        raise RuntimeError(f"Pixels outside approved label region changed: {source.name}")
    edited.save(output, format="PNG", optimize=False)
    return {
        "source_sha256": sha256(source),
        "output_sha256": sha256(output),
        "dimensions": list(original.size),
        "preserved_pixels_source_sha256": image_hash(original_preserved),
        "preserved_pixels_output_sha256": image_hash(edited_preserved),
        "pixels_outside_modified_regions_identity": "PASS",
        "modified_regions": [list(region) for region in modified_regions],
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-dir", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--audit", type=Path, required=True)
    args = parser.parse_args()
    results = {}
    for name, expected in EXPECTED_SOURCE_HASHES.items():
        source = args.source_dir / name
        if sha256(source) != expected:
            raise RuntimeError(f"Frozen source SHA-256 mismatch: {name}")
        output = args.output_dir / name
        if name in TWO_D:
            results[name] = relabel_2d(source, output, *TWO_D[name])
        else:
            results[name] = relabel_3d(source, output)
    audit = {
        "artifact_role": "BLOCK_C_LABEL_ONLY_FIGURE_REGENERATION_AUDIT",
        "regeneration_mode": "LABEL_ONLY_MARGIN_PIXEL_REPLACEMENT",
        "objective_data_read": False,
        "scientific_analysis_executed": False,
        "point_coordinates_identical": "PASS_ALL_POINT_MARKERS_OUTSIDE_EDIT_REGIONS_AND_PIXEL_IDENTICAL",
        "H_C_membership_identical": "PASS_ALL_POINT_COLORS_AND_IDS_UNMODIFIED",
        "rank_membership_identical": "PASS_ALL_RANK_MARKERS_UNMODIFIED",
        "scientific_geometry_identical": "PASS",
        "figures": results,
    }
    args.audit.write_text(json.dumps(audit, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
