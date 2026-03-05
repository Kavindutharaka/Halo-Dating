import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:halo/utils/constants.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String> uploadProfilePhoto({
    required String userId,
    required File file,
  }) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage
        .ref()
        .child(AppConstants.profilePhotosPath)
        .child(userId)
        .child(fileName);

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteProfilePhoto(String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (_) {
      // Photo may have already been deleted
    }
  }

  Future<String> uploadVerificationDoc({
    required String userId,
    required File file,
    required String docType, // 'id' or 'selfie'
  }) async {
    final fileName = '${docType}_${_uuid.v4()}.jpg';
    final ref = _storage
        .ref()
        .child(AppConstants.verificationDocsPath)
        .child(userId)
        .child(fileName);

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }
}
