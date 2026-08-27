class CropModel {
  final String id;
  final String farmId;

  final String cropName;
  final String season;

  final double area;
  final String areaUnit;

  final DateTime? plannedDate;
  final DateTime? plantingDate;

  final String? variety;
  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  CropModel({
    required this.id,
    required this.farmId,
    required this.cropName,
    required this.season,
    required this.area,
    required this.areaUnit,
    this.plannedDate,
    this.plantingDate,
    this.variety,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmId': farmId,
      'cropName': cropName,
      'season': season,
      'area': area,
      'areaUnit': areaUnit,
      'plannedDate': plannedDate,
      'plantingDate': plantingDate,
      'variety': variety,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory CropModel.fromMap(Map<String, dynamic> map) {
    return CropModel(
      id: map['id'] ?? '',
      farmId: map['farmId'] ?? '',
      cropName: map['cropName'] ?? '',
      season: map['season'] ?? '',
      area: (map['area'] ?? 0).toDouble(),
      areaUnit: map['areaUnit'] ?? 'acres',

      plannedDate: map['plannedDate'] != null
          ? _parseDate(map['plannedDate'])
          : null,

      plantingDate: map['plantingDate'] != null
          ? _parseDate(map['plantingDate'])
          : null,

      variety: map['variety'],
      notes: map['notes'],

      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value?.runtimeType.toString().contains('Timestamp') == true) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }
}
