import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';

class RegistrationViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  RegistrationViewModel(this._authRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.signUp(email, password);
    } catch (e) {
      debugPrint('Erro no cadastro: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
