class Address {
  final String? address;
  final String? city;
  final String? pincode;
  final String? phone;
  final String? notes;

  Address({
    this.address,
    this.city,
    this.pincode,
    this.phone,
    this.notes,
  });

  factory Address.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Address();
    return Address(
      address: json['address'],
      city: json['city'],
      pincode: json['pincode'],
      phone: json['phone'],
      notes: json['notes'],
    );
  }

  @override
  String toString() {
    return [address, city, pincode].where((e) => e != null && e.isNotEmpty).join(', ');
  }
}
