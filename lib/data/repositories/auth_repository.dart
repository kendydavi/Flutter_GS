import '../services/auth_firebase_service.dart';

class AuthRepository {
  final AuthFirebaseService _authFirebaseService;

  AuthRepository(this._authFirebaseService);

  Future<void> signIn(String email, String password) async {
    return _authFirebaseService.signIn(email, password);
  }

  Future<void> signUp(String email, String password) async {
    return _authFirebaseService.signUp(email, password);
  }

  Future<void> signOut() async {
    return _authFirebaseService.signOut();
  }
}
