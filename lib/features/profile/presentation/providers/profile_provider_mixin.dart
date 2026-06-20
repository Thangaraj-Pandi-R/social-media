part of 'profile_provider.dart';

mixin ProfileProviderMixin on ChangeNotifier {
  UserEntity? _profile;
  List<UserEntity> _searchList = [];
  
  bool _loadingProfile = false;
  bool _searching = false;
  bool _working = false;
  String? _error;

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController bioCtrl = TextEditingController();
  XFile? _pickedAvatar;

  final TextEditingController searchCtrl = TextEditingController();

  UserEntity? get profile => _profile;
  UserEntity? get userProfile => _profile;

  List<UserEntity> get searchList => _searchList;
  List<UserEntity> get searchResults => _searchList;

  bool get loadingProfile => _loadingProfile;
  bool get isProfileLoading => _loadingProfile;

  bool get searching => _searching;
  bool get isSearchLoading => _searching;

  bool get working => _working;
  bool get isActionLoading => _working;

  String? get error => _error;
  String? get errorMessage => _error;

  XFile? get pickedAvatar => _pickedAvatar;
  XFile? get selectedAvatar => _pickedAvatar;

  void initEditForm(UserEntity? user) {
    if (user != null) {
      nameCtrl.text = user.displayName;
      bioCtrl.text = user.bio;
      _pickedAvatar = null;
    }
  }

  void initializeEditFields(UserEntity? user) => initEditForm(user);

  void setPickedAvatar(XFile? file) {
    _pickedAvatar = file;
    notifyListeners();
  }

  void setSelectedAvatar(XFile? file) => setPickedAvatar(file);

  void resetEditForm() {
    nameCtrl.clear();
    bioCtrl.clear();
    _pickedAvatar = null;
    _error = null;
  }

  void clearEditFields() => resetEditForm();

  void resetSearch() {
    searchCtrl.clear();
    _searchList = [];
    notifyListeners();
  }

  void clearSearch() => resetSearch();

  @override
  void dispose() {
    nameCtrl.dispose();
    bioCtrl.dispose();
    searchCtrl.dispose();
    super.dispose();
  }
}
