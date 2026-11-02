# PRD: Aplikasi Olahraga Rumah (Program 30 Hari)

| | |
|---|---|
| Versi | 1.0 (siap dibangun) |
| Tanggal | 1 November 2026 |
| Platform | Android (Flutter) |
| Jenis | Aplikasi pribadi, offline-first, tanpa backend |
| Desain acuan | Canvas "Desain Aplikasi Olahraga Rumah" (layar Hari Ini, Kalender, Detail Gerakan) |

---

## 1. Latar Belakang

Pengguna punya target olahraga di rumah tanpa alat (push up, squat, plank, dll.) tetapi belum punya panduan terstruktur dan pencatatan yang konsisten. Aplikasi ini menyediakan program 30 hari yang jelas, contoh gerakan yang dapat dilihat kapan saja, serta pencatatan progres harian.

## 2. Tujuan

**Sasaran utama aplikasi: membentuk otot (hipertrofi) dan meningkatkan kekuatan, bukan menurunkan berat badan.** Semua fitur dirancang untuk sasaran ini.

1. Menjalankan program latihan 30 hari dengan jadwal yang jelas per hari.
2. Memberi contoh gerakan yang benar beserta otot yang bekerja, form, dan kesalahan umum.
3. Mencatat set, rep, dan streak agar progres terlihat.
4. Berjalan sepenuhnya offline dan gratis saat dipakai.

### Bukan tujuan (v1)
- Akun, login, sinkronisasi cloud, atau fitur sosial.
- Pemanggilan AI saat aplikasi berjalan (semua konten dibuat sekali di luar aplikasi).
- Deteksi gerakan lewat kamera (masuk roadmap).
- Penurunan berat badan, target kalori, atau defisit kalori. Satu-satunya panduan nutrisi adalah panduan protein (v1.1).

## 3. Pengguna

Satu pengguna: pemilik aplikasi, berlatih di rumah tanpa alat, level pemula sampai menengah, ingin target harian yang tegas dan mudah dicentang.

## 4. Ruang Lingkup Fitur (MVP)

### 4.1 Layar Hari Ini
- Menampilkan hari ke-N dari 30 dan progress bar.
- Ringkasan: streak, estimasi durasi latihan.
- Daftar gerakan hari itu dengan thumbnail contoh dan target (set x rep atau durasi).
- Tombol **Mulai latihan**.
- Navigasi bawah: Hari Ini, Kalender, Gerakan, Progres.

### 4.2 Kalender 30 Hari
- Grid 7 kolom, hari 1 sampai 30.
- Setiap sel menampilkan nomor hari dan kode jenis latihan: **P** Dorong, **K** Kaki, **C** Core, **F** Full body, **R** Istirahat.
- Status sel: selesai (redup), hari ini (disorot), mendatang, terlewat.
- Mengetuk sel menampilkan ringkasan latihan hari itu dan membuka detailnya.

### 4.3 Detail Gerakan
- Dua gambar contoh: posisi awal dan posisi akhir (opsional animasi loop).
- Otot utama dan otot penstabil.
- Langkah form yang benar, kesalahan umum, panduan napas.
- Variasi lebih mudah dan lebih sulit.
- Tombol **Catat set**.

### 4.4 Sesi Latihan
- Mode satu gerakan per layar: target, penghitung set, input rep aktual.
- Timer istirahat otomatis antar set (default 60 detik, bisa diubah).
- Tombol lewati gerakan dan akhiri sesi.
- Layar tetap menyala selama sesi.

### 4.5 Progres
- Streak saat ini dan terpanjang.
- Total rep per gerakan dan per minggu.
- Riwayat sesi (tanggal, gerakan, set, rep).
- **Perkembangan bentuk otot** (v1), dijelaskan di bawah.

**Hari ukur**
- Pengukuran dan foto dilakukan pada **hari 1, hari 15, dan hari 30**, sama dengan jadwal tes ulang kemampuan, sehingga pengguna hanya diingatkan tiga kali selama program.
- Pengukuran juga dapat ditambah manual kapan saja dari layar Progres.

**Lingkar badan**
- Titik ukur default: lengan atas, dada, pinggang, paha. Pengguna dapat menambah atau menyembunyikan titik ukur (mis. bahu, betis).
- Satuan sentimeter. Setiap titik ukur menampilkan grafik garis dan selisih terhadap hari 1 (mis. "Lengan +1,5 cm").
- Layar input menampilkan ilustrasi cara mengukur (posisi pita ukur, kondisi otot rileks) agar hasil konsisten.

**Foto progres**
- Tiga sudut: depan, samping, belakang.
- Layar kamera memberi panduan agar foto konsisten: garis bantu, pengatur waktu 10 detik, dan saran memakai pencahayaan dan jarak yang sama.
- Perbandingan berdampingan atau geser (slider) antara dua tanggal, mis. hari 1 dan hari 30.
- Foto disimpan di folder privat aplikasi, **tidak muncul di galeri** dan tidak dikirim ke mana pun. Pengguna dapat menghapus foto kapan saja, dan opsi ekspor tersedia di Pengaturan.
- Foto bersifat opsional; pengguna dapat memakai lingkar badan saja.

### 4.6 Onboarding: Profil dan Tes Kemampuan
Diisi saat pertama kali membuka aplikasi; semua dapat diubah atau diulang kapan saja.

**Langkah 1, profil**
- Data: usia, tinggi badan, berat badan, tujuan (**membentuk otot** sebagai default, kekuatan, daya tahan), jumlah hari latihan per minggu.
- Kegunaan data tubuh: **target protein harian** (v1.1) dan **level cadangan** bila tes dilewati. Tidak ada estimasi kalori terbakar, pengingat, atau grafik berat badan karena sasaran aplikasi bukan penurunan berat.
- Berat badan dapat diedit di Pengaturan kapan saja bila pengguna ingin target protein lebih akurat; tidak ada kewajiban memperbaruinya.
- Semua data disimpan lokal di perangkat dan tidak dikirim ke mana pun.

**Langkah 1b, kuesioner kesiapan**
Lima pertanyaan ya/tidak, tampil sekali sebelum tes:
1. Pernah diberi tahu dokter bahwa ada masalah jantung atau tekanan darah?
2. Merasa nyeri dada atau pusing saat berolahraga?
3. Ada cedera atau nyeri sendi (bahu, pergelangan tangan, lutut, punggung) saat ini?
4. Sedang hamil atau baru menjalani operasi?
5. Ada kondisi lain yang membuat dokter melarang olahraga?

- Semua jawaban "tidak": lanjut seperti biasa.
- Ada jawaban "ya": tampilkan peringatan untuk berkonsultasi dengan dokter atau fisioterapis, sarankan mulai dengan variasi lebih mudah, namun **tidak memblokir** pengguna.
- Tidak ada ambang usia atau berat badan yang memicu peringatan; angka semacam itu tidak cukup menggambarkan kesiapan seseorang.
- Jawaban disimpan lokal (`readiness_flags`) dan dapat diubah di Pengaturan.

**Langkah 2, tes kemampuan maksimum**
Aplikasi menanyakan kemampuan maksimum pengguna lewat empat tes singkat. Setiap tes punya contoh gerakan, instruksi form, dan input hasil. Pengguna dapat melewati tes mana pun.

| Tes | Cara | Hasil yang dicatat |
|---|---|---|
| Push up | Sebanyak mungkin dengan form benar sampai gagal | Jumlah rep |
| Squat | Sebanyak mungkin dengan form benar, maksimal 60 detik | Jumlah rep |
| Sit up | Sebanyak mungkin dengan form benar, maksimal 60 detik | Jumlah rep |
| Plank | Tahan selama mungkin dengan badan lurus | Detik |

- Istirahat minimal 2 menit antar tes (timer ditampilkan).
- Layar tes menampilkan pengingat: berhenti bila nyeri sendi, pusing, atau form rusak.
- Pengguna yang tidak sanggup satu rep penuh boleh memilih variasi lebih mudah (mis. knee push up), dan hasilnya dicatat untuk variasi itu.
- Aplikasi menawarkan tes ulang **hanya pada hari 15 dan hari 30**. Tes ulang manual tetap tersedia di Pengaturan, tetapi tidak ada pengingat tambahan.

### 4.7 Pengaturan
- Tanggal mulai program (bebas dipilih pengguna, lihat bagian 5).
- Tema: **gelap**, **terang**, atau ikut sistem.
- Bahasa: **Indonesia dan Inggris** saja pada v1.
- Durasi istirahat default antar set.
- Pengingat harian (notifikasi lokal) pada jam yang dipilih.
- Reset program dan ekspor data (JSON).

### 4.8 Panduan Protein Harian (v1.1)

Fitur yang memberi tahu sisa kebutuhan protein hari ini dan menyarankan makanan murah untuk menutupnya, misalnya: *"Hari ini kamu masih butuh 17 g protein. Coba: 2 telur + 1 potong tempe."*

**Target harian**
- `target_g = berat_badan_kg x faktor`
- Faktor default mengikuti tujuan di profil: **membentuk otot 1,6**; kekuatan 1,4; daya tahan 1,2 (g per kg). Pengguna dapat mengubah faktor di Pengaturan.
- **Satu target tetap setiap hari**, sama di hari latihan maupun hari istirahat. Pemulihan dan pembentukan otot berlangsung sampai 1 hingga 2 hari setelah latihan, jadi hari istirahat tetap butuh protein. Satu angka juga paling mudah dipahami dan tidak membuat pengguna bingung.
- Hanya protein yang ditampilkan. Tidak ada target kalori makanan, tidak ada target penurunan berat, dan tidak ada ajakan makan lebih sedikit.
- Teks pendamping di kartu: otot juga butuh asupan makanan yang cukup secara keseluruhan; jangan menahan makan.

**Pencatatan ringan**
- Kartu protein di layar Hari Ini: bar progres, "Terpenuhi 67 g dari 84 g, **sisa 17 g**".
- Menambah asupan cukup dengan mengetuk chip makanan (mis. "1 telur", "tempe 50 g", "dada ayam 100 g"). Satu ketukan menambah satu porsi default; tekan lama untuk mengubah porsi.
- Tersedia input manual "tambah X gram protein" untuk makanan di luar daftar.
- Ada tombol batalkan untuk entri terakhir dan daftar entri hari ini yang dapat dihapus.
- Hari berganti pukul 00.00 waktu lokal; riwayat harian tersimpan.

**Mesin saran**
- Dijalankan lokal dari database makanan; tanpa AI saat aplikasi berjalan.
- Input: sisa protein, preferensi dan pantangan makanan pengguna, makanan yang sudah dicatat hari ini.
- Hasil: sampai 3 kombinasi (maksimal 3 bahan per kombinasi) yang total proteinnya mendekati sisa (selisih maksimal 3 g di atas atau di bawah).
- Urutan: tingkat biaya paling murah dahulu, lalu variasi (hindari bahan yang sudah dimakan berulang hari ini), lalu jumlah bahan paling sedikit.
- Sisa kecil (kurang dari 5 g) menampilkan satu saran ringan, misalnya 1 butir telur.
- Sisa nol atau negatif menampilkan "Target hari ini tercapai"; tidak ada dorongan makan lebih banyak.
- Contoh untuk sisa 17 g:
  - 2 telur (12 g) + tempe 30 g (6 g) = 18 g
  - Tahu 100 g (8 g) + tempe 50 g (10 g) = 18 g
  - 1 telur (6 g) + dada ayam 35 g (11 g) = 17 g

**Database makanan (JSON di assets, dua bahasa)**

```json
{
  "id": "egg",
  "name": { "id": "Telur", "en": "Egg" },
  "portion_label": { "id": "1 butir", "en": "1 egg" },
  "portion_g": 55,
  "protein_g": 6,
  "cost_tier": 1,
  "tags": ["halal", "vegetarian"],
  "allergens": ["egg"],
  "min_portion": 1,
  "max_portion": 4
}
```

- `cost_tier`: 1 murah, 2 sedang, 3 mahal. Harga tidak disimpan karena berubah-ubah dan berbeda tiap daerah.
- Daftar awal (default): telur, tempe, tahu, dada ayam, paha ayam, ikan lele, ikan tongkol, hati ayam, kacang tanah, ikan teri, oncom, susu.
- **Pengguna dapat menambah makanan sendiri**: nama, porsi, gram protein, dan tingkat biaya (opsional, default sedang). Makanan buatan pengguna ikut dipakai mesin saran dan dapat diedit atau dihapus.
- Nilai protein adalah perkiraan; layar menampilkan tanda "±".

**Preferensi makanan**
- Saat mengaktifkan fitur, pengguna memilih pantangan atau alergi (mis. telur, ikan, kacang) dan preferensi (mis. vegetarian).
- Bahan yang dikecualikan tidak pernah muncul di saran.

**Keamanan**
- Satu pertanyaan tambahan di kuesioner kesiapan saat fitur diaktifkan: "Pernah diberi tahu dokter untuk membatasi protein (mis. penyakit ginjal)?" Jawaban "ya" menampilkan peringatan dan menonaktifkan target protein otomatis; pengguna dapat tetap memakai input manual.
- Teks informasi: panduan ini bersifat umum dan bukan pengganti ahli gizi.

## 5. Aturan Program 30 Hari

Pola berulang tiap 7 hari:

| Hari ke- (dalam minggu) | Kode | Fokus |
|---|---|---|
| 1 | P | Dorong |
| 2 | K | Kaki |
| 3 | C | Core |
| 4 | R | Istirahat |
| 5 | P | Dorong |
| 6 | F | Full body |
| 7 | R | Istirahat |

Hari 29 = P, hari 30 = K.

### Gerakan per jenis sesi
- **P (Dorong)**: push up, diamond push up, incline push up, plank
- **K (Kaki)**: squat, lunges, glute bridge, calf raise
- **C (Core)**: plank, sit up, leg raise, mountain climber
- **F (Full body)**: burpee, squat jump, push up, mountain climber
- **R (Istirahat)**: tanpa latihan; opsional peregangan ringan

### Progres beban (set x rep, plank dalam detik)
| Minggu | Gerakan utama | Gerakan pendukung | Plank |
|---|---|---|---|
| 1 (hari 1-7) | 3 x 8 | 3 x 10 | 3 x 20 dtk |
| 2 (hari 8-14) | 3 x 10 | 3 x 12 | 3 x 25 dtk |
| 3 (hari 15-21) | 3 x 12 | 3 x 15 | 3 x 30 dtk |
| 4 (hari 22-30) | 4 x 12 | 4 x 15 | 3 x 40 dtk |

Tabel di atas adalah **target dasar level menengah**. Target sebenarnya dihitung dari profil pengguna (lihat bagian "Target mengikuti profil"). Semua angka disimpan di data konten, bukan di kode.

### Target mengikuti hasil tes dan profil
Target dasar pada tabel progres di atas adalah nilai cadangan. Bila pengguna menjalani tes kemampuan, target dihitung dari hasil tes:

`rep_per_set = max(3, round(hasil_tes x faktor_minggu))`

| Minggu | Faktor | Set |
|---|---|---|
| 1 | 0,60 | 3 |
| 2 | 0,65 | 3 |
| 3 | 0,70 | 3 |
| 4 | 0,75 | 4 |

- Berlaku untuk push up, squat, sit up, dan plank (hasil plank dalam detik, dengan batas bawah 15 detik).
- Faktor di atas untuk tujuan **membentuk otot** (default). Untuk membentuk otot, set terakhir tiap gerakan dikerjakan sampai hampir gagal (sisa sekitar 1 sampai 2 rep); layar sesi menampilkan petunjuk ini dan meminta input rep aktual.
- **Progresi beban**: bila semua set suatu gerakan melampaui target dengan selisih 3 rep atau lebih, aplikasi menyarankan variasi lebih sulit pada sesi berikutnya (mis. decline push up, pike push up, split squat). Dengan latihan tanpa alat, kenaikan kesulitan inilah yang menjaga otot terus terangsang.
- Gerakan tanpa tes langsung (diamond push up, incline push up, lunges, dll.) memakai hasil tes gerakan induknya dengan penyesuaian: variasi lebih mudah x1,2, lebih sulit x0,6.
- Bila tes dilewati, aplikasi memakai level cadangan dari profil:

| Level cadangan | Pengali target dasar |
|---|---|
| Pemula | 0,7x |
| Menengah | 1,0x |
| Lanjut | 1,3x |

- Tujuan menggeser fokus: *membentuk otot* (default) memakai rep sedang sampai hampir gagal, *kekuatan* menambah set dan memakai variasi lebih sulit dengan rep lebih sedikit, *daya tahan* menambah rep dan memperpendek istirahat.
- Jumlah hari latihan per minggu dari profil menentukan berapa hari istirahat di pola mingguan.
- Tes ulang (ditawarkan di hari 15 dan 30) menghitung ulang target untuk hari yang belum dikerjakan.
- Pengguna dapat mengubah target satu gerakan secara manual; perubahan manual menimpa hasil hitungan.
- Rumus ini versi awal dan perlu diuji di pemakaian nyata.

### Tanggal mulai dan kebebasan memilih hari
- Pengguna memilih tanggal mulai sendiri, tidak harus hari ini.
- Pengguna bebas mengetuk hari mana pun di kalender dan memulai sesinya, tidak harus berurutan.
- Hari istirahat dapat diganti menjadi hari latihan (pilih jenis P/K/C/F atau latihan ringan), dan sebaliknya hari latihan dapat dijadikan istirahat. Perubahan ini disimpan sebagai *override* per hari.
- Hari dapat ditukar posisinya; kalender menampilkan versi hasil perubahan.

### Aturan status hari
- Selesai: semua gerakan hari itu dicentang.
- Terlewat: hari lewat tanpa sesi selesai. Program **tidak bergeser otomatis**; pengguna boleh mengerjakan hari terlewat kapan saja, dan streak putus.
- Hari istirahat (termasuk hasil override pengguna) otomatis dihitung selesai dan tidak memutus streak.
- Jika pengguna melatih hari yang semula istirahat, hari itu dihitung sebagai bonus dan tidak berpengaruh negatif pada streak.

## 6. Model Data

### 6.1 Konten statis (JSON di assets)

```json
{
  "id": "push_up",
  "name": "Push Up",
  "category": "upper_body",
  "difficulty": "intermediate",
  "primary_muscles": ["pectoralis_major", "triceps", "anterior_deltoid"],
  "secondary_muscles": ["serratus_anterior", "core", "glutes", "quadriceps"],
  "steps": ["..."],
  "common_mistakes": ["..."],
  "breathing": "Tarik napas saat turun, hembuskan saat naik",
  "variations": ["knee_push_up", "diamond", "wide", "decline", "incline"],
  "media": { "start_pose": "push_up_start.png", "end_pose": "push_up_end.png" }
}
```

```json
{
  "program_id": "home_30",
  "days": [
    {
      "day": 1,
      "type": "P",
      "items": [
        { "exercise_id": "push_up", "sets": 3, "reps": 8 },
        { "exercise_id": "plank", "sets": 3, "duration_sec": 20 }
      ]
    }
  ]
}
```

### 6.2 Data pengguna (database lokal)

| Tabel | Kolom utama |
|---|---|
| `user_profile` | `goal`, `days_per_week`, `age`, `height_cm`, `weight_kg`, `fallback_level`, `readiness_flags`, `protein_factor`, `food_exclusions` |
| `fitness_test` | `id`, `tested_at`, `exercise_id`, `result` (rep atau detik), `variation_id` |
| `body_measurement` | `id`, `measured_at`, `site` (lengan, dada, pinggang, paha, dst.), `value_cm` |
| `progress_photo` | `id`, `taken_at`, `angle` (depan, samping, belakang), `file_path` (folder privat aplikasi) |
| `food_log` (v1.1) | `id`, `logged_at`, `food_id` (null bila manual), `portion_count`, `protein_g` |
| `custom_food` (v1.1) | `id`, `name`, `portion_label`, `protein_g`, `cost_tier`, `tags`, `allergens` |
| `program_state` | `start_date`, `rest_seconds`, `reminder_time`, `theme_mode`, `locale` |
| `day_override` | `day_number`, `type` (P/K/C/F/R/custom), `items_json` |
| `target_override` | `exercise_id`, `sets`, `reps`, `duration_sec` |
| `session` | `id`, `day_number`, `started_at`, `finished_at` |
| `set_log` | `id`, `session_id`, `exercise_id`, `set_no`, `reps`, `duration_sec` |

Streak dan total dihitung dari `session` dan `set_log`, tidak disimpan terpisah.

## 7. Konten Contoh Gerakan

- Dibuat **sekali** di luar aplikasi, lalu dimasukkan sebagai aset.
- Teks (langkah, otot, kesalahan umum): dibuat dengan Claude, disimpan di JSON, ditinjau manual.
- Gambar: pose awal dan akhir per gerakan, dibuat dengan AI image generation memakai prompt template dan gaya yang sama agar konsisten (ilustrasi datar, latar polos, satu karakter).
- Jumlah gerakan v1: sekitar 15.
- **Multi bahasa**: semua teks gerakan disimpan per bahasa (`id`, `en`), misalnya `"name": {"id": "Push Up", "en": "Push Up"}`. Gambar tidak boleh memuat teks agar tidak perlu dibuat ulang per bahasa.
- Semua gambar harus ditinjau manual terhadap form yang benar sebelum dipakai.

## 8. Rekomendasi Teknis

| Aspek | Pilihan |
|---|---|
| Framework | Flutter (satu codebase, UI animasi mudah) |
| State management | Riverpod |
| Database lokal | Drift (SQLite) |
| Notifikasi | `flutter_local_notifications` |
| Layar tetap menyala | `wakelock_plus` |
| Aset | Gambar WebP, JSON dimuat dari `assets/` |
| Lokalisasi | `flutter_localizations` + `intl` (file ARB untuk `id` dan `en`), fallback ke bahasa Inggris |
| Tema | `ThemeData` terang dan gelap, mode disimpan di `program_state` |
| Kamera dan foto | `camera` atau `image_picker`; file disimpan di folder privat aplikasi (`path_provider`), bukan di galeri |
| Arsitektur | Presentation, domain, data; repository untuk konten dan log |

## 9. Desain

- Dua tema: **gelap** (acuan desain saat ini) dan **terang**, dengan aksen hijau-lime yang disesuaikan agar kontras tetap terpenuhi di kedua tema. Desain tema terang belum dibuat di canvas.
- Tipografi condensed untuk judul dan sans untuk isi.
- Tata letak harus tahan terhadap teks yang lebih panjang di bahasa lain.
- Target sentuh minimal 44 px, kontras teks minimal 4.5:1.
- Kode jenis latihan tidak mengandalkan warna saja (selalu disertai huruf).
- Referensi visual: tiga layar pada canvas desain.

## 10. Kriteria Penerimaan

1. Kalender menampilkan 30 hari dengan kode jenis yang benar, dan hari ini tersorot sesuai `start_date`.
2. Membuka hari mana pun menampilkan daftar gerakan dan target sesuai program.
3. Sesi dapat diselesaikan: set tercatat, timer istirahat berjalan, hari ditandai selesai.
4. Streak naik saat hari selesai, putus saat hari terlewat, dan tidak putus pada hari istirahat.
5. Detail gerakan menampilkan gambar awal dan akhir, otot, form, dan kesalahan umum untuk semua gerakan program.
6. Seluruh fitur berjalan tanpa internet.
7. Data tetap ada setelah aplikasi ditutup dan dibuka ulang.
8. Pengingat harian muncul pada jam yang diatur.
9. Pengguna dapat memilih tanggal mulai dan memulai sesi hari mana pun dari kalender.
10. Hari istirahat dapat diubah menjadi hari latihan dan sebaliknya, dan perubahan tetap ada setelah aplikasi dibuka ulang.
11. Onboarding meminta data profil dan hasil empat tes kemampuan; tiap tes dapat dilewati; target hari-hari program dihitung dari hasil tes sesuai rumus.
12. Tes ulang menghitung ulang target hanya untuk hari yang belum dikerjakan.
13. Berat badan di profil dipakai untuk target protein (v1.1); aplikasi tidak menampilkan estimasi kalori maupun target penurunan berat di mana pun.
14. Kuesioner kesiapan muncul sebelum tes; jawaban "ya" menampilkan peringatan dan menyarankan variasi lebih mudah tanpa memblokir pengguna.
15. Mengganti tema (gelap, terang, sistem) dan bahasa (Indonesia, Inggris) langsung berlaku tanpa restart dan semua teks, termasuk konten gerakan, ikut berganti.
16. (v1.1) Kartu protein menampilkan target dari berat badan dan faktor, protein terpenuhi, dan sisa; sisa berubah setelah entri ditambah atau dihapus.
17. (v1.1) Untuk sisa protein tertentu (mis. 17 g), aplikasi menampilkan sampai 3 kombinasi dengan total dalam selisih 3 g, memakai maksimal 3 bahan, tidak memuat bahan yang dikecualikan, dan mengurutkan dari yang paling murah.
18. (v1.1) Saat target tercapai, tidak ada saran tambahan; tidak ada target kalori atau penurunan berat di mana pun.
19. Bila semua set suatu gerakan melampaui target dengan selisih 3 rep atau lebih, aplikasi menyarankan variasi lebih sulit untuk sesi berikutnya.
20. (v1.1) Pengguna dapat menambah makanan sendiri dan makanan itu muncul di mesin saran.
21. Pada hari 1, 15, dan 30 aplikasi menawarkan pengukuran lingkar badan dan foto; hasilnya tampil sebagai grafik per titik ukur beserta selisih terhadap hari 1.
22. Foto progres tersimpan di folder privat aplikasi, tidak tampak di galeri perangkat, dapat dibandingkan antar tanggal, dan dapat dihapus pengguna.

## 11. Rencana Pengerjaan

| Tahap | Isi |
|---|---|
| 1 | Konten: JSON gerakan dan program 30 hari, prompt dan pembuatan gambar |
| 2 | Kerangka aplikasi, navigasi, database, pemuat konten, lokalisasi dan tema |
| 3 | Onboarding (profil dan tes kemampuan), layar Hari Ini, Kalender, Detail Gerakan |
| 4 | Sesi latihan, timer istirahat, pencatatan set |
| 5 | Progres (termasuk lingkar badan dan foto), streak, pengingat, pengaturan |
| 6 | Uji manual di perangkat, perbaikan, rilis pribadi |
| 7 (v1.1) | Panduan protein: database makanan, pencatatan, mesin saran, layar kartu protein |

## 12. Risiko

| Risiko | Mitigasi |
|---|---|
| Gambar AI tidak konsisten atau form salah | Template prompt tetap, seleksi manual, mulai dari gambar statis |
| Beban program terlalu berat atau ringan | Angka target disimpan di JSON agar mudah disesuaikan |
| Motivasi turun saat hari terlewat | Hari boleh dikejar, tidak ada penalti selain streak |
| Cedera karena form salah | Tampilkan tips form dan variasi lebih mudah; konsultasi tenaga kesehatan bila ada cedera |
| Nilai protein makanan tidak akurat | Tampilkan sebagai perkiraan (±), porsi dapat diedit, input manual tersedia |
| Pencatatan makanan terasa merepotkan | Satu ketukan per entri, daftar chip, tanpa pencarian atau hitung gram |
| Foto progres bersifat pribadi | Disimpan di folder privat aplikasi, tidak masuk galeri, tidak dikirim keluar, dapat dihapus dan bersifat opsional |
| Ukuran lingkar tidak konsisten antar sesi | Ilustrasi cara mengukur, titik ukur yang sama tiap kali, hanya tiga hari ukur |

## 13. Roadmap Setelah v1

- Deteksi pose dan hitung repetisi otomatis (ML Kit Pose Detection).
- Animasi gerakan (Lottie atau video loop).
- Diagram tubuh dengan otot berwarna.
- Program lanjutan (60 atau 90 hari).
- Bahasa tambahan (opsional, belum direncanakan).
- Pencatatan dan grafik berat badan (hanya bila pengguna merasa perlu setelah memakai v1).
- Ekspor ke Health Connect.

## 14. Keputusan (sebelumnya pertanyaan terbuka)

| # | Pertanyaan | Keputusan |
|---|---|---|
| 1 | Tanggal mulai program | Bebas dipilih pengguna; pengguna juga bebas memilih hari mana pun di kalender |
| 2 | Hari istirahat boleh diganti latihan? | Boleh. Pengguna dan target menentukan, disimpan sebagai override per hari |
| 3 | Target plank dan gerakan lain | Mengikuti profil pengguna (level, tujuan, hari per minggu) |
| 4 | Tema | Gelap dan terang, plus ikut sistem. Bahasa: multi bahasa, awal Indonesia dan Inggris |

## 15. Keputusan Tahap Kedua

| # | Pertanyaan | Keputusan |
|---|---|---|
| 1 | Penentuan level | Tidak dipilih manual; aplikasi menanyakan kemampuan maksimum lewat tes (push up, squat, sit up, plank). Pilihan level hanya cadangan bila tes dilewati |
| 2 | Bahasa | Indonesia dan Inggris saja. Bahasa daerah tidak dipakai |
| 3 | Data profil (usia, tinggi, berat) | Dipakai di v1 (diperbarui di bagian 18): target protein, level cadangan; estimasi kalori dan grafik berat badan dihapus |

## 16. Keputusan Tahap Ketiga

| # | Pertanyaan | Keputusan |
|---|---|---|
| 1 | Jadwal tes ulang | Hanya ditawarkan di hari 15 dan hari 30 |
| 2 | Pembaruan berat badan berkala | Tidak ada di v1 karena belum jelas manfaatnya; berat badan dapat diedit manual (kini dipakai untuk target protein, bukan estimasi kalori). Grafik berat masuk roadmap |
| 3 | Peringatan keamanan | Perlu, tetapi berbasis kuesioner kesiapan (5 pertanyaan ya/tidak), bukan ambang usia atau berat badan, dan tidak memblokir pengguna |

## 17. Keputusan Tahap Keempat

| # | Pertanyaan | Keputusan |
|---|---|---|
| 1 | Bentuk fitur protein | Dinamis dan detail: aplikasi menghitung sisa protein hari ini dan menyarankan makanan murah untuk menutupnya, bukan menu mingguan statis |
| 2 | Cakupan | Hanya protein, dengan pencatatan satu ketukan. Tidak ada target kalori atau penurunan berat |
| 3 | Rilis | v1.1, setelah inti aplikasi jalan |

## 18. Keputusan Tahap Kelima

| # | Pertanyaan | Keputusan |
|---|---|---|
| 1 | Sasaran aplikasi | Membentuk otot dan kekuatan, bukan menurunkan berat badan. Tidak ada estimasi kalori maupun target kalori |
| 2 | Faktor protein | Berbeda per tujuan (otot 1,6; kekuatan 1,4; daya tahan 1,2 g per kg) |
| 3 | Daftar makanan | Daftar default dahulu; pengguna dapat menambah makanan sendiri |
| 4 | Target protein hari latihan vs istirahat | Satu target tetap tiap hari (keputusan UX) |

## 19. Keputusan Tahap Keenam

| # | Pertanyaan | Keputusan |
|---|---|---|
| 1 | Faktor target latihan | Disetujui: 0,60 sampai 0,75 dari hasil tes, naik tiap minggu |
| 2 | Lingkar badan dan foto progres | Dimajukan ke v1 (bagian 4.5), dilakukan di hari 1, 15, dan 30 |
| 3 | Titik ukur default | Lengan, dada, pinggang, paha sudah cukup; pengguna tetap dapat menambah sendiri |
| 4 | Kunci tambahan untuk foto | Tidak perlu; cukup disimpan di folder privat aplikasi |

## 20. Pertanyaan Terbuka

Tidak ada pertanyaan terbuka tersisa untuk lingkup v1 dan v1.1.
