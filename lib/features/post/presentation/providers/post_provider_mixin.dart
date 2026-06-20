part of 'post_provider.dart';

mixin PostProviderMixin on ChangeNotifier {
  List<PostEntity> _posts = [];
  final Map<String, List<PostEntity>> _userPosts = {};
  String? _loadedUid;
  
  bool _loadingFeed = false;
  bool _loadingUserPosts = false;
  bool _working = false;
  String? _error;

  bool _hasMore = true;
  String? _lastId;

  final TextEditingController contentCtrl = TextEditingController();
  XFile? _pickedImage;

  final ScrollController scrollCtrl = ScrollController();
  String? _activeUid;

  String? get activeUid => _activeUid;
  String? get activeUserId => _activeUid;

  List<PostEntity> get posts => _posts;
  List<PostEntity> get feedPosts => _posts;

  List<PostEntity> get userPosts => _userPosts[_loadedUid] ?? [];
  List<PostEntity> getUserPostsFor(String userId) => _userPosts[userId] ?? [];
  bool hasLoadedUserPosts(String userId) => _userPosts.containsKey(userId);
  String? get loadedUid => _loadedUid;
  String? get loadedUserPostsId => _loadedUid;

  bool get loadingFeed => _loadingFeed;
  bool get isFeedLoading => _loadingFeed;

  bool get loadingUserPosts => _loadingUserPosts;
  bool get isUserPostsLoading => _loadingUserPosts;

  bool get working => _working;
  bool get isActionLoading => _working;

  String? get error => _error;
  String? get errorMessage => _error;

  bool get hasMore => _hasMore;
  XFile? get pickedImage => _pickedImage;
  XFile? get selectedPostImage => _pickedImage;

  void setPickedImage(XFile? file) {
    _pickedImage = file;
    notifyListeners();
  }

  void setSelectedPostImage(XFile? file) => setPickedImage(file);

  void resetPostForm() {
    contentCtrl.clear();
    _pickedImage = null;
    _error = null;
  }

  void clearPostCreation() => resetPostForm();

  @override
  void dispose() {
    contentCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }
}
