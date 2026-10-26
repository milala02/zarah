# Status Proyek

## M0 — Fondasi
- [x] Struktur repo & AGENTS.md
- [x] Proyek Godot 4.3 (gl_compatibility, landscape)
- [x] Kerangka tes headless
- [x] Validator data + skema material
- [x] 1 material contoh (water, rujukan CRC Handbook)
- [x] CI Job A (validate, lint, headless tests) hijau
- [ ] CI Job B (build APK debug) — DITUNDA
- [ ] Verifikasi APK di HP — DITUNDA

**Keputusan pemilik:** Bangun APK ditunda. Alasan: preset Android
menggabungkan `gradle_build=false` dengan override `min_sdk`, yang
ditolak Godot. Prioritas bergeser ke M1-core (inti simulasi murni)
demi mematangkan fondasi sebelum rendering & rilis.

**Aktifkan kembali Job B ketika:** (a) set gradle_build=true + Android
SDK/NDK/templates di runner, ATAU (b) hapus override min_sdk.

## M1-core — Inti Simulasi (sedang berjalan)
Lihat `docs/tasks/` untuk task brief per unit.
