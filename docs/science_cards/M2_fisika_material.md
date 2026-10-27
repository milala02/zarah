# Kartu Sains M2: Fisika Material

## Fenomena
- Pasir (powder) jatuh dan menumpuk di atas permukaan padat.
- Air (cairan) mengalir ke bawah dan menyebar secara horizontal mengisi cekungan.
- Udara (gas) naik melalui cairan atau fluida yang lebih rapat (gaya apung / Archimedes).

## Hukum atau prinsip
- **Gravitasi:** Padatan lepas (butiran) dan cairan ditarik ke bawah menuju area dengan kerapatan lebih rendah.
- **Tekanan hidrostatik sederhana:** Cairan mengalir ke samping (sideways) saat ada ruang kosong atau fluida lebih ringan di atasnya.
- **Prinsip Apung Archimedes:** Material dengan kerapatan lebih rendah terdesak ke atas melewati material dengan kerapatan lebih tinggi.

## Penyederhanaan (Tingkat C)
- **Iterasi KANONIK (bukan permutation-invariant):** Pemindaian chunk dilakukan dari baris terbawah ke atas (bottom-up, `y` dari 63 turun ke 0) dan dari kiri ke kanan (`x` dari 0 ke 63), dengan arah preferensi diagonal bergantian setiap tick (`preferred = -1` jika genap, `+1` jika ganjil).
- **Multi-pass kind:** Simulasi dijalankan dalam 3 pass berurutan per tick: POWDER, LIQUID, lalu GAS, untuk menjaga kestabilan pertukaran antar jenis material.
- **Mark-src-only:** Hanya sel penggerak (`src`) yang diberi tanda `last_moved_tick = tick_count`, sedangkan sel `dst` yang terdesak tidak ditandai. Konsekuensi: kolom material sejenis dapat bergerak bersama 1 sel per tick.
- **Gas menembus padatan lepas:** Porositas belum dimodelkan secara terpisah; pertukaran gas mengacu langsung pada perbedaan kerapatan.
- **Batas Chunk (Cross-chunk deferred):** Fisika pada M2 dibatasi strictly di dalam batas chunk (`0 <= x, y < 64`). Pergerakan lintas chunk ditunda ke M3.
- **Satu pergerakan per tick:** Setiap sel penggerak hanya berpindah maksimal 1 langkah per tick.
- **Dinamika tekanan belum dimodelkan:** Air hanya mengalir ke bawah dan menyebar ke samping, belum menghasilkan tekanan dorong hidrodinamika penuh.

## Parameter dan warna dasar sRGB (di data/)
- `udara`: `id_numerik = 0`, `fase_default = "gas"`, `kerapatan_kg_m3 = 1.2`, `warna_dasar_srgb = "#C8E6F0"`
- `stone`: `id_numerik = 1`, `fase_default = "padat"`, `kerapatan_kg_m3 = 2600`, `warna_dasar_srgb = "#8A8A8A"`
- `sand`: `id_numerik = 2`, `fase_default = "padat"`, `kerapatan_kg_m3 = 1600`, `warna_dasar_srgb = "#E6C88A"`
- `water`: `id_numerik = 3`, `fase_default = "cair"`, `kerapatan_kg_m3 = 1000` (cair), `warna_dasar_srgb = "#A8D4E6"`

## Sumber rujukan
- CRC Handbook of Chemistry and Physics, 97th ed. (2016): Nilai densitas udara kering (20 °C, 1 atm), granit/batuan rata-rata, pasir kuarsa, dan air.
- Buku teks fisika dasar (Hukum Gravitasi Newton dan Prinsip Archimedes).

## Tes pembuktian
- `tests/test_physics_powder.gd`: Pasir jatuh, kolom pasir turun serentak tanpa cascade, tertahan di dasar, dan determinisme 50 tick.
- `tests/test_physics_liquid.gd`: Air jatuh, air menyebar di dasar basin, pasir tenggelam melewati air, dan determinisme 50 tick.
- `tests/test_physics_gas.gd`: Gelembung udara naik melewati air, gelembung keluar diagonal di bawah atap tertutup, dan determinisme 50 tick.
- `tests/test_physics_integration.gd`: Campuran multi-material (batu, air, pasir, udara) 100 tick identik deterministik, dan order-independence chunk.
- `tests/test_benchmark.gd`: Chunk 64x64 dengan ~1000 sel aktif berjalan 100 tick dengan rata-rata waktu < 50 ms/tick di CI (target VPS ARM64 < 8 ms/tick).

## Penjelasan untuk pemain (ringkas)
Pasir jatuh karena lebih berat dari udara. Air mengalir ke tempat lebih rendah dan menyebar. Udara naik karena lebih ringan dari air.

## Penjelasan untuk pemain (mendalam)
Zat diatur oleh massa jenis (kerapatan). Benda yang lebih padat/berat ditarik ke bawah oleh gravitasi dan mendesak benda yang lebih ringan ke atas (gaya apung Archimedes). Di Zarah versi ini, simulasi disederhanakan menggunakan kisi sel teratur (cellular automata) dan perpindahan panas serta tekanan fluida penuh belum diperhitungkan.
