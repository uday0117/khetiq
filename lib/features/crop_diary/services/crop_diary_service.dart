import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/diary_entry_model.dart';

class CropDiaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _diaryCollection({
    required String uid,
    required String farmId,
    required String cropId,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('farms')
        .doc(farmId)
        .collection('crops')
        .doc(cropId)
        .collection('diary');
  }

  // CREATE
  Future<void> createEntry({
    required String uid,
    required String farmId,
    required String cropId,
    required DiaryEntryModel entry,
  }) async {
    await _diaryCollection(
      uid: uid,
      farmId: farmId,
      cropId: cropId,
    ).doc(entry.id).set(entry.toMap());
  }

  // READ - ALL ENTRIES
  Future<List<DiaryEntryModel>> getEntries({
    required String uid,
    required String farmId,
    required String cropId,
  }) async {
    final snapshot = await _diaryCollection(
      uid: uid,
      farmId: farmId,
      cropId: cropId,
    ).orderBy('date', descending: true).get();

    return snapshot.docs
        .map(
          (doc) => DiaryEntryModel.fromMap(doc.data()),
        )
        .toList();
  }

  // READ - SINGLE ENTRY
  Future<DiaryEntryModel?> getEntry({
    required String uid,
    required String farmId,
    required String cropId,
    required String entryId,
  }) async {
    final doc = await _diaryCollection(
      uid: uid,
      farmId: farmId,
      cropId: cropId,
    ).doc(entryId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return DiaryEntryModel.fromMap(doc.data()!);
  }

  // UPDATE
  Future<void> updateEntry({
    required String uid,
    required String farmId,
    required String cropId,
    required DiaryEntryModel entry,
  }) async {
    await _diaryCollection(
      uid: uid,
      farmId: farmId,
      cropId: cropId,
    ).doc(entry.id).update(entry.toMap());
  }

  // DELETE
  Future<void> deleteEntry({
    required String uid,
    required String farmId,
    required String cropId,
    required String entryId,
  }) async {
    await _diaryCollection(
      uid: uid,
      farmId: farmId,
      cropId: cropId,
    ).doc(entryId).delete();
  }
}