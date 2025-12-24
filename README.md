LaundryKu – Aplikasi Manajemen Laundry Berbasis Flutter
📌 Deskripsi Aplikasi

LaundryKu adalah aplikasi manajemen laundry berbasis Flutter yang digunakan untuk membantu proses pengelolaan laundry mulai dari pemesanan, pelacakan status cucian, pembayaran, hingga manajemen order oleh admin.

Aplikasi memiliki dua peran pengguna:

User (Customer): melakukan pemesanan laundry, melihat status, dan melakukan pembayaran menggunakan QR.

Admin: mengelola order, memperbarui status laundry, mengunggah foto laundry, dan mencatat pembayaran.

Backend aplikasi menggunakan Supabase sebagai database dan REST API.

🖼️ Screenshot Demo Aplikasi

Minimal 5 screen

Login	Register	User Home

	
	
Admin Home	Detail Order

	

📁 Screenshot disimpan pada folder:

/screenshots

📱 Link APK / AAB (Testing)

🔗 Download APK:

https://drive.google.com/your-apk-link

▶️ Cara Menjalankan Aplikasi
1. Clone Repository
git clone https://github.com/Ric1st/Flutter-LaundryKu.git
cd Flutter-LaundryKu

2. Install Dependency
flutter pub get

3. Jalankan Aplikasi
flutter run

🗄️ Database Schema
Tabel customers
Field	Type
id	uuid
name	text
phone	text
role	text
Tabel orders
Field	Type
id	uuid
customer_id	uuid
weight	numeric
service_type	text
price	numeric
status	text
photo_url	text
date	timestamp
Tabel payments
Field	Type
id	uuid
order_id	uuid
payment_method	text
created_at	timestamp
🔌 API Documentation
Get Orders by Customer
GET /orders?customer_id={id}

Create Order
POST /orders

Update Order Status
PATCH /orders/{id}

Insert Payment
POST /payments

📂 Struktur Project (Ringkas)
lib/
 ├── models/
 ├── providers/
 ├── screens/
 │    ├── admin/
 │    └── user/
 ├── services/
 └── main.dart

👤 Author

Richard Christoper
Flutter – Perangkat Bergerak
