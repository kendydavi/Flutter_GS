import '../services/talhao_service.dart';
import '../../domain/models/talhao_model.dart';

class TalhaoRepository {
  final TalhaoService _talhaoService;

  TalhaoRepository(this._talhaoService);

  Stream<List<TalhaoModel>> getTalhoesStream(String userId) {
    return _talhaoService.getTalhoesStream(userId);
  }

  Future<void> addTalhao(TalhaoModel talhao, String userId) async {
    return _talhaoService.addTalhao(talhao, userId);
  }

  Future<void> deleteTalhao(String id) async {
    return _talhaoService.deleteTalhao(id);
  }

  Future<void> updateStatus(String id, String status) async {
    return _talhaoService.updateStatus(id, status);
  }
}
