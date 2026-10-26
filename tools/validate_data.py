#!/usr/bin/env python3
"""Skrip validasi data material terhadap JSON Schema."""

from __future__ import annotations

import json
import sys
from pathlib import Path

import jsonschema
from jsonschema import ValidationError


def load_json(path: Path) -> object:
    """Memuat file JSON dari path yang diberikan."""
    with path.open("r", encoding="utf-8") as file_handle:
        return json.load(file_handle)


def validate_materials(repo_root: Path) -> int:
    """Memvalidasi semua file JSON di data/materials/ terhadap material.schema.json."""
    schema_path: Path = repo_root / "data" / "schemas" / "material.schema.json"
    materials_dir: Path = repo_root / "data" / "materials"

    if not schema_path.is_file():
        print(f"GAGAL {schema_path}: file skema tidak ditemukan")
        return 1

    try:
        schema_data = load_json(schema_path)
    except (OSError, json.JSONDecodeError) as exc:
        print(f"GAGAL {schema_path}: {exc}")
        return 1

    if not isinstance(schema_data, dict):
        print(f"GAGAL {schema_path}: skema harus berupa objek JSON")
        return 1

    validator_cls = getattr(
        jsonschema, "Draft202012Validator", jsonschema.Draft7Validator
    )
    validator_cls.check_schema(schema_data)
    validator = validator_cls(schema_data)

    material_files: list[Path] = sorted(materials_dir.glob("*.json"))
    failed: bool = False

    for file_path in material_files:
        rel_path: Path = file_path.relative_to(repo_root)
        try:
            instance = load_json(file_path)
            validator.validate(instance)
            print(f"OK {rel_path}")
        except (OSError, json.JSONDecodeError, ValidationError) as exc:
            message = exc.message if isinstance(exc, ValidationError) else str(exc)
            print(f"GAGAL {rel_path}: {message}")
            failed = True

    return 1 if failed else 0


def main() -> int:
    """Titik masuk utama validator data."""
    repo_root: Path = Path(__file__).resolve().parent.parent
    return validate_materials(repo_root)


if __name__ == "__main__":
    sys.exit(main())
