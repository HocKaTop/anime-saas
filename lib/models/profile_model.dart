import 'package:flutter/foundation.dart';

import '../data/auth_api.dart';
import '../data/result.dart';
import '../domain/auth_user.dart';

class ProfileModel extends ChangeNotifier {
  ProfileModel(this._auth);

  final AuthApi _auth;

  AuthUser? _user;
  String? _error;
  bool _isLoading = false;
  int _revision = 0;

  AuthUser? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;

  void setUser(AuthUser user){
    if(_user?.id != user.id) return;

      _revision++;
      _user=user;
      _error=null;
      _isLoading=false;
      notifyListeners();
  }

  Future<void> load() async {
    if (_isLoading) return;

    final revision = ++_revision;

    _isLoading = true;
    _error = null;
    _user = null;
    notifyListeners();

    final result = await _auth.me();

    // После выхода старый ответ больше не применяется.
    if (revision != _revision) return;

    switch (result) {
      case Ok(:final value):
        _user = value;

      case Err(:final msg):
        _error = msg;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _revision++;
    _user = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}