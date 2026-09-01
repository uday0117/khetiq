import 'dart:convert';

class CropScanResultModel {
  final String id;
  final String cropName;
  final String healthStatus; // 'Healthy', 'Mild Issue', 'Severe Issue'
  final String diseaseName;
  final double confidenceScore; // 0.0 - 1.0 or percentage
  final List<String> symptoms;
  final List<String> causes;
  final List<String> organicTreatments;
  final List<String> chemicalTreatments;
  final List<String> preventiveMeasures;
  final String? userNotes;
  final String? imagePath;
  final DateTime timestamp;

  CropScanResultModel({
    required this.id,
    required this.cropName,
    required this.healthStatus,
    required this.diseaseName,
    required this.confidenceScore,
    required this.symptoms,
    required this.causes,
    required this.organicTreatments,
    required this.chemicalTreatments,
    required this.preventiveMeasures,
    this.userNotes,
    this.imagePath,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cropName': cropName,
      'healthStatus': healthStatus,
      'diseaseName': diseaseName,
      'confidenceScore': confidenceScore,
      'symptoms': symptoms,
      'causes': causes,
      'organicTreatments': organicTreatments,
      'chemicalTreatments': chemicalTreatments,
      'preventiveMeasures': preventiveMeasures,
      'userNotes': userNotes,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CropScanResultModel.fromMap(Map<String, dynamic> map) {
    return CropScanResultModel(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      cropName: map['cropName'] ?? 'Unknown Crop',
      healthStatus: map['healthStatus'] ?? 'Healthy',
      diseaseName: map['diseaseName'] ?? 'No Disease Detected',
      confidenceScore: (map['confidenceScore'] ?? 0.85).toDouble(),
      symptoms: List<String>.from(map['symptoms'] ?? []),
      causes: List<String>.from(map['causes'] ?? []),
      organicTreatments: List<String>.from(map['organicTreatments'] ?? []),
      chemicalTreatments: List<String>.from(map['chemicalTreatments'] ?? []),
      preventiveMeasures: List<String>.from(map['preventiveMeasures'] ?? []),
      userNotes: map['userNotes'],
      imagePath: map['imagePath'],
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] is String
              ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
              : map['timestamp'].toDate())
          : DateTime.now(),
    );
  }

  factory CropScanResultModel.fromJsonString(String rawJson, {String? imagePath, String? cropNameHint, String? userNotes}) {
    try {
      // Clean raw JSON response from markdown wrappers if present (e.g. ```json ... ```)
      String cleanJson = rawJson.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      } else if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(3);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();

      final Map<String, dynamic> parsed = jsonDecode(cleanJson);
      return CropScanResultModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cropName: parsed['cropName'] ?? cropNameHint ?? 'Crop',
        healthStatus: parsed['healthStatus'] ?? 'Uncertain',
        diseaseName: parsed['diseaseName'] ?? 'General Condition',
        confidenceScore: (parsed['confidenceScore'] ?? 0.85).toDouble(),
        symptoms: List<String>.from(parsed['symptoms'] ?? []),
        causes: List<String>.from(parsed['causes'] ?? []),
        organicTreatments: List<String>.from(parsed['organicTreatments'] ?? []),
        chemicalTreatments: List<String>.from(parsed['chemicalTreatments'] ?? []),
        preventiveMeasures: List<String>.from(parsed['preventiveMeasures'] ?? []),
        userNotes: userNotes,
        imagePath: imagePath,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // Fallback parser if Gemini output was not strict JSON
      return CropScanResultModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cropName: cropNameHint ?? 'Crop',
        healthStatus: 'Analysis Completed',
        diseaseName: 'AI Diagnosis Summary',
        confidenceScore: 0.80,
        symptoms: [rawJson.length > 200 ? '${rawJson.substring(0, 200)}...' : rawJson],
        causes: ['Requires verification by local agronomist.'],
        organicTreatments: ['Ensure adequate water and soil nutrients.'],
        chemicalTreatments: ['Consult an agricultural expert before chemical application.'],
        preventiveMeasures: ['Monitor crop regularly.'],
        userNotes: userNotes,
        imagePath: imagePath,
        timestamp: DateTime.now(),
      );
    }
  }
}
