part of 'comment_provider.dart';

mixin CommentProviderMixin on ChangeNotifier {
  final Map<String, List<CommentEntity>> _commentsMap = {};
  
  bool _loading = false;
  bool _adding = false;
  String? _error;

  final TextEditingController commentCtrl = TextEditingController();
  final ScrollController scrollCtrl = ScrollController();

  final TextEditingController commentController = TextEditingController(); // alias if needed, but let's point it to the field or use getters
  final ScrollController commentsScrollController = ScrollController(); // alias

  List<CommentEntity> getCommentsForPost(String postId) => _commentsMap[postId] ?? [];
  bool hasCommentsLoaded(String postId) => _commentsMap.containsKey(postId);
  
  bool get loading => _loading;
  bool get isLoading => _loading;

  bool get adding => _adding;
  bool get isAdding => _adding;

  String? get error => _error;
  String? get errorMessage => _error;

  void scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollCtrl.hasClients) {
        scrollCtrl.animateTo(
          scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void scrollToBottom() => scrollDown();

  void resetComments(String postId) {
    _commentsMap.remove(postId);
    commentCtrl.clear();
  }

  void clearCommentsForPost(String postId) => resetComments(postId);

  @override
  void dispose() {
    commentCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }
}
