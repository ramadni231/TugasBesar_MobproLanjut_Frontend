# 📘 PRESENSIKU - SISTEM PRESENSI MAHASISWA BERBASIS GPS & KODE QR

---

## 👥 Anggota Kelompok

1. Riki Ramadhani - STI202303415

---

## 📱 Repository Terkait (Backend Laravel)

Untuk melihat implementasi kode program di sisi server (_backend REST API_) yang terintegrasi dengan database MySQL,terdapat pada tautan repositori berikut:

🔗 **[Repositori Backend Laravel](https://github.com/ramadni231/TugasBesar_AplikasiPresensi)**

## 🚀 Deskripsi Proyek

**Presensiku** adalah aplikasi manajemen presensi perkuliahan berbasis _mobile_ yang memanfaatkan teknologi pemindaian Kode QR dan validasi koordinat GPS (_Geolocator_) secara _real-time_. Aplikasi ini dirancang untuk mengatasi kecurangan presensi (titip absen) di lingkungan kampus dengan memastikan bahwa mahasiswa yang melakukan presensi benar-benar berada di dalam radius ruang kelas yang telah ditentukan oleh pihak Admin dan Dosen pada jam kuliah yang aktif.

## 🎯 Tujuan

- **Akurasi Data:** Memastikan validitas kehadiran mahasiswa berdasarkan posisi koordinat GPS yang dihitung langsung oleh peladen (_backend_).
- **Efisiensi Waktu:** Mempercepat proses absensi di kelas melalui pemindaian Kode QR yang dinamis dengan batas waktu hitung mundur (_countdown_).
- **Transparansi & Manajemen Terpusat:** Memudahkan Admin dalam mengelola data master (ruangan, mata kuliah, akun) serta membantu Dosen dalam memantau rekap kelas harian secara _real-time_.

---

## 🧱 Arsitektur Sistem

Aplikasi ini dibangun menggunakan arsitektur pemisahan _Frontend_ dan _Backend_ (_Decoupled Architecture_) dengan kontrak data berbasis JSON:

```text
Flutter (Mobile App) ➔ Mengambil Sensor GPS & Memindai QR Code
       ↓
REST API (Laravel 13) ➔ Autentikasi Sanctum & Menghitung Jarak Rumus Haversine
       ↓
MySQL Database ➔ Penyimpanan Data Master, Sesi, dan Transaksi Presensi

```

---

## ⚙️ Teknologi yang Digunakan

- **Frontend:** Flutter, ForUI Kit (`forui`), SharedPreferences, Geolocator, Mobile Scanner.
- **Backend:** Laravel 13, Laravel Sanctum (Otentikasi API Token).
- **Basis Data:** MySQL / MariaDB.
- **Alat Pengembangan:** VS Code, Android Studio, Postman, Arch Linux OS.

---

## 📌 Fitur yang Akan Dibuat

### 🔐 Fitur Otentikasi & Visual Global

- **Sistem Masuk Multi-Akses:** Form login tunggal manual (Email & Password) tanpa registrasi publik untuk mencegah akun anonim.
- **Tema Ganda Kontras (Light/Dark Mode):** Desain visual modern menggunakan komponen ForUI dengan palet warna Biru-Putih (Light) dan Navy Gelap yang Jelas (Dark). Status tema tersimpan otomatis di memori ponsel.
- **Modal Profil Slider:** Akses menu pengaturan, ubah kata sandi, dan tombol _logout_ melalui lembar geser bawah (_Bottom Sheet_) dengan menekan avatar profil di pojok kiri atas dasbor.

---

### 👑 Fitur Hak Akses Admin

- **Manajemen Pengguna:** CRUD akun Mahasiswa dan Dosen secara terpusat dilengkapi fitur **Ekspor Data Akun (CSV)** untuk pembagian kredensial bawaan.
- **Master Akademik (CRUD):** Mengelola data ruangan (kapasitas, koordinat GPS absolut, dan radius toleransi meter), data mata kuliah (Kode MK, Nama MK, SKS), serta pembuatan jadwal kelas makro.
- **Validasi Izin & Rekap Global:** Menyetujui/menolak surat izin mahasiswa serta melihat tabel rekapitulasi kehadiran global.

---

### 👨‍🎓 Fitur Hak Akses Mahasiswa

- **Dasbor & Jadwal Mingguan:** Menampilkan ringkasan profil akademik, kalender perkuliahan seminggu, dan kartu kelas terdekat hari ini.
- **Pemindai Presensi Ber-GPS:** Kamera pemindai QR yang terintegrasi dengan indikator jarak. Tombol pindai akan otomatis terkunci jika mahasiswa berada di luar radius kelas.
- **Pengajuan Izin & Riwayat:** Form pengajuan izin/sakit dengan unggahan lampiran foto surat dokter serta pemantauan kartu riwayat kehadiran berwarna (Hadir, Terlambat, Izin, Alpa).

---

### 👨‍🏫 Fitur Hak Akses Dosen

- **Aktivasi Kelas & Hitung Mundur:** Tombol pembuka kelas untuk mengaktifkan fungsi QR Code mahasiswa yang dilengkapi dengan batas waktu hitung mundur (_countdown_) 15 menit awal.
- **Manajemen Kelas Harian:** Fitur mengubah jadwal mengajar (_Reschedule_) secara mendadak atau melakukan pembatalan kelas (_Cancel_).
- **Pemantauan Real-Time & Ekspor:** Memantau daftar mahasiswa yang masuk ke kelas berjalan secara langsung serta mengunduh laporan rekap per kelas dalam format PDF _dummy_.

---

## 🔌 Endpoint Utama

| Method | Endpoint                              | Deskripsi                                              | Hak Akses |
| ------ | ------------------------------------- | ------------------------------------------------------ | --------- |
| `POST` | `/api/auth/login`                     | Autentikasi masuk manual & penyerahan Token Sanctum    | Publik    |
| `POST` | `/api/admin/users`                    | Membuat data akun mahasiswa atau dosen baru            | Admin     |
| `GET`  | `/api/admin/users/export`             | Mengunduh berkas CSV daftar akun dan password bawaan   | Admin     |
| `POST` | `/api/admin/rooms`                    | Membuat data master ruangan, koordinat, dan radius     | Admin     |
| `POST` | `/api/admin/sessions`                 | Membuat plot jadwal perkuliahan harian                 | Admin     |
| `GET`  | `/api/mahasiswa/sessions/today`       | Mengambil daftar jadwal kelas mahasiswa hari ini       | Mahasiswa |
| `POST` | `/api/mahasiswa/attendances/scan`     | Mengirim data token QR dan koordinat GPS hasil scan    | Mahasiswa |
| `POST` | `/api/mahasiswa/permits`              | Mengunggah surat keterangan izin/sakit beserta alasan  | Mahasiswa |
| `POST` | `/api/dosen/sessions/{id}/activate`   | Membuka kelas dan mengaktifkan hitung mundur 15 menit  | Dosen     |
| `PUT`  | `/api/dosen/sessions/{id}/reschedule` | Mengubah jam/tanggal kelas berjalan secara mendadak    | Dosen     |
| `GET`  | `/api/dosen/sessions/{id}/realtime`   | Memantau daftar mahasiswa yang hadir di kelas berjalan | Dosen     |

---

## 🗄️ Struktur Database

Tabel utama yang digunakan di dalam sistem basis data meliputi:

1. **`users`**: Menyimpan data akun pengguna (Nama, NIM/NIDN, Email, Password, Peran).
2. **`rooms`**: Menyimpan data geolokasi ruang kelas (Nama Ruang, Koordinat Latitude/Longitude, Radius Toleransi).
3. **`courses`**: Menyimpan data identitas mata kuliah (Kode MK, Nama MK, SKS).
4. **`sessions`**: Menyimpan data transaksi jadwal, status aktif kelas, dan waktu aktivasi dosen.
5. **`attendances`**: Menyimpan data transaksi presensi mahasiswa (Koordinat scan, jarak meter, status kehadiran).
6. **`permits`**: Menyimpan data transaksi surat izin/sakit mahasiswa beserta status validasinya.

```

```
