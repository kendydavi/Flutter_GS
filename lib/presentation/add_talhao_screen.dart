import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/talhao_model.dart';
import 'view_models/home_view_model.dart';
import 'widgets/app_button.dart';

/// Tela de cadastro de novo talhão.
class AddTalhaoScreen extends StatefulWidget {
  const AddTalhaoScreen({super.key});

  @override
  State<AddTalhaoScreen> createState() => _AddTalhaoScreenState();
}

class _AddTalhaoScreenState extends State<AddTalhaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _areaController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();

  String _cultura = 'Soja';
  String _status = 'Saudável';
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _areaController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  Future<void> _saveTalhao() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final viewModel = context.read<HomeViewModel>();
      final now = DateTime.now();

      final talhao = TalhaoModel(
        nome: _nomeController.text.trim(),
        cultura: _cultura,
        areaHectares: double.tryParse(_areaController.text.replaceAll(',', '.')),
        latitude: double.tryParse(_latController.text.replaceAll(',', '.')),
        longitude: double.tryParse(_lonController.text.replaceAll(',', '.')),
        status: _status,
        dataCadastro: now.toIso8601String(),
      );

      await viewModel.addTalhao(talhao);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Talhão cadastrado com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Talhão'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Talhão',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.terrain),
                ),
                enabled: !_isLoading,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome do talhão' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _cultura,
                decoration: const InputDecoration(
                  labelText: 'Cultura',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.grass),
                ),
                items: ['Soja', 'Milho', 'Trigo', 'Café', 'Cana-de-açúcar', 'Algodão', 'Outra']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: _isLoading ? null : (v) => setState(() => _cultura = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Área (hectares)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.straighten),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: !_isLoading,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a área';
                  if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Coordenadas (para dados NASA POWER)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                        hintText: 'ex: -23.5',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      enabled: !_isLoading,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Obrigatório';
                        final val = double.tryParse(v.replaceAll(',', '.'));
                        if (val == null || val < -90 || val > 90) return 'Inválida';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lonController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                        hintText: 'ex: -46.6',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      enabled: !_isLoading,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Obrigatório';
                        final val = double.tryParse(v.replaceAll(',', '.'));
                        if (val == null || val < -180 || val > 180) return 'Inválida';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status inicial',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.health_and_safety),
                ),
                items: ['Saudável', 'Atenção', 'Crítico']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: _isLoading ? null : (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'Cadastrar Talhão',
                isLoading: _isLoading,
                icon: Icons.save,
                onPressed: _saveTalhao,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
