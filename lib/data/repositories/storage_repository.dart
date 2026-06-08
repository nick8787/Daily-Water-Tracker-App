import 'dart:io';

import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadProfilePhotoResult {
  const UploadProfilePhotoResult({
    required this.objectPath,
    required this.downloadUrl,
  });

  final String objectPath;
  final String downloadUrl;
}

/// Firebase Storage access for profile media and account cleanup
class StorageRepository {
  StorageRepository({required FirebaseStorage storage}) : _storage = storage;

  final FirebaseStorage _storage;

  Future<UploadProfilePhotoResult> uploadProfilePhoto({
    required String uid,
    required File file,
  }) async {
    final fileName = 'profile_$uid.jpg';
    final objectPath = 'users/$uid/$fileName';
    final ref = _storage.ref().child(objectPath);

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return UploadProfilePhotoResult(
      objectPath: objectPath,
      downloadUrl: downloadUrl,
    );
  }

  Future<void> deleteUserStorage({required String uid}) async {
    await _deleteReferenceTree(_storage.ref().child('users/$uid'));
  }

  Future<void> _deleteReferenceTree(Reference ref) async {
    try {
      final list = await ref.listAll();
      await Future.wait<void>([
        for (final item in list.items) _deleteItemBestEffort(item),
        for (final prefix in list.prefixes) _deleteReferenceTree(prefix),
      ]);
    } on FirebaseException catch (e, st) {
      if (e.code == 'object-not-found') return;
      logCaughtError('StorageRepository._deleteReferenceTree', e, st);
      rethrow;
    }
  }

  Future<void> _deleteItemBestEffort(Reference item) async {
    try {
      await item.delete();
    } on FirebaseException catch (e, st) {
      if (e.code == 'object-not-found') return;
      logCaughtError('StorageRepository._deleteItemBestEffort', e, st);
      rethrow;
    }
  }

  Future<void> removeProfilePhoto({required String objectPath}) async {
    final ref = _storage.ref().child(objectPath);

    try {
      await ref.delete();
    } on FirebaseException catch (e, st) {
      if (e.code == 'object-not-found') return;
      logCaughtError('StorageRepository.removeProfilePhoto', e, st);
      rethrow;
    }
  }
}
