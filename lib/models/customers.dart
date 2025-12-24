class Customer {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final String role;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    required this.role,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'role': role,
    };
  }
}
