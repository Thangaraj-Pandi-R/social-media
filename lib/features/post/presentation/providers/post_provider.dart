import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/app_config.dart';
import 'package:social_media/features/post/domain/entities/post_entity.dart';
import 'package:social_media/features/post/domain/usecases/create_post_usecase.dart';
import 'package:social_media/features/post/domain/usecases/edit_post_usecase.dart';
import 'package:social_media/features/post/domain/usecases/delete_post_usecase.dart';
import 'package:social_media/features/post/domain/usecases/like_post_usecase.dart';
import 'package:social_media/features/post/domain/usecases/get_feed_posts_usecase.dart';
import 'package:social_media/features/post/domain/usecases/get_user_posts_usecase.dart';

part 'post_provider_mixin.dart';

class PostProvider extends ChangeNotifier with PostProviderMixin {
  final CreatePostUseCase _createPostUseCase;
  final EditPostUseCase _editPostUseCase;
  final DeletePostUseCase _deletePostUseCase;
  final LikePostUseCase _likePostUseCase;
  final GetFeedPostsUseCase _getFeedPostsUseCase;
  final GetUserPostsUseCase _getUserPostsUseCase;
  static const int _pageSize = 15;

  PostProvider({
    required CreatePostUseCase createPostUseCase,
    required EditPostUseCase editPostUseCase,
    required DeletePostUseCase deletePostUseCase,
    required LikePostUseCase likePostUseCase,
    required GetFeedPostsUseCase getFeedPostsUseCase,
    required GetUserPostsUseCase getUserPostsUseCase,
  })  : _createPostUseCase = createPostUseCase,
        _editPostUseCase = editPostUseCase,
        _deletePostUseCase = deletePostUseCase,
        _likePostUseCase = likePostUseCase,
        _getFeedPostsUseCase = getFeedPostsUseCase,
        _getUserPostsUseCase = getUserPostsUseCase {
    _initScrollListener();
    _initAuthListener();
  }

  void _initScrollListener() {
    scrollCtrl.addListener(() {
      if (_activeUid != null &&
          scrollCtrl.position.pixels >= scrollCtrl.position.maxScrollExtent - 200) {
        fetchFeed(_activeUid!);
      }
    });
  }

  void _initAuthListener() {
    AppConfig.authRepository.authStateChanges.listen((user) {
      if (user != null) {
        bindUserFeed(user.id);
      } else {
        _activeUid = null;
        _posts = [];
        _lastId = null;
        _hasMore = true;
        notifyListeners();
      }
    });
  }

  void bindUserFeed(String userId) {
    if (_activeUid != userId) {
      _activeUid = userId;
      fetchFeed(userId, isRefresh: true);
    }
  }

  void bindUserAndLoadFeed(String userId) => bindUserFeed(userId);

  Future<void> fetchFeed(String userId, {bool isRefresh = false}) async {
    if (isRefresh) {
      _posts = [];
      _lastId = null;
      _hasMore = true;
      _error = null;
    }

    if (!_hasMore || _loadingFeed) return;

    _loadingFeed = true;
    notifyListeners();

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _error = 'No internet connection. Running offline.';
      _loadingFeed = false;
      notifyListeners();
      return;
    }

    try {
      final newPosts = await _getFeedPostsUseCase(GetFeedPostsParams(
        userId: userId,
        limit: _pageSize,
        lastPostId: _lastId,
      ));

      if (newPosts.length < _pageSize) {
        _hasMore = false;
      }

      _posts.addAll(newPosts);
      if (_posts.isNotEmpty) {
        _lastId = _posts.last.id;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingFeed = false;
      notifyListeners();
    }
  }

  Future<void> loadFeed(String userId, {bool isRefresh = false}) => fetchFeed(userId, isRefresh: isRefresh);

  Future<void> fetchUserPosts(String userId) async {
    _loadingUserPosts = true;
    _loadedUid = userId;
    _error = null;
    notifyListeners();

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _error = 'No internet connection. Running offline.';
      _loadingUserPosts = false;
      notifyListeners();
      return;
    }

    try {
      _userPosts[userId] = await _getUserPostsUseCase(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingUserPosts = false;
      notifyListeners();
    }
  }

  Future<void> loadUserPosts(String userId) => fetchUserPosts(userId);

  Future<bool> publishPost({
    required String authorId,
    required String authorName,
    required String authorPic,
    required String content,
    dynamic imageFile,
  }) async {
    _working = true;
    _error = null;
    notifyListeners();

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _error = 'Cannot create post: No internet connection.';
      _working = false;
      notifyListeners();
      return false;
    }

    try {
      final newPost = await _createPostUseCase(CreatePostParams(
        authorId: authorId,
        authorName: authorName,
        authorPic: authorPic,
        content: content,
        imageFile: imageFile,
      ));

      _posts.insert(0, newPost);
      if (_userPosts.containsKey(authorId)) {
        _userPosts[authorId]!.insert(0, newPost);
      }
      resetPostForm();
      _working = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _working = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createPost({
    required String authorId,
    required String authorName,
    required String authorPic,
    required String content,
    dynamic imageFile,
  }) => publishPost(
    authorId: authorId,
    authorName: authorName,
    authorPic: authorPic,
    content: content,
    imageFile: imageFile,
  );

  Future<bool> updatePost(String postId, String content) async {
    _working = true;
    _error = null;
    notifyListeners();

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _error = 'Cannot edit post: No internet connection.';
      _working = false;
      notifyListeners();
      return false;
    }

    try {
      final updated = await _editPostUseCase(EditPostParams(postId: postId, content: content));
      
      final feedIdx = _posts.indexWhere((p) => p.id == postId);
      if (feedIdx != -1) _posts[feedIdx] = updated;
      
      _userPosts.forEach((uid, postsList) {
        final idx = postsList.indexWhere((p) => p.id == postId);
        if (idx != -1) postsList[idx] = updated;
      });
      
      _working = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _working = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> editPost(String postId, String content) => updatePost(postId, content);

  Future<bool> removePost(String postId) async {
    _working = true;
    _error = null;
    notifyListeners();

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _error = 'Cannot delete post: No internet connection.';
      _working = false;
      notifyListeners();
      return false;
    }

    try {
      await _deletePostUseCase(postId);
      _posts.removeWhere((p) => p.id == postId);
      _userPosts.forEach((uid, postsList) {
        postsList.removeWhere((p) => p.id == postId);
      });
      _working = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _working = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePost(String postId) => removePost(postId);

  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _error = 'Cannot like/unlike: No internet connection.';
      notifyListeners();
      return;
    }

    final feedIdx = _posts.indexWhere((p) => p.id == postId);
    PostEntity? targetPost;
    String? foundUserId;
    int userIdx = -1;

    if (feedIdx != -1) {
      targetPost = _posts[feedIdx];
    } else {
      for (final entry in _userPosts.entries) {
        final idx = entry.value.indexWhere((p) => p.id == postId);
        if (idx != -1) {
          targetPost = entry.value[idx];
          foundUserId = entry.key;
          userIdx = idx;
          break;
        }
      }
    }

    if (targetPost == null) return;
    final isLiked = targetPost.likes.contains(userId);

    final updatedLikes = List<String>.from(targetPost.likes);
    if (isLiked) {
      updatedLikes.remove(userId);
    } else {
      updatedLikes.add(userId);
    }

    final updatedPost = targetPost.copyWith(likes: updatedLikes);

    if (feedIdx != -1) _posts[feedIdx] = updatedPost;
    if (foundUserId != null && userIdx != -1) {
      _userPosts[foundUserId]![userIdx] = updatedPost;
    }
    notifyListeners();

    try {
      await _likePostUseCase(LikePostParams(
        postId: postId,
        userId: userId,
        isLike: !isLiked,
      ));
    } catch (e) {
      final revertedLikes = List<String>.from(updatedPost.likes);
      if (isLiked) {
        revertedLikes.add(userId);
      } else {
        revertedLikes.remove(userId);
      }
      final revertedPost = targetPost.copyWith(likes: revertedLikes);
      
      if (feedIdx != -1) _posts[feedIdx] = revertedPost;
      if (foundUserId != null && userIdx != -1) {
        _userPosts[foundUserId]![userIdx] = revertedPost;
      }
      _error = 'Failed to toggle like.';
      notifyListeners();
      rethrow;
    }
  }

  void updatePostCommentCount(String postId, int change) {
    final feedIdx = _posts.indexWhere((p) => p.id == postId);

    if (feedIdx != -1) {
      final post = _posts[feedIdx];
      _posts[feedIdx] = post.copyWith(commentCount: (post.commentCount + change).clamp(0, 99999));
    }
    
    _userPosts.forEach((uid, postsList) {
      final idx = postsList.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        final post = postsList[idx];
        postsList[idx] = post.copyWith(commentCount: (post.commentCount + change).clamp(0, 99999));
      }
    });
    notifyListeners();
  }
}
