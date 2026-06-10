import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/talhao_model.dart';
import 'add_talhao_screen.dart';
import 'talhao_detail_screen.dart';
import 'login_screen.dart';
import 'view_models/home_view_model.dart';
import 'widgets/talhao_card.dart';
import 'widgets/loading_indicator.dart';

/// Tela principal — listagem em tempo real dos talhões do usuário.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _gotoLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _confirmDelete(BuildContext context, HomeViewModel viewModel, TalhaoModel talhao) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir talhão'),
        content: Text('Deseja excluir "${talhao.nome}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && talhao.id != null) {
      try {
        await viewModel.deleteTalhao(talhao.id!);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<HomeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛰️ AgroSat Sentinel'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) _gotoLogin(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<TalhaoModel>>(
        stream: viewModel.talhoesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Carregando talhões...');
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text('Erro ao carregar dados:\n${snapshot.error}',
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }

          final talhoes = snapshot.data ?? [];

          if (talhoes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.terrain, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhum talhão cadastrado.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque em + para adicionar o primeiro.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: talhoes.length,
            itemBuilder: (context, index) {
              final talhao = talhoes[index];
              return TalhaoCard(
                talhao: talhao,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TalhaoDetailScreen(talhao: talhao),
                  ),
                ),
                onDelete: () => _confirmDelete(context, viewModel, talhao),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTalhaoScreen()),
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo Talhão'),
      ),
    );
  }
}
