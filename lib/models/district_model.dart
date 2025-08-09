class Ward {
  final int id;
  final String name;

  Ward({required this.id, required this.name});

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      id: json['id'],
      name: json['name'],
    );
  }
}

class District {
  final int id;
  final String name;
  final List<Ward> wards;

  District({required this.id, required this.name, required this.wards});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      name: json['name'],
      wards: (json['wards'] as List).map((e) => Ward.fromJson(e)).toList(),
    );
  }
} 