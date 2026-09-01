import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:khetiq/core/constants/app_constants.dart';
import '../models/crop_scan_result_model.dart';

class GeminiCropScanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Analyzes crop image bytes using Gemini 1.5 Flash AI multimodal vision model
  Future<CropScanResultModel> analyzeCropImage({
    required Uint8List imageBytes,
    required String mimeType,
    String? cropCategory,
    String? userNotes,
    String? customApiKey,
    String? localImagePath,
  }) async {
    final apiKey = (customApiKey != null && customApiKey.trim().isNotEmpty)
        ? customApiKey.trim()
        : geminiApiKey;

    if (apiKey.isEmpty) {
      throw Exception(
        'Gemini API Key is missing. Please provide a valid Gemini API Key to perform Crop Scan.',
      );
    }

    // Using gemini-1.5-flash model which is available on the free tier
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );

    final cropHintText = (cropCategory != null && cropCategory != 'Auto-detect' && cropCategory.isNotEmpty)
        ? 'Target Crop Type: $cropCategory.'
        : 'Identify the crop type if visible.';

    final notesHintText = (userNotes != null && userNotes.trim().isNotEmpty)
        ? 'User Observation Notes: $userNotes.'
        : '';

    final promptText = '''
You are an expert plant pathologist and agronomist for KhetIQ agricultural platform.
Analyze the provided crop/plant image carefully and diagnose any disease, pest infestation, nutrient deficiency, or physiological disorder.
$cropHintText
$notesHintText

Return ONLY a valid JSON object matching the following structure without any extra text or commentary:
{
  "cropName": "Name of the crop identified (e.g., Tomato, Cotton, Wheat, Rice, Sugarcane, etc.)",
  "healthStatus": "Healthy" OR "Mild Issue" OR "Severe Issue",
  "diseaseName": "Name of disease/pest/disorder or 'Healthy Plant' if no issue found",
  "confidenceScore": 0.95 (number between 0.0 and 1.0),
  "symptoms": ["Symptom 1", "Symptom 2", "Symptom 3"],
  "causes": ["Possible cause 1", "Possible cause 2"],
  "organicTreatments": ["Organic/Biological remedy 1", "Remedy 2"],
  "chemicalTreatments": ["Recommended chemical/fungicide/pesticide dosage 1", "Treatment 2"],
  "preventiveMeasures": ["Prevention step 1", "Prevention step 2"]
}
''';

    final content = [
      Content.multi([
        DataPart(mimeType, imageBytes),
        TextPart(promptText),
      ])
    ];

    try {
      final response = await model.generateContent(content);
      final rawResponseText = response.text;

      if (rawResponseText == null || rawResponseText.isEmpty) {
        throw Exception('Received empty analysis response from Gemini AI.');
      }

      return CropScanResultModel.fromJsonString(
        rawResponseText,
        imagePath: localImagePath,
        cropNameHint: cropCategory,
        userNotes: userNotes,
      );
    } catch (e) {
      if (e.toString().contains('API_KEY_INVALID') || e.toString().contains('API key not valid')) {
        throw Exception('Invalid Gemini API Key. Please check your Gemini API key settings.');
      } else if (e.toString().contains('RESOURCE_EXHAUSTED') || e.toString().contains('429')) {
        throw Exception('Gemini Free Tier rate limit reached. Please wait a minute before trying again.');
      }
      rethrow;
    }
  }

  /// Optional: Save scan result to user's history in Firestore
  Future<void> saveScanHistory({
    required String uid,
    required CropScanResultModel scanResult,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('crop_scans')
          .doc(scanResult.id)
          .set(scanResult.toMap());
    } catch (e) {
      // Non-blocking error for history save
    }
  }
}
