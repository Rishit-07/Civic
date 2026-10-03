import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Cloud Firestore database service for CIVIC user profile and sync
class FirestoreService {
  static final FirestoreService instance = FirestoreService._internal();
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  /// Upsert user profile into Firestore collection 'users'
  Future<void> syncUserProfile(User user, {String? selectedState, String? language}) async {
    try {
      final userDoc = _usersCol.doc(user.uid);
      final snapshot = await userDoc.get();

      final data = <String, dynamic>{
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL,
        'isAnonymous': user.isAnonymous,
        'lastLogin': FieldValue.serverTimestamp(),
      };

      if (selectedState != null) {
        data['selectedState'] = selectedState;
      }
      if (language != null) {
        data['language'] = language;
      }

      if (!snapshot.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
        await userDoc.set(data);
      } else {
        await userDoc.update(data);
      }
    } catch (e) {
      debugPrint('Firestore syncUserProfile warning: $e');
      // If Firestore API is pending activation, keep local flow unimpeded
    }
  }

  /// Update user state and language preferences
  Future<void> updateUserPreferences(
    String uid, {
    String? state,
    String? language,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (state != null) updateData['selectedState'] = state;
      if (language != null) updateData['language'] = language;
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _usersCol.doc(uid).set(updateData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore updateUserPreferences warning: $e');
    }
  }

  /// Save or update a citizen legal note in users/{uid}/notes
  Future<String?> saveCitizenNote(
    String uid, {
    String? noteId,
    required String title,
    required String content,
    String? scenarioId,
  }) async {
    try {
      final notesCol = _usersCol.doc(uid).collection('notes');
      final targetDoc = noteId != null ? notesCol.doc(noteId) : notesCol.doc();

      final data = <String, dynamic>{
        'id': targetDoc.id,
        'title': title,
        'content': content,
        'scenarioId': scenarioId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (noteId == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
        await targetDoc.set(data);
      } else {
        await targetDoc.update(data);
      }
      return targetDoc.id;
    } catch (e) {
      debugPrint('Firestore saveCitizenNote warning: $e');
      return null;
    }
  }

  /// Stream of user notes
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserNotesStream(String uid) {
    return _usersCol
        .doc(uid)
        .collection('notes')
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }
}
