# EventYog Mobile by HalfOfDozen (F6) - PBP 2024/2025

## Apa itu EventYog?
EventYog adalah aplikasi inovatif berbasis web yang dirancang untuk memudahkan promosi, penemuan, dan partisipasi dalam beragam event menarik di Yogyakarta. Mulai dari konser musik yang spektakuler, pameran seni yang menginspirasi, hingga acara budaya. EventYog hadir sebagai jembatan yang menghubungkan masyarakat dengan aktivitas lokal. Aplikasi ini menyediakan informasi lengkap seperti waktu, lokasi, dan tata cara berpartisipasi dalam setiap event yang tersedia.

EventYog tidak hanya fokus pada kemudahan akses acara, tetapi juga memperkaya pengalaman user dengan fitur menarik, seperti pembelian merchandise eksklusif yang terkait dengan acara-acara tersebut. user dapat langsung memesan merchandise favorit mereka melalui aplikasi, menciptakan kenangan unik dari setiap acara yang mereka ikuti. 

## Tautan Deployment
Aplikasi EventYog dapat diakses melalui tautan berikut: [link kita nntu)

## Anggota Kelompok
EventYog dikembangkan oleh kelompok HalfOfDozen (F6), yang terdiri dari enam mahasiswa:

1. **Andrew Devito Aryo** (2306152494)   
2. **Luvenia Feodora Saragih** (2306228402)
3. **Sezza Auraghaniya Winanda** (2306207291)
4. **Allan Kwek** (2306152134)
5. **Arief Ridzki Darmawan** (2306210115)
6. **Fransisca Ellya Bunaren** (2306152286)

## Modul Utama dalam Aplikasi
Pembagian tugas dapat diakses pada link ini:
> https://docs.google.com/spreadsheets/d/1zH-FyHCWx9a6bBGQ5zgjocIm-GUWxTVqYs0H9DE2wIo/edit?usp=sharing

EventYog memiliki berbagai modul utama (CRUD) yang berperan penting dalam pengalaman user, meliputi:
1. [Andrew] **Authentication System**: Fitur ini memungkinkan user untuk melakukan registrasi dan login ke aplikasi Eventyog.
2. [Andrew] **Profile Page**: Fitur ini memungkinkan user untuk mengubah data pribadi dan profile picture mereka
3. [Andrew] **Home Page**: Fitur ini akan memberikan gambaran singkat mengenai aplikasi Eventyog dan memudahkan user untuk bernavigasi ke fitur-fitur lain.
4. [Andrew] **About Eventyog Page**: Fitur ini akan memberikan keterangan terkait developer dan tujuan dari aplikasi Eventyog.
5. [Arief] **Admin Page**: Fitur ini memungkinkan admin untuk menambahkan user, menghapus user, dan mengedit data user.
7. [Fransisca] **Explore Events**: Menu ini menampilkan daftar event dan detail dari event di kota Jogja berdasarkan preferensi user. Admin dapat menambahkan, mengedit, dan menghapus event. user dapat membeli tiket event dan memberikan rating jika sudah membeli tiket.
9. [Luvenia] **View Merchandise**: user dapat melihat daftar merchandise yang dijual dalam satu event. Admin dapat menambahkan, mengedit, dan menghapus merchandise tersebut. user dapat menambahkan item ke cart, dan nanti dapat dibeli melalui My Cart Page.
10. [Allan] **My Cart**: Fitur ini akan menampilkan semua tiket event dan merchandise yang user beli. Jika user mengklik beli, maka saldo user akan terpotong.
11. [Ghia] **Forum**: Fitur ini akan menampilkan forum terkait event. user dapat mengupload foto dan komentar terkait event dan merchandise yang mereka beli di event tersebut. Forum memungkinkan interaksi antara user dengan fitur like, dislike, dan komentar.
12. [Andrew] **Scheduled Events**: Fitur ini menampilkan event yang telah didaftarkan oleh user. user dapat menambah event dengan mendaftar pada event baru, membatalkan pendaftaran, atau mengganti jenis tiket (jika tersedia lebih dari satu jenis tiket).
13. [Andrew] **Friends Page**: Fitur ini memungkinkan user untuk berteman dengan user lain

## Sumber Dataset Awal Kategori Produk
Dataset yang digunakan untuk memulai pengembangan kategori produk pada aplikasi ini dapat diakses melalui tautan berikut: [Dataset dan Link Sumbernya](https://docs.google.com/spreadsheets/d/1iP8eY44oMNFkbkmIzFSCkeFv99xC77yMKTMeYp2hoFs/edit?usp=sharing)

## Peran dan Fungsi User
1. **User yang belum terautentikasi:**
   - Tipe user yang belum melakukan registrasi atau log in.
   - Akses user lebih dibatasi. Halaman seperti View Merchandise, My cart, Scheduled Event, dan beberapa lainnya tidak dapat diakses.
   - user hanya bisa mengakses Landing Page dan Forum, tanpa dapat menambahkan, merubah, ataupun menghapus data/informasi apapun.
2. **User yang sudah terautentikasi:**
   - Menggunakan EventYog untuk menelusuri dan menemukan berbagai acara menarik di Yogyakarta.
   - Mendaftar dan mengikuti acara yang mereka minati.
   - Memberikan ulasan setelah mengikuti acara, serta membeli merchandise eksklusif yang terkait dengan acara tersebut.
3. **Administrator (Admin):**
   - Mengelola seluruh aplikasi, termasuk memantau aktivitas user.
   - Menangani permasalahan teknis dan memberikan bantuan.
   - Memastikan aplikasi berfungsi dengan baik, selalu diperbarui, dan tetap aman digunakan.

## Alur Pengintegrasian
1. Migrasi dndpoint pada Project PTS menjadi dndpoint API Only
   Semua endpoint AJAX yang telah digunakan sebelumnya pada Projek PTS akan dimigrasi dikumpulkan dalam 1 module yaitu module API.
3. Membuat dokumentasi API
   Semua endpoint yang telah dimigrasi akan didokumentasikan menggunakan Google Docs
3. Menggunakan endpoints yang telah dibuat
   Projek Flutter akan memanggil endpoints dari proyek Django sesuai kebutuhan
