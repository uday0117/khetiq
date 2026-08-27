import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/farm_model.dart';

class FarmService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _farmsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('farms');
  }

  Future<String> createFarm({
    required String uid,
    required FarmModel farm,
  }) async {
    final document = _farmsCollection(uid).doc();

    await document.set(farm.toMap());

    return document.id;
  }

  Future<List<FarmModel>> getFarms(String uid) async {
    final snapshot = await _farmsCollection(
      uid,
    ).orderBy('createdAt', descending: true).get();

    return snapshot.docs.map((document) {
      return FarmModel.fromMap(document.data());
    }).toList();
  }

  Future<FarmModel?> getFarm({
    required String uid,
    required String farmId,
  }) async {
    final document = await _farmsCollection(uid).doc(farmId).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return FarmModel.fromMap(document.data()!);
  }

  Future<void> updateFarm({
    required String uid,
    required FarmModel farm,
  }) async {
    await _farmsCollection(uid).doc(farm.id).update(farm.toMap());
  }

  Future<void> deleteFarm({required String uid, required String farmId}) async {
    await _farmsCollection(uid).doc(farmId).delete();
  }
}
