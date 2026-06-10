import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/talhao_repository.dart';
import '../../data/repositories/weather_repository.dart';
import '../../domain/models/talhao_model.dart';
import '../../domain/models/weather_model.dart';

class HomeViewModel extends ChangeNotifier {
  final TalhaoRepository _talhaoRepository;
  final WeatherRepository _weatherRepository;
  final FirebaseAuth _firebaseAuth;

  HomeViewModel(
    this._talhaoRepository,
    this._weatherRepository,
    this._firebaseAuth,
  );

  // --- Estado do clima ---
  WeatherModel? _weather;
  WeatherModel? get weather => _weather;

  bool _isLoadingWeather = false;
  bool get isLoadingWeather => _isLoadingWeather;

  String? _weatherError;
  String? get weatherError => _weatherError;

  String? get _userId => _firebaseAuth.currentUser?.uid;

  /// Retorna stream de talhões para um UID específico.
  /// Chamado pela HomeScreen após o Firebase Auth confirmar o usuário,
  /// garantindo que o UID nunca seja nulo no momento da consulta.
  Stream<List<TalhaoModel>> talhoesStreamForUser(String uid) {
    return _talhaoRepository.getTalhoesStream(uid);
  }

  // --- Ações ---

  Future<void> addTalhao(TalhaoModel talhao) async {
    final uid = _userId;
    if (uid == null) return;
    await _talhaoRepository.addTalhao(talhao, uid);
  }

  Future<void> deleteTalhao(String id) async {
    await _talhaoRepository.deleteTalhao(id);
  }

  Future<void> updateStatus(String id, String status) async {
    await _talhaoRepository.updateStatus(id, status);
  }

  /// Busca dados agrometeorológicos da NASA POWER API para o talhão selecionado.
  Future<void> fetchWeather(double latitude, double longitude) async {
    _isLoadingWeather = true;
    _weatherError = null;
    notifyListeners();

    try {
      _weather = await _weatherRepository.getWeather(latitude, longitude);
    } catch (e) {
      _weatherError = 'Erro ao buscar dados climáticos: $e';
      debugPrint(_weatherError);
    } finally {
      _isLoadingWeather = false;
      notifyListeners();
    }
  }

  void clearWeather() {
    _weather = null;
    _weatherError = null;
    notifyListeners();
  }
}