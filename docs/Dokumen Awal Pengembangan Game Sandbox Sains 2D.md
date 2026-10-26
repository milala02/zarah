# Dokumen Awal Pengembangan: Game Sandbox Sains 2D

Versi 0.1 · 26 Oktober 2026 · Judul kerja: Zarah · Status: draf untuk ditinjau pemilik proyek

## 0. Cara memakai dokumen ini

Dokumen ini adalah sumber kebenaran tunggal proyek. Pemilik proyek dan agen AI sama-sama bekerja dari sini.

- Urutan baca: bagian 1 sampai 3 untuk memahami arah, bagian 5 dan 6 untuk spesifikasi teknis, bagian 7 dan 8 untuk aturan kerja.
- Spesifikasi hanya boleh berubah lewat revisi dokumen ini, bukan lewat improvisasi saat coding.
- Bagian 12 mencatat keputusan awal. Jika sebuah keputusan belum tercatat, agen harus bertanya dan tidak boleh menebak.
- Lampiran A, B, dan C siap disalin menjadi file di repo.

## 1. Visi produk

**Satu kalimat:** game sandbox 2D bergaya Terraria di mana dunia diatur oleh hukum fisika, kimia, dan biologi yang disimulasikan, sehingga pemain belajar sains dengan bereksperimen.

**Lima pilar:**

1. **Sandbox 2D:** menjelajah, menggali, membangun, dan bertahan dalam dunia tile yang bisa diubah.
2. **Sains sebagai sistem, bukan konten:** fenomena muncul dari aturan simulasi, bukan dari skrip yang ditulis satu per satu.
3. **Belajar lewat bermain:** pemain bereksperimen, melihat akibatnya, lalu membaca penjelasannya.
4. **Solo dan offline:** tidak butuh internet, akun, atau server.
5. **Aman untuk anak:** tanpa iklan, tanpa data pribadi, tanpa chat online.

**Pemain:** utama adalah pembuat game sendiri. Sekunder adalah anak-anak dan siapa pun yang suka sains. Usia target bervariasi, dari anak-anak sampai dewasa. Karena itu penjelasan sains dibuat berlapis (ringkas dan mendalam) dan konten dijaga ramah anak sebagai batas dasar.

**Bukan tujuan versi 1:** multiplayer, monetisasi, iklan, akun online, dan realisme ilmiah tingkat riset.

## 2. Prinsip desain sains: realistis yang bisa dimainkan

Realisme penuh tidak mungkin dan tidak perlu. Yang penting adalah konsistensi dan kejujuran tentang penyederhanaan.

**Tiga tingkat kesetiaan:**

| Tingkat | Arti | Contoh |
| --- | --- | --- |
| A: tepat | Mengikuti hukum atau data nyata | Kekekalan massa, kerapatan relatif material, urutan titik didih |
| B: disederhanakan | Meniru perilaku, rumusnya dipangkas | Aliran cairan, konduksi panas antar sel |
| C: stilisasi | Demi keterbacaan atau kesenangan | Kecepatan tumbuh tanaman, ukuran dunia |

**Aturan wajib:**

- Setiap sistem sains punya **Kartu Sains** (Lampiran C): hukum yang ditiru, penyederhanaan yang dipilih, sumber rujukan, dan tes yang membuktikannya.
- Tidak ada penjelasan edukasi tanpa Kartu Sains. Agen dilarang mengarang fakta sains.
- Penyederhanaan harus dinyatakan jujur di jurnal game, misalnya "di game ini dibuat lebih cepat dari aslinya".
- Yang tidak diketahui atau diperdebatkan tidak dimasukkan sebagai fakta.
- Konsistensi internal lebih penting daripada akurasi parsial. Dua sistem tidak boleh saling bertentangan.

## 3. Lingkup dan strategi anti-membengkak

Target akhirnya besar: Terraria penuh dengan lapisan sains. Karena itu strategi kerjanya harus ketat.

**Aturan lingkup:**

- **Vertical slice dulu:** selalu ada versi yang bisa dimainkan di HP. Tidak ada fase "membangun semuanya dulu, mainkan nanti".
- **Satu sistem sekali:** sistem baru dimulai hanya jika sistem sebelumnya sudah punya tes, lolos CI, dan sudah dicoba di HP.
- **Bug lebih dulu daripada fitur:** daftar bug terbuka harus kosong atau terjadwal sebelum milestone baru.
- **Tanpa estimasi tanggal** sebelum M1 selesai. Kecepatan kerja diukur dulu, baru dijadwalkan.

**Daftar sistem dan prioritas:**

| Sistem | Prioritas | Milestone |
| --- | --- | --- |
| Dunia tile, chunk, simpan/muat | P0 | M1 |
| Pemain, gerak, gali dan bangun | P0 | M1 |
| Fisika material (gravitasi, cairan, gas) | P0 | M2 |
| Termal (panas, perubahan wujud, api) | P1 | M3 |
| Kimia (material dan reaksi) | P1 | M4 |
| Crafting berbasis sifat material | P1 | M5 |
| Mode edukasi (Jurnal Sains, eksperimen) | P1 | M5 |
| Biologi (tumbuhan, lalu hewan) | P2 | M6 |
| Cuaca dan iklim | P2 | M7 |
| Musuh, progres, mode bertahan | P3 | M8 |
| Audio, tutorial, polish | P3 | M9 |

## 4. Spesifikasi gameplay

**Loop inti:** jelajahi, gali, amati, bereksperimen, buat sesuatu, bertahan atau berkembang, lalu temukan fenomena baru.

**Mode permainan:**

- **Eksplorasi:** tanpa musuh, fokus eksperimen. Mode utama untuk anak-anak.
- **Bertahan:** ada musuh, kebutuhan dasar, dan progres. Hadir di M8.

**Progres lewat pengetahuan:** kemampuan dan resep terbuka karena pemain menemukan atau memahami sesuatu, bukan hanya karena mengumpulkan item. Contoh: setelah pemain mengamati bahwa kayu terbakar dan menghasilkan arang, resep arang terbuka.

**Jurnal Sains:** setiap fenomena yang diamati pemain tercatat dengan penjelasan singkat, diambil dari Kartu Sains. Penjelasan punya dua tingkat, ringkas dan mendalam.

**Dunia:**

- Dunia 2D samping (side-view), dibuat dari seed, dibagi dalam chunk.
- Beberapa biom dengan material dan iklim berbeda. Daftar biom ditetapkan di M1 sampai M2.
- Siklus siang dan malam memengaruhi suhu dan cahaya (cahaya dibutuhkan tumbuhan).

**Kontrol sentuh (target utama Android):**

- Joystick virtual untuk gerak, tombol lompat, dan tombol aksi.
- Ketuk atau tahan pada tile untuk menggali atau menaruh.
- Pemilih alat dan item berupa bilah cepat di tepi layar.
- Ukuran target sentuh minimal sekitar 48 dp. Semua tombol harus bisa dijangkau ibu jari.

## 4A. Arah visual dan akurasi warna

Zarah harus indah dilihat, dan warna materialnya harus bisa dipertanggungjawabkan secara ilmiah. Dua tuntutan ini diperlakukan sebagai aturan teknis, bukan selera.

**Arah visual: pixel art yang kaya dan cantik**

- Pixel art dengan detail dan pengerjaan halus, bukan versi sederhana. Semua aset orisinal, terinspirasi kualitas genre, bukan tiruan game lain.
- Tile dasar 16 x 16 piksel (usulan), diskalakan dengan bilangan bulat agar tetap tajam. Resolusi final diputuskan di M1 setelah dicoba di HP.
- Setiap material punya beberapa varian tile (usulan 4 sampai 8) dan tepi otomatis (autotile), supaya permukaan tidak terlihat berulang.
- Kecantikan datang dari lapisan: pencahayaan 2D dengan bayangan, latar berlapis (parallax), partikel (percikan, uap, debu), dan animasi untuk air, api, dan tumbuhan.
- Efek harus tetap ringan. Semuanya diukur terhadap anggaran performa di bagian 6.3, dengan renderer Compatibility sebagai batas.
- Palet dijaga konsisten per biom. Warna bukan satu-satunya penanda, dan ada mode ramah buta warna yang hanya mengubah tampilan.
- Semua aset dicatat di `ASSETS.md` dengan sumber, pembuat, dan lisensi. Aset buatan generator AI hanya dipakai jika lisensi dan kebijakan toko aplikasinya sudah diperiksa.

**Akurasi warna material**

Prinsipnya: warna material di game sesuai warna aslinya pada kondisi yang ditiru, dan sumbernya tercatat.

1. Setiap material punya `warna_dasar` (nilai sRGB) di `data/materials`. Nilainya diturunkan dari rujukan terukur, misalnya foto spesimen standar, katalog mineral, atau tabel warna ilmiah. Rujukannya dicatat di Kartu Sains.
2. Warna bergantung pada kondisi: fase (padat, cair, gas), suhu, kemurnian, dan reaksi seperti oksidasi. Data mencatat varian warna per kondisi.
3. Pijar logam dan batuan panas mengikuti warna radiasi benda hitam menurut suhu: mulai tampak merah redup sekitar 525 derajat Celsius, oranye sekitar 1000, dan kuning keputihan di atas sekitar 1200. Angka ini perkiraan dan wajib diverifikasi dari rujukan sebelum dikunci.
4. Warna nyala mengikuti zat yang terbakar, misalnya natrium kuning-oranye dan tembaga hijau kebiruan.
5. Cahaya, bayangan, dan filter hanya menambah lapisan di atas warna dasar. Keduanya tidak boleh mengubah nilai di data.
6. Warna yang sengaja distilisasi (tingkat C) ditandai di Kartu Sains dan dijelaskan di jurnal.
7. Tes otomatis memastikan setiap material punya warna dasar dan rujukan, dan selisih warna terhadap rujukan (ΔE) tidak melewati ambang yang ditetapkan di M2.

Contoh arah warna (nilai hex diisi dari rujukan, bukan dari tabel ini):

| Material atau kondisi | Warna yang ditiru | Catatan |
| --- | --- | --- |
| Tembaga murni | Oranye kemerahan logam | Berubah hijau kebiruan (patina) setelah teroksidasi lama |
| Besi berkarat | Cokelat kemerahan sampai oranye | Bergantung pada kelembapan dan lama berkarat |
| Belerang | Kuning | Stabil pada suhu ruang |
| Es | Putih kebiruan, tembus cahaya | Lapisan tebal tampak lebih biru |
| Air | Hampir bening | Kebiruan hanya pada kedalaman besar |
| Logam pijar | Merah redup, oranye, kuning keputihan | Mengikuti suhu |
| Nyala api | Kuning-oranye pada kayu | Berubah menurut zat, misalnya hijau kebiruan pada tembaga |

Keterbatasan: layar HP menampilkan warna berbeda-beda. Akurasi di sini berarti sesuai rujukan sRGB, bukan identik di setiap layar.

## 5. Spesifikasi sistem simulasi

### 5.1 Representasi dunia

- Dunia adalah grid sel. Satu sel mewakili 0,5 meter, sehingga pemain setinggi sekitar 3 sel. Dunia awal berukuran 2048 x 512 sel (sekitar 1 km lebar dan 256 m dalam) dan bisa diperbesar kemudian. Setiap sel punya: `material_id`, `suhu`, `massa` atau `kepadatan`, `fase` (padat, cair, gas), dan penanda ringan (misalnya umur atau kelembapan).
- Dunia dibagi chunk (usulan awal 64 x 64 sel). Hanya chunk aktif yang disimulasikan. Chunk memakai penanda `dirty` agar sel yang tidak berubah tidak dihitung ulang.
- Simulasi berjalan pada **tick tetap** (usulan 20 kali per detik), terpisah dari render. Render menginterpolasi.
- **Deterministik:** seed ditambah urutan input harus menghasilkan keadaan dunia yang sama. Ini syarat untuk tes snapshot dan untuk menemukan bug.

### 5.2 Fisika

- Gravitasi sel: padatan lepas (pasir, kerikil) jatuh dan menumpuk.
- Cairan: mengalir ke bawah lalu menyebar, dengan aturan tekanan sederhana.
- Gas: berdifusi dan naik atau turun menurut kerapatan.
- Apung: material yang lebih ringan naik melewati yang lebih berat.
- Struktur (tahap lanjut): kestabilan bangunan menurut beban dan kekuatan material. Tidak masuk sebelum M3.

### 5.3 Termal

- Konduksi panas antar sel bertetangga, bergantung pada daya hantar material.
- Kapasitas panas menentukan seberapa cepat suhu naik atau turun.
- Perubahan wujud (es, air, uap) terjadi di ambang suhu yang ada di data material.
- Api diperlakukan sebagai reaksi kimia pembakaran yang butuh bahan bakar, oksigen, dan suhu.

### 5.4 Kimia

- **Basis data material:** nama, fase, kerapatan, suhu transisi, daya hantar panas, kapasitas panas, mudah terbakar atau tidak, warna.
- **Basis data reaksi:** reaktan, produk, syarat (suhu, katalis, kehadiran gas), dan energi yang dilepas atau diserap.
- **Kekekalan:** tes otomatis memeriksa bahwa setiap reaksi menjaga massa (dan unsur, bila dimodelkan). Reaksi yang melanggar tidak boleh masuk basis data.
- Reaksi awal (sekitar 10): pembakaran kayu, pembekuan dan pencairan air, penguapan, pembentukan arang, dan beberapa lagi yang ditetapkan di M4.

### 5.5 Biologi

- Tumbuhan: butuh cahaya, air, dan nutrisi tanah. Hasil fotosintesis berupa biomassa.
- Hewan sederhana dan rantai makanan: hanya setelah tumbuhan stabil, bukan sebelum M6 selesai.
- Ekosistem: keseimbangan populasi sederhana. Ditunda ke tahap lanjut.

### 5.6 Berbasis data

Material, reaksi, biom, dan resep disimpan di file data (usulan JSON atau TOML) dengan skema yang divalidasi saat build. Tidak ada angka sains yang ditanam langsung di kode.

## 6. Arsitektur teknis

### 6.1 Keputusan awal (ADR)

| ID | Keputusan | Alasan | Pemicu tinjau ulang |
| --- | --- | --- | --- |
| ADR-001 | Mesin: Godot 4 (diputuskan) | Sistem tile dan chunk bawaan, ekspor Android, build headless di CI | Jika build Android dari CI terus gagal |
| ADR-002 | Inti simulasi dipisah dari mesin (folder `sim/`, tanpa ketergantungan scene) | Bisa dites tanpa menjalankan game | Tidak ada |
| ADR-003 | Mulai dengan GDScript bertipe statis, ukur performa, baru pertimbangkan C# atau ekstensi native | Kesederhanaan dulu, optimasi berdasarkan data | Simulasi melewati anggaran waktu di perangkat uji |
| ADR-004 | Semua parameter sains di file data | Mudah diaudit dan diubah tanpa menyentuh kode | Tidak ada |

### 6.2 Struktur repo (usulan)

```
/
  AGENTS.md
  docs/            # dokumen ini dan turunannya
  data/            # material, reaksi, biom, resep + skema
  sim/             # inti simulasi murni, tanpa scene
  game/            # scene, UI, kontrol, render
  tests/           # unit, properti, snapshot, benchmark
  tools/           # skrip validasi data, generator
  .github/workflows/
```

### 6.3 Target performa (usulan, diukur di HP uji milik pemilik)

- Render 60 FPS pada perangkat uji dalam kondisi normal.
- Langkah simulasi chunk aktif di bawah 8 ms per tick.
- Memori stabil, tanpa kebocoran selama sesi 30 menit.
- Ukuran APK debug dicatat sejak M0 agar pertumbuhan terpantau.

### 6.4 Penyimpanan

- Simpan lokal per chunk, dengan nomor versi skema di setiap file.
- Autosave berkala dan saat aplikasi masuk latar belakang.
- Migrasi skema ditulis bersama setiap perubahan format, lengkap dengan tes.

### 6.5 Build dan alur lingkungan

- Pengembangan hanya di VPS. Build APK dan AAB lewat GitHub Actions secara headless.
- Setiap push menjalankan: validasi data, lint, tes unit dan properti, tes snapshot, lalu build APK debug sebagai artefak.
- Pengujian manual: unduh APK dari artefak CI, pasang di HP, lalu catat hasilnya.

## 7. Standar kualitas (Definition of Done)

Sebuah tugas dianggap selesai hanya jika semua ini terpenuhi:

1. Ada spesifikasi dan kriteria penerimaan yang terukur.
2. Ada tes otomatis yang gagal sebelum perubahan dan lulus sesudahnya.
3. CI hijau.
4. Sudah dicoba di HP, hasilnya dicatat.
5. Kartu Sains diperbarui jika menyentuh sistem sains.
6. Catatan perubahan ditulis.

**Jenis tes:**

- **Unit:** fungsi kecil di `sim/`.
- **Properti:** kekekalan massa, energi tidak muncul dari ketiadaan, hasil tidak bergantung pada urutan iterasi sel.
- **Snapshot deterministik:** seed dan input yang sama harus menghasilkan keadaan dunia yang identik.
- **Benchmark:** waktu tick pada skenario baku.
- **Smoke:** game bisa start, memuat dunia, dan menyimpan tanpa error (headless).

**Aturan kode:**

- Fungsi kecil, tipe statis, tanpa state global tersembunyi.
- Tidak ada angka ajaib. Konstanta sains ada di `data/`.
- Perubahan per PR kecil (pedoman sekitar 300 baris). PR besar dipecah.
- Setiap bug diperbaiki bersama tes regresi.

## 8. Protokol kerja dengan agen AI

Pendekatan "vibe coding serius": manusia memegang arah dan keputusan, agen mengerjakan unit kerja kecil yang bisa diverifikasi.

**Alur setiap tugas:**

1. Agen membaca bagian spesifikasi yang relevan dan `AGENTS.md`.
2. Agen menulis rencana singkat dan menunggu persetujuan.
3. Agen mengerjakan satu unit kecil sekaligus.
4. Agen menjalankan tes lokal, lalu mendorong ke CI.
5. Agen menulis ringkasan: apa yang berubah, apa yang diuji, apa yang belum.
6. Manusia meninjau dan mencoba di HP.

**Larangan bagi agen:**

- Mengubah spesifikasi atau Kartu Sains tanpa persetujuan.
- Menonaktifkan, melonggarkan, atau menghapus tes agar CI hijau.
- Mengarang fakta sains, rumus, atau angka.
- Menambah fitur di luar tugas.
- Melanjutkan saat spesifikasi ambigu. Agen wajib bertanya.

**Mitigasi berdasarkan pengalaman proyek sebelumnya yang hasilnya banyak kesalahan:** tugas dibuat kecil, setiap hasil diverifikasi tes, dan manusia meninjau di setiap milestone. Agen tidak diberi tugas besar tanpa kriteria penerimaan.

**Konteks:** dokumen ini bisa dimuat utuh ke agen berkonteks panjang, tetapi ukuran konteks tidak menggantikan tugas yang kecil dan terukur.

## 9. Peta jalan milestone

Milestone ditandai oleh syarat keluar, bukan tanggal.

| Milestone | Isi | Syarat keluar |
| --- | --- | --- |
| M0 Fondasi | Repo, proyek Godot, CI, tes headless, APK debug kosong | APK terpasang di HP, CI hijau |
| M1 Dunia dan pemain | Tile, chunk, kamera, gerak, gali dan bangun, simpan dan muat, gaya visual dan palet awal | 10 menit bermain tanpa crash, target FPS tercapai |
| M2 Material bergerak | Pasir, air, gas, kerapatan, apung | Tes deterministik lulus, tick sesuai anggaran |
| M3 Termal | Konduksi, perubahan wujud, api awal | Es, air, uap berperilaku benar; tes kekekalan lulus |
| M4 Kimia | Basis data reaksi, sekitar 10 reaksi | Semua reaksi lolos tes kekekalan |
| M5 Crafting dan Jurnal | Crafting berbasis sifat, Jurnal Sains v1 | Setiap resep dan entri jurnal punya Kartu Sains |
| M6 Biologi | Tumbuhan, siklus cahaya dan air | Tanaman tumbuh dan mati sesuai syarat, ada tes |
| M7 Cuaca | Hujan, suhu harian | Cuaca memengaruhi simulasi tanpa pelanggaran tes |
| M8 Bertahan | Musuh, kebutuhan dasar, progres | Satu sesi bertahan penuh bisa dimainkan |
| M9 Polish dan rilis tertutup | Audio, tutorial, penyeimbangan | Uji oleh beberapa pemain di luar pembuat |

## 10. Risiko dan mitigasi

| Risiko | Dampak | Mitigasi |
| --- | --- | --- |
| Lingkup membengkak | Proyek tidak selesai | Aturan satu sistem sekali, vertical slice, syarat keluar per milestone |
| Simulasi lambat di HP | Game patah-patah | Chunk aktif, penanda dirty, anggaran waktu, benchmark di CI |
| Sains salah atau menyesatkan | Misinformasi kepada anak-anak | Kartu Sains wajib, rujukan jelas, penyederhanaan dinyatakan terbuka |
| Kualitas kode agen | Banyak bug | Tugas kecil, tes wajib, tinjauan manusia, larangan melonggarkan tes |
| Kontrol sentuh tidak nyaman | Pemain frustrasi | Uji kontrol sejak M1 di HP nyata |
| Hanya satu perangkat uji | Bug di perangkat lain tidak terlihat | Catat spesifikasi perangkat uji, tambah uji perangkat lain sebelum rilis |
| Kelelahan sebagai pengembang tunggal | Proyek terhenti | Milestone kecil yang memberi hasil bisa dimainkan lebih cepat |
| Kemiripan dengan Terraria | Masalah hak cipta | Semua nama, karakter, dan aset orisinal. Hanya genre yang terinspirasi |

## 11. Keselamatan anak dan konten

- Tanpa iklan, tanpa pelacakan, tanpa data pribadi, tanpa chat online.
- Kekerasan dijaga ringan dan tidak realistis. Mode Eksplorasi tanpa musuh.
- Sebelum rilis publik, periksa kebijakan Google Play untuk aplikasi yang menyasar anak dan keluarga, karena aturannya bisa berubah.

## 12. Keputusan awal

Item berlabel "diputuskan" adalah keputusan awal yang sudah ditetapkan. Tinjau ulang jika arah proyek berubah:

1. Judul kerja game: diputuskan, Zarah (periksa ketersediaan nama sebelum rilis).
2. Usia target: diputuskan, bervariasi dari anak-anak sampai dewasa, dengan penjelasan berlapis.
3. Skala dunia: diputuskan, satu sel mewakili 0,5 meter.
4. Ukuran dunia: diputuskan, awal 2048 x 512 sel. Biom awal: diputuskan, empat.
5. Gaya visual: diputuskan, pixel art yang cantik dan kaya detail (bukan sederhana), dengan warna material seakurat mungkin dengan aslinya (lihat bagian 4A).
6. Bahasa antarmuka: diputuskan, Indonesia dulu. Teks disimpan di file terjemahan agar bahasa lain mudah ditambah.
7. Mode permainan: diputuskan, Eksplorasi dulu. Bertahan menyusul di M8.
8. Mesin: diputuskan, Godot 4.
9. Versi Android minimum: diputuskan, Android 8 ke atas.

## Lampiran A: Draf AGENTS.md (siap salin)

```
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
```

## Lampiran B: Template Task Brief

```
Judul:
Tujuan (satu kalimat):
Konteks (bagian spesifikasi yang relevan):
Kriteria penerimaan (terukur):
Di luar lingkup:
Tes yang diharapkan:
Risiko atau hal yang perlu ditanyakan:
```

## Lampiran C: Template Kartu Sains dan contoh

**Template:**

```
Fenomena:
Hukum atau prinsip:
Penyederhanaan:
Parameter dan warna dasar sRGB beserta rujukannya (di data/):
Sumber rujukan:
Tes pembuktian:
Penjelasan untuk pemain (ringkas):
Penjelasan untuk pemain (mendalam):
```

**Contoh: air membeku dan es mengapung**

```
Fenomena: Air cair menjadi es di suhu rendah, dan es mengapung di air.
Hukum atau prinsip: Perubahan wujud pada titik beku (0 derajat Celsius pada tekanan 1 atm). Es lebih renggang daripada air cair sehingga kerapatannya lebih kecil (sekitar 917 kg per meter kubik dibanding sekitar 1000).
Penyederhanaan: Tidak ada pendinginan lewat dari titik beku (supercooling). Tekanan dianggap tetap 1 atm.
Parameter: titik beku, kerapatan air, kerapatan es, kalor laten (di data/materials).
Sumber rujukan: diisi pemilik proyek dari buku teks atau sumber ilmiah terpercaya sebelum fitur dirilis.
Tes pembuktian: massa total sebelum dan sesudah membeku sama; sel es naik melewati sel air saat bergerak ke atas.
Penjelasan ringkas: Air memuai saat membeku, jadi es lebih ringan dan mengapung.
Penjelasan mendalam: Ikatan hidrogen mengatur molekul air menjadi struktur heksagonal yang lebih renggang saat membeku.
```
