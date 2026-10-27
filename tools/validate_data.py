#!/usr/bin/env python3
"""Skrip validasi data simulasi dan material terhadap JSON Schema."""

from __future__ import annotations

import json
import sys
from pathlib import Path

import jsonschema
from jsonschema import ValidationError

ROOT_FILE_SCHEMAS: dict[str, str] = {
    "sim_defaults.json": "sim_defaults.schema.json",
}


def load_json(path: Path) -> object:
    """Memuat file JSON dari path yang diberikan."""
    with path.open("r", encoding="utf-8") as file_handle:
        return json.load(file_handle)


def _get_validator(schema_path: Path) -> tuple[object | None, str | None]:
    """Memuat dan membuat validator JSON Schema dari file skema."""
    if not schema_path.is_file():
        return None, f"GAGAL {schema_path}: file skema tidak ditemukan"

    try:
        schema_data = load_json(schema_path)
    except (OSError, json.JSONDecodeError) as exc:
        return None, f"GAGAL {schema_path}: {exc}"

    if not isinstance(schema_data, dict):
        return None, f"GAGAL {schema_path}: skema harus berupa objek JSON"

    validator_cls = getattr(
        jsonschema, "Draft202012Validator", jsonschema.Draft7Validator
    )
    validator_cls.check_schema(schema_data)
    return validator_cls(schema_data), None


def _validate_file(file_path: Path, rel_path: Path, validator: object) -> bool:
    """Memvalidasi satu file JSON menggunakan validator yang diberikan."""
    try:
        instance = load_json(file_path)
        validator.validate(instance)  # type: ignore[attr-defined]
        print(f"OK {rel_path}")
        return True
    except (OSError, json.JSONDecodeError, ValidationError) as exc:
        message = exc.message if isinstance(exc, ValidationError) else str(exc)
        print(f"GAGAL {rel_path}: {message}")
        return False


def validate_all_data(repo_root: Path) -> int:
    """Memvalidasi seluruh file data/ root dan data/materials/ terhadap skema."""
    data_dir: Path = repo_root / "data"
    schemas_dir: Path = data_dir / "schemas"
    materials_dir: Path = data_dir / "materials"

    failed: bool = False

    root_files: list[Path] = sorted(data_dir.glob("*.json"))
    for file_path in root_files:
        rel_path: Path = file_path.relative_to(repo_root)
        schema_name: str | None = ROOT_FILE_SCHEMAS.get(file_path.name)
        if schema_name is None:
            print(f"GAGAL {rel_path}: tidak ada pemetaan skema untuk file ini")
            failed = True
            continue

        validator, err = _get_validator(schemas_dir / schema_name)
        if err is not None or validator is None:
            print(err)
            return 1

        if not _validate_file(file_path, rel_path, validator):
            failed = True

    material_validator, mat_err = _get_validator(schemas_dir / "material.schema.json")
    if mat_err is not None or material_validator is None:
        print(mat_err)
        return 1

    seen_id_numerik: dict[int, Path] = {}
    material_files: list[Path] = sorted(materials_dir.glob("*.json"))
    for file_path in material_files:
        rel_path = file_path.relative_to(repo_root)
        if not _validate_file(file_path, rel_path, material_validator):
            failed = True
            continue

        instance = load_json(file_path)
        if isinstance(instance, dict) and isinstance(instance.get("id_numerik"), int):
            id_num: int = instance["id_numerik"]
            if id_num in seen_id_numerik:
                prev_path: Path = seen_id_numerik[id_num]
                print(
                    f"GAGAL {rel_path}: duplikat id_numerik={id_num} "
                    f"(sudah dipakai di {prev_path})"
                )
                failed = True
            else:
                seen_id_numerik[id_num] = rel_path

    return 1 if failed else 0


def main() -> int:
    """Titik masuk utama validator data."""
    repo_root: Path = Path(__file__).resolve().parent.parent
    return validate_all_data(repo_root)


if __name__ == "__main__":
    sys.exit(main())
