import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/talhao_model.dart';

class TalhaoService {
  final FirebaseFirestore _firestore;
  static const String _collection = 'talhoes';

  TalhaoService(this._firestore);

  /// Stream em tempo real de todos os talhões do usuário autenticado.
  /// Ordenação feita no Dart para evitar necessidade de índice composto no Firestore.
  Stream<List<TalhaoModel>> getTalhoesStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final talhoes = snapshot.docs
              .map((doc) => TalhaoModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList();
          talhoes.sort((a, b) =>
              (b.dataCadastro ?? '').compareTo(a.dataCadastro ?? ''));
          return talhoes;
        });
  }

  /// Adiciona um novo talhão vinculado ao userId.
  Future<void> addTalhao(TalhaoModel talhao, String userId) async {
    final data = {...talhao.toJson(), 'userId': userId};
    data.remove('id'); // Firestore gera o ID automaticamente
    await _firestore.collection(_collection).add(data);
  }

  /// Remove um talhão pelo ID do documento.
  Future<void> deleteTalhao(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  /// Atualiza o status de um talhão.
  Future<void> updateStatus(String id, String status) async {
    await _firestore.collection(_collection).doc(id).update({'status': status});
  }
}