import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_media/firebase_options.dart';
import 'package:social_media/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_media/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:social_media/features/profile/domain/repositories/profile_repository.dart';
import 'package:social_media/features/profile/data/repositories/firebase_profile_repository.dart';
import 'package:social_media/features/post/domain/repositories/post_repository.dart';
import 'package:social_media/features/post/data/repositories/firebase_post_repository.dart';
import 'package:social_media/features/comment/domain/repositories/comment_repository.dart';
import 'package:social_media/features/comment/data/repositories/firebase_comment_repository.dart';

class AppConfig {
  static late AuthRepository authRepository;
  static late ProfileRepository profileRepository;
  static late PostRepository postRepository;
  static late CommentRepository commentRepository;

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("AppConfig: Firebase initialized successfully. Running in FIREBASE Mode.");

    authRepository = FirebaseAuthRepository();
    profileRepository = FirebaseProfileRepository();
    postRepository = FirebasePostRepository();
    commentRepository = FirebaseCommentRepository();
  }
}
