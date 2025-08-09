class Address {
  final String id;
  final String userId;
  final String streetAddress;
  final String ward;
  final String district;
  final String city;
  final String phone;
  final String? notes;

  Address({
    required this.id,
    required this.userId,
    required this.streetAddress,
    required this.ward,
    required this.district,
    required this.city,
    required this.phone,
    this.notes,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      streetAddress: json['streetAddress'] ?? '',
      ward: json['ward'] ?? '',
      district: json['district'] ?? '',
      city: json['city'] ?? '',
      phone: json['phone'] ?? '',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'streetAddress': streetAddress,
      'ward': ward,
      'district': district,
      'city': city,
      'phone': phone,
      'notes': notes,
    };
  }
} 