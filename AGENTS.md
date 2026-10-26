# AGENTS.md

## Sumber kebenaran
Baca docs/ sebelum mengerjakan apa pun. Spesifikasi di docs/ mengalahkan asumsi.

## Alur kerja
1. Baca bagian spesifikasi yang relevan.
2. Tulis rencana singkat, tunggu persetujuan.
3. Kerjakan satu unit kecil.
4. Jalankan tes, lalu CI.
5. Tulis ringkasan: yang berubah, yang diuji, yang belum.

## Larangan
- Jangan ubah spesifikasi atau Kartu Sains tanpa persetujuan.
- Jangan matikan, longgarkan, atau hapus tes agar CI hijau.
- Jangan mengarang fakta sains. Rujuk Kartu Sains.
- Jangan tambah fitur di luar tugas, dan jangan memilih warna material sendiri (pakai data/).
- Jika spesifikasi ambigu, berhenti dan tanya.

## Kode
- Inti simulasi hanya di sim/, tanpa ketergantungan scene.
- Parameter sains hanya di data/.
- Tipe statis, fungsi kecil, tanpa state global.
- Setiap bug punya tes regresi.

## Definition of Done
Kriteria terukur, tes otomatis, CI hijau, dicoba di HP, catatan perubahan.
