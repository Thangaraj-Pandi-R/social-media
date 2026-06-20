import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:social_media/features/comment/domain/entities/comment_entity.dart';
import 'package:social_media/features/comment/domain/usecases/get_comments_usecase.dart';
import 'package:social_media/features/comment/domain/usecases/add_comment_usecase.dart';
import 'package:social_media/features/comment/domain/usecases/delete_comment_usecase.dart';

part 'comment_provider_mixin.dart';

class CommentProvider extends ChangeNotifier with CommentProviderMixin {
  final GetCommentsUseCase _getCommentsUseCase;
  final AddCommentUseCase _addCommentUseCase;
  final DeleteCommentUseCase _deleteCommentUseCase;

  CommentProvider({
    required GetCommentsUseCase getCommentsUseCase,
    required AddCommentUseCase addCommentUseCase,
    required DeleteCommentUseCase deleteCommentUseCase,
  })  : _getCommentsUseCase = getCommentsUseCase,
        _addCommentUseCase = addCommentUseCase,
        _deleteCommentUseCase = deleteCommentUseCase;

  Future<void> loadComments(String postId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _error = 'No internet connection. Running offline.';
      _loading = false;
      notifyListeners();
      return;
    }

    try {
      final list = await _getCommentsUseCase(postId);
      _commentsMap[postId] = list;
      scrollDown();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String authorPic,
    required String content,
  }) async {
    _adding = true;
    _error = null;
    notifyListeners();

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _error = 'Cannot add comment: No internet connection.';
      _adding = false;
      notifyListeners();
      return false;
    }

    try {
      final comment = await _addCommentUseCase(AddCommentParams(
        postId: postId,
        authorId: authorId,
        authorName: authorName,
        authorPic: authorPic,
        content: content,
      ));

      if (!_commentsMap.containsKey(postId)) {
        _commentsMap[postId] = [];
      }
      _commentsMap[postId]!.add(comment);
      commentCtrl.clear();
      _adding = false;
      notifyListeners();
      scrollDown();
      return true;
    } catch (e) {
      _error = e.toString();
      _adding = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    _error = null;
    notifyListeners();

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _error = 'Cannot delete comment: No internet connection.';
      notifyListeners();
      return false;
    }

    try {
      await _deleteCommentUseCase(DeleteCommentParams(
        postId: postId,
        commentId: commentId,
      ));

      if (_commentsMap.containsKey(postId)) {
        _commentsMap[postId]!.removeWhere((c) => c.id == commentId);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
