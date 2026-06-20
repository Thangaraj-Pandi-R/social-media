import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_media/core/errors/failure.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> uploadFile({
    required String path,
    required File file,
    String contentType = 'image/jpeg',
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final bytes = await file.readAsBytes();
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw StorageFailure(e.toString());
    }
  }

  static Future<void> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } catch (_) {
      // Ignore failures when deleting file silently (e.g. file does not exist)
    }
  }
}
