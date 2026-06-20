import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/core/errors/failure.dart';
import 'package:social_media/core/utils/constants.dart';
import 'package:social_media/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_media/features/profile/data/models/user_model.dart';
import 'package:social_media/features/profile/domain/entities/user_entity.dart';

import 'package:flutter/foundation.dart';

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _mapFirebaseAuthError(fb.FirebaseAuthException e) {
    final code = e.code.toLowerCase();
    final msg = (e.message ?? '').toUpperCase();

    switch (code) {
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check and try again.';
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in instead.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'The email address format is invalid.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'operation-not-allowed':
      case 'configuration-not-found':
        return 'Email & Password sign-in is disabled in Firebase. '
            'Please enable it in Firebase Console → Authentication → Sign-in method.';
      default:
        break;
    }

    if (msg.contains('CONFIGURATION_NOT_FOUND') ||
        msg.contains('OPERATION_NOT_ALLOWED')) {
      return 'Email & Password sign-in is disabled in Firebase. '
          'Please enable it in Firebase Console → Authentication → Sign-in method.';
    }
    if (msg.contains('NETWORK_ERROR') || msg.contains('NETWORK_REQUEST_FAILED')) {
      return 'Network error. Check your internet connection.';
    }
    if (msg.contains('TOO_MANY_ATTEMPTS') || msg.contains('TOO_MANY_REQUESTS')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (msg.contains('USER_DISABLED')) {
      return 'This account has been disabled. Contact support.';
    }
    if (msg.contains('EMAIL_NOT_FOUND') || msg.contains('USER_NOT_FOUND')) {
      return 'No account found with this email. Please sign up first.';
    }
    if (msg.contains('INVALID_PASSWORD') || msg.contains('WRONG_PASSWORD')) {
      return 'Incorrect password. Please try again.';
    }
    if (msg.contains('EMAIL_EXISTS') || msg.contains('EMAIL_ALREADY_IN_USE')) {
      return 'This email is already registered. Try logging in instead.';
    }
    if (msg.contains('WEAK_PASSWORD')) {
      return 'Password is too weak. Use at least 6 characters.';
    }

    return 'An authentication error occurred. Please try again.';
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw const AuthFailure('Login failed. Please try again.');
      }

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        throw const AuthFailure('User profile not found. Please contact support.');
      }

      return UserModel.fromMap(doc.data()!, doc.id);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseAuthError(e));
    } catch (e, stackTrace) {
      if (e is AuthFailure) rethrow;
      debugPrint("FirebaseAuthRepository.login error: $e\n$stackTrace");
      throw ServerFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw const AuthFailure('Sign up failed. Please try again.');
      }

      final usernameQuery = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: username.trim().toLowerCase())
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        await credential.user?.delete();
        throw const AuthFailure('This username is already taken. Please choose another.');
      }

      final newUser = UserModel(
        id: credential.user!.uid,
        username: username.trim().toLowerCase(),
        displayName: displayName.trim(),
        email: email.trim(),
        bio: 'Hello! I am new here.',
        profilePicUrl: '',
        followers: [],
        following: [],
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(newUser.id)
          .set(newUser.toFirestoreMap());

      return newUser;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseAuthError(e));
    } catch (e, stackTrace) {
      if (e is AuthFailure) rethrow;
      debugPrint("FirebaseAuthRepository.signUp error: $e\n$stackTrace");
      throw ServerFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final fbUser = _firebaseAuth.currentUser;
      if (fbUser == null) return null;

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(fbUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) return null;
      try {
        final doc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(fbUser.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!, doc.id);
        }
      } catch (_) {}
      return null;
    });
  }
}
