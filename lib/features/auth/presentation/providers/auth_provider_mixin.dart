part of 'auth_provider.dart';

mixin AuthProviderMixin on ChangeNotifier {
  UserEntity? _user;
  bool _loading = false;
  bool _starting = true;
  String? _error;
  StreamSubscription<UserEntity?>? _authSub;
  int _navIdx = 0;

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  bool _hidePassword = true;

  final TextEditingController regEmailCtrl = TextEditingController();
  final TextEditingController regPassCtrl = TextEditingController();
  final TextEditingController regUserCtrl = TextEditingController();
  final TextEditingController regNameCtrl = TextEditingController();
  bool _regHidePassword = true;

  List<NotificationItem> _notifs = [];
  bool _loadingNotifs = false;
  bool _unreadNotifs = false;
  DateTime? _lastReadAt;

  UserEntity? get user => _user;
  UserEntity? get currentUser => _user; // Keep alias for compile compatibility if needed, but let's use user
  bool get loading => _loading;
  bool get isLoading => _loading;
  bool get starting => _starting;
  bool get isInitializing => _starting;
  String? get error => _error;
  String? get errorMessage => _error;
  bool get isAuthenticated => _user != null;
  int get navIdx => _navIdx;
  int get currentNavigationIndex => _navIdx;
  bool get hidePassword => _hidePassword;
  bool get obscurePassword => _hidePassword;
  bool get regHidePassword => _regHidePassword;
  bool get regObscurePassword => _regHidePassword;

  List<NotificationItem> get notifs => _notifs;
  List<NotificationItem> get notifications => _notifs;
  bool get loadingNotifs => _loadingNotifs;
  bool get isNotificationsLoading => _loadingNotifs;
  bool get unreadNotifs => _unreadNotifs;
  bool get hasUnreadNotifications => _unreadNotifs;

  void changeNavIdx(int index) {
    _navIdx = index;
    notifyListeners();
  }

  void setNavigationIndex(int index) => changeNavIdx(index);

  void togglePasswordVisibility() {
    _hidePassword = !_hidePassword;
    notifyListeners();
  }

  void toggleObscurePassword() => togglePasswordVisibility();

  void toggleRegisterPasswordVisibility() {
    _regHidePassword = !_regHidePassword;
    notifyListeners();
  }

  void toggleRegObscurePassword() => toggleRegisterPasswordVisibility();

  void resetForms() {
    emailCtrl.clear();
    passwordCtrl.clear();
    regEmailCtrl.clear();
    regPassCtrl.clear();
    regUserCtrl.clear();
    regNameCtrl.clear();
    _hidePassword = true;
    _regHidePassword = true;
    _error = null;
  }

  void clearFormControllers() => resetForms();

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void updateCurrentUser(UserEntity u) {
    _user = u;
    notifyListeners();
  }

  void readNotifications() {
    _unreadNotifs = false;
    final now = DateTime.now();
    _lastReadAt = now;
    notifyListeners();

    if (_user != null) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('last_read_notifications_time_${_user!.id}', now.toIso8601String());
      }).catchError((_) {});
    }
  }

  void markNotificationsAsRead() => readNotifications();

  @override
  void dispose() {
    _authSub?.cancel();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    regEmailCtrl.dispose();
    regPassCtrl.dispose();
    regUserCtrl.dispose();
    regNameCtrl.dispose();
    super.dispose();
  }
}
