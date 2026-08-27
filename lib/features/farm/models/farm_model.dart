class FarmModel {
  final String id;
  final String name;
  final double area;
  final String areaUnit;
  final String village;
  final String district;
  final String state;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FarmModel({
    required this.id,
    required this.name,
    required this.area,
    required this.areaUnit,
    required this.village,
    required this.district,
    required this.state,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'area': area,
      'areaUnit': areaUnit,
      'village': village,
      'district': district,
      'state': state,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory FarmModel.fromMap(Map<String, dynamic> map) {
    return FarmModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      area: (map['area'] as num?)?.toDouble() ?? 0,
      areaUnit: map['areaUnit'] ?? 'acres',
      village: map['village'] ?? '',
      district: map['district'] ?? '',
      state: map['state'] ?? '',
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }
}
