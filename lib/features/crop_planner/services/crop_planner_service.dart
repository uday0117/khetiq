import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/crop_model.dart';

class CropPlannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _cropsCollection({
    required String uid,
    required String farmId,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('farms')
        .doc(farmId)
        .collection('crops');
  }

  Future<void> createCrop({
    required String uid,
    required CropModel crop,
  }) async {
    await _cropsCollection(
      uid: uid,
      farmId: crop.farmId,
    ).doc(crop.id).set(crop.toMap());
  }

  Future<List<CropModel>> getCrops({
    required String uid,
    required String farmId,
  }) async {
    final snapshot = await _cropsCollection(
      uid: uid,
      farmId: farmId,
    ).orderBy('createdAt', descending: true).get();

    return snapshot.docs.map((doc) => CropModel.fromMap(doc.data())).toList();
  }

  Future<CropModel?> getCrop({
    required String uid,
    required String farmId,
    required String cropId,
  }) async {
    final doc = await _cropsCollection(
      uid: uid,
      farmId: farmId,
    ).doc(cropId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return CropModel.fromMap(doc.data()!);
  }

  Future<void> updateCrop({
    required String uid,
    required CropModel crop,
  }) async {
    await _cropsCollection(
      uid: uid,
      farmId: crop.farmId,
    ).doc(crop.id).update(crop.toMap());
  }

  Future<void> deleteCrop({
    required String uid,
    required String farmId,
    required String cropId,
  }) async {
    await _cropsCollection(uid: uid, farmId: farmId).doc(cropId).delete();
  }
}
