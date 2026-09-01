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
    final document = _farmsCollection(uid).doc(farm.id);

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
      // Fallback: Query by inner 'id' field for older records
      final query = await _farmsCollection(uid)
          .where('id', isEqualTo: farmId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return FarmModel.fromMap(query.docs.first.data());
    }

    return FarmModel.fromMap(document.data()!);
  }

  Future<void> updateFarm({
    required String uid,
    required FarmModel farm,
  }) async {
    final docRef = _farmsCollection(uid).doc(farm.id);
    final docSnap = await docRef.get();
    if (docSnap.exists) {
      await docRef.update(farm.toMap());
    } else {
      // Fallback: Query by inner 'id' field for older records
      final query = await _farmsCollection(uid)
          .where('id', isEqualTo: farm.id)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update(farm.toMap());
      } else {
        // If not found, create as new
        await docRef.set(farm.toMap());
      }
    }
  }

  Future<void> deleteFarm({required String uid, required String farmId}) async {
    final docRef = _farmsCollection(uid).doc(farmId);
    final docSnap = await docRef.get();
    if (docSnap.exists) {
      await docRef.delete();
    } else {
      // Fallback: Query by inner 'id' field for older records
      final query = await _farmsCollection(uid)
          .where('id', isEqualTo: farmId)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.delete();
      }
    }
  }
}
