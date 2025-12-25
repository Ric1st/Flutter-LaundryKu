# LaundryKu – Aplikasi Manajemen Laundry Berbasis Flutter

# 📌 Deskripsi Aplikasi

LaundryKu adalah aplikasi manajemen laundry berbasis Flutter yang digunakan untuk membantu proses pengelolaan laundry mulai dari pemesanan, pelacakan status cucian, pembayaran, hingga manajemen order oleh admin.

### Aplikasi memiliki dua peran pengguna:

1. User (Customer): melihat status Laundry, dan melakukan pembayaran bila laundry sudah siap.

2. Admin: menambahkan order, memperbarui status laundry, mengunggah foto laundry, dan mencatat pembayaran.

Backend aplikasi menggunakan Supabase sebagai database.

<hr>

# 🖼️ Screenshot Demo Aplikasi

## Login

<img src="Screenshots/Login.jpg" width="200">

### Register

<img src="Screenshots/Register.jpg" width="200">

### User Home

<img src="Screenshots/User_screen.jpg" width="200">

### Admin Home

<img src="Screenshots/Admin_screen.jpg" width="200">

### Detail Order User

<img src="Screenshots/Detail_screen_user.jpg" width="200">

### Detail Order Admin

<img src="Screenshots/Detail_screen_admin.jpg" width="200">

### Detail Order Completed

<img src="Screenshots/Detail_screen_completed.jpg" width="200">

### Profile Screen User

<img src="Screenshots/Profile_user_screen.jpg" width="200">

### Profile Screen Admin

<img src="Screenshots/Profile_admin_screen.jpg" width="200">

### Photo Screen

<img src="Screenshots/Take_photo_screen.jpg" width="200">

### 📁 Screenshot disimpan pada folder:

/Screenshots

<hr>

# 📱 Link APK / AAB (Testing)

### 🔗 Download APK: https://drive.google.com/file/d/126WHxGF4XeHYTWN6uspw_iU1XLXN2ptX/view?usp=sharing

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

### lib/

### ├── models/

### ├── providers/

### ├── screens/

### │ ├── admin/

### │ └── user/

### ├── services/

### └── main.dart

<hr>

## 🔌 API Documentation (Supabase Services)

Aplikasi berinteraksi dengan Supabase menggunakan service class berikut:

### Customer API (`customer_api.dart`)

| Fungsi                 | Deskripsi                                               |
| :--------------------- | :------------------------------------------------------ |
| `login(name, phone)`   | Validasi user berdasarkan nama dan nomor telepon.       |
| `isPhoneExists(phone)` | Mengecek apakah nomor sudah terdaftar sebelum register. |
| `registerCustomer()`   | Menambahkan data customer baru ke tabel `customers`.    |
| `update(customer)`     | Memperbarui profil customer yang sudah ada.             |

### Order API (`order_api.dart`)

| Fungsi                    | Deskripsi                                                                           |
| :------------------------ | :---------------------------------------------------------------------------------- |
| `getOrdersByCustomer(id)` | Mengambil semua riwayat laundry milik satu customer.                                |
| `Order.status (Logic)`    | Otomatis berubah jadi 'Selesai' jika data pembayaran ditemukan di tabel `payments`. |

<hr>

# 👤 Author

| Detail          | Informasi                            |
| :-------------- | :----------------------------------- |
| **Nama**        | Richard Christoper Subianto          |
| **NIM**         | A11.2023.14922                       |
| **Mata Kuliah** | Pemrograman Perangkat Bergerak (PPB) |
| **Kelas**       | A11.4702                             |
