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

## M1-core — Inti Simulasi
- [x] Fondasi sel, chunk, world, determinisme RNG, dan serialisasi v1.

## M2 — Fisika Material (Selesai Lokal)
- [x] Material data & skema: udara, stone, sand, water dengan `id_numerik`, `physics_kind`, kerapatan, dan warna terverifikasi rujukan ilmiah.
- [x] MaterialRegistry murni tanpa FileAccess untuk sim/.
- [x] Fisika kanonik deterministik: POWDER (pasir), LIQUID (air), GAS (udara) via multi-pass kind.
- [x] Snapshot determinisme & order independence chunk terverifikasi.
- [x] Benchmark 100 tick < 50 ms/tick (< 8 ms target perangkat fisik).
- [x] Kartu Sains M2 tertulis (`docs/science_cards/M2_fisika_material.md`).
- [ ] Cross-chunk physics — DITUNDA ke M3.
- [ ] APK debug & uji perangkat fisik — DITUNDA (mengikuti kebijakan M0/M1).
