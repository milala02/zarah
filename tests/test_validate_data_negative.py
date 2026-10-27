"""Tes negatif dan positif untuk tools/validate_data.py."""

from __future__ import annotations

import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

from tools.validate_data import validate_all_data


class TestValidateData(unittest.TestCase):
    """Menguji validasi skema sim_defaults.json dan materials."""

    def setUp(self) -> None:
        """Menyiapkan direktori repo sementara dengan skema asli."""
        self.real_repo = REPO_ROOT
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = Path(self.temp_dir.name)

        (self.root / "data" / "schemas").mkdir(parents=True)
        (self.root / "data" / "materials").mkdir(parents=True)

        shutil.copy2(
            self.real_repo / "data" / "schemas" / "material.schema.json",
            self.root / "data" / "schemas" / "material.schema.json",
        )
        shutil.copy2(
            self.real_repo / "data" / "schemas" / "sim_defaults.schema.json",
            self.root / "data" / "schemas" / "sim_defaults.schema.json",
        )
        shutil.copy2(
            self.real_repo / "data" / "materials" / "water.json",
            self.root / "data" / "materials" / "water.json",
        )

    def tearDown(self) -> None:
        """Membersihkan direktori sementara."""
        self.temp_dir.cleanup()

    def test_valid_sim_defaults_exits_0(self) -> None:
        """Fixture sim_defaults valid harus menghasilkan kode keluar 0."""
        valid_payload = {
            "suhu_ambient_c": 20.0,
            "material_udara_id": 0,
            "rujukan": "ISO 1:2016",
        }
        (self.root / "data" / "sim_defaults.json").write_text(
            json.dumps(valid_payload), encoding="utf-8"
        )
        exit_code = validate_all_data(self.root)
        self.assertEqual(exit_code, 0)

    def test_missing_suhu_ambient_c_exits_1(self) -> None:
        """Fixture sim_defaults tanpa suhu_ambient_c harus menghasilkan kode keluar 1."""
        invalid_payload = {
            "material_udara_id": 0,
            "rujukan": "ISO 1:2016",
        }
        (self.root / "data" / "sim_defaults.json").write_text(
            json.dumps(invalid_payload), encoding="utf-8"
        )
        exit_code = validate_all_data(self.root)
        self.assertEqual(exit_code, 1)

    def test_duplicate_id_numerik_exits_1(self) -> None:
        """Dua file material dengan id_numerik sama harus menghasilkan kode keluar 1."""
        valid_defaults = {
            "suhu_ambient_c": 20.0,
            "material_udara_id": 0,
            "rujukan": "ISO 1:2016",
        }
        (self.root / "data" / "sim_defaults.json").write_text(
            json.dumps(valid_defaults), encoding="utf-8"
        )
        dup_material = {
            "id": "dup_mat",
            "id_numerik": 3,
            "nama": "Duplikat",
            "fase_default": "padat",
            "physics_kind": "static",
            "kerapatan_kg_m3": 1000,
            "warna_dasar_srgb": "#112233",
            "rujukan": "CRC Handbook",
        }
        (self.root / "data" / "materials" / "dup_mat.json").write_text(
            json.dumps(dup_material), encoding="utf-8"
        )
        exit_code = validate_all_data(self.root)
        self.assertEqual(exit_code, 1)


if __name__ == "__main__":
    unittest.main()
