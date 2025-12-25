# LaundryKu – Aplikasi Manajemen Laundry Berbasis Flutter

# 📌 Deskripsi Aplikasi

LaundryKu adalah aplikasi manajemen laundry berbasis Flutter yang digunakan untuk membantu proses pengelolaan laundry mulai dari pemesanan, pelacakan status cucian, pembayaran, hingga manajemen order oleh admin.

### Aplikasi memiliki dua peran pengguna:

1. User (Customer): melihat status Laundry, dan melakukan pembayaran bila laundry sudah siap.

2. Admin: menambahkan order, memperbarui status laundry, mengunggah foto laundry, dan mencatat pembayaran.

Backend aplikasi menggunakan Supabase sebagai database.

<hr>

# 🖼️ Screenshot Demo Aplikasi

Login
<img src="screenshots/Login.jpg" width="200">

Register
<img src="screenshots/Register.jpg" width="200">

User Home
<img src="screenshots/User_screen.jpg" width="200">

Admin Home
<img src="screenshots/Admin_screen.jpg" width="200">

Detail Order User
<img src="screenshots/Detail_screen_user.jpg" width="200">

Detail Order Admin
<img src="screenshots/Detail_screen_admin.jpg" width="200">

Detail Order Completed
<img src="screenshots/Detail_screen_completed.jpg" width="200">

Profile Screen User
<img src="screenshots/Profile_user_screen.jpg" width="200">

Profile Screen Admin
<img src="screenshots/Profile_admin_screen.jpg" width="200">

Photo Screen
<img src="screenshots/Take_photo_screen.jpg" width="200">

### 📁 Screenshot disimpan pada folder:

/screenshots

<hr>

# 📱 Link APK / AAB (Testing)

### 🔗 Download APK:

<hr>

# ▶️ Cara Menjalankan Aplikasi

1. Clone Repository
   git clone https://github.com/Ric1st/Flutter-LaundryKu.git
   cd Flutter-LaundryKu

2. Install Dependency
   flutter pub get

3. Jalankan Aplikasi
   flutter run
   (disarankan menggunakan emulator/mobile phone)

<hr>

## 🗄️ Database Schema (Supabase)

Aplikasi ini menggunakan **Supabase** sebagai backend. Berikut adalah struktur tabel yang digunakan:

### Tabel: `customers`

| Field     | Type      | Description            |
| :-------- | :-------- | :--------------------- |
| `id`      | uuid (PK) | Primary Key            |
| `name`    | text      | Nama lengkap user      |
| `phone`   | text      | Nomor telepon/WhatsApp |
| `address` | text      | Alamat Customer        |
| `role`    | text      | Role (Admin/Customer)  |

### Tabel: `orders`

| Field          | Type      | Description                                 |
| :------------- | :-------- | :------------------------------------------ |
| `id`           | uuid (PK) | Primary Key                                 |
| `customer_id`  | uuid (FK) | Relasi ke tabel customers                   |
| `weight`       | numeric   | Berat cucian (kg)                           |
| `service_type` | text      | Jenis layanan laundry                       |
| `price`        | numeric   | Total harga                                 |
| `status`       | text      | Status (Pending/Process/Ready/Completed)    |
| `photo_url`    | text      | Link foto bukti laundry di Supabase Storage |
| `date`         | timestamp | Waktu pemesanan                             |

### Tabel: `payments`

| Field            | Type      | Description                |
| :--------------- | :-------- | :------------------------- |
| `id`             | uuid (PK) | Primary Key                |
| `order_id`       | uuid (FK) | Relasi ke tabel orders     |
| `amount`         | numeric   | Total yang dibayarkan      |
| `payment_method` | text      | Method (Tunai/Qris/Kupon)  |
| `created_at`     | timestamp | Waktu pembayaran dilakukan |

<hr>

# 📂 Struktur Project

lib/
├── models/
├── providers/
├── screens/
│ ├── admin/
│ └── user/
├── services/
└── main.dart

<hr>

# 👤 Author

NIM : A11.2023.14922
Nama : Richard Christoper Subianto
Matakuliah : PPB - A11.4702
