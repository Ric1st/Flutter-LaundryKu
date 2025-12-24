class Order {
  final String id;
  final String customerId;
  final String? customerName;
  final int weight;
  final String serviceType;
  final int price;
  final String status;
  final String? photoURL;
  final bool isPaid;
  final DateTime date;

  Order({
    required this.id,
    required this.customerId,
    this.customerName,
    required this.serviceType,
    required this.weight,
    required this.price,
    required this.status,
    this.photoURL,
    required this.isPaid,
    required this.date,
  });

  bool get showQr => !isPaid;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customers']?['name'],
      weight: (json['weight'] ?? 0) as int,
      serviceType: json['service_type']?.toString() ?? '-',
      price: (json['price'] ?? 0) as int,
      status: json['status']?.toString() ?? 'pending',
      photoURL: json['photo_url'],
      isPaid: json['is_paid'] ?? false,
      date:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
