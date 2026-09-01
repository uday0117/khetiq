import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryEntryModel {
  final String id;
  final String cropId;
  final String title;
  final String description;
  final String type;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiaryEntryModel({
    required this.id,
    required this.cropId,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cropId': cropId,
      'title': title,
      'description': description,
      'type': type,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory DiaryEntryModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return DiaryEntryModel(
      id: map['id'] as String,
      cropId: map['cropId'] as String,
      title: map['title'] as String? ?? '',
      description:
          map['description'] as String? ?? '',
      type: map['type'] as String? ?? 'other',
      date: _parseDate(map['date']),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ??
          DateTime.now();
    }

    return DateTime.now();
  }
}