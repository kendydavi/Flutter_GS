import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/talhao_model.dart';
import '../../domain/models/weather_model.dart';
import 'view_models/home_view_model.dart';
import 'widgets/status_badge.dart';
import 'widgets/loading_indicator.dart';

/// Tela de detalhes de um talhão, com dados agrometeorológicos da NASA POWER API.
class TalhaoDetailScreen extends StatefulWidget {
  final TalhaoModel talhao;

  const TalhaoDetailScreen({super.key, required this.talhao});

  @override
  State<TalhaoDetailScreen> createState() => _TalhaoDetailScreenState();
}

class _TalhaoDetailScreenState extends State<TalhaoDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Dispara a busca de clima ao abrir a tela, se coordenadas disponíveis
    final lat = widget.talhao.latitude;
    final lon = widget.talhao.longitude;
    if (lat != null && lon != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<HomeViewModel>().fetchWeather(lat, lon);
      });
    }
  }

  @override
  void dispose() {
    context.read<HomeViewModel>().clearWeather();
    super.dispose();
  }

  Future<void> _changeStatus() async {
    final viewModel = context.read<HomeViewModel>();
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Alterar status'),
        children: ['Saudável', 'Atenção', 'Crítico'].map((s) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, s),
            child: Text(s),
          );
        }).toList(),
      ),
    );

    if (selected != null && widget.talhao.id != null) {
      try {
        await viewModel.updateStatus(widget.talhao.id!, selected);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Status atualizado para "$selected"')),
          );
          Navigator.pop(context); // Volta para home (stream atualiza)
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final talhao = widget.talhao;

    return Scaffold(
      appBar: AppBar(
        title: Text(talhao.nome ?? 'Detalhes'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Alterar status',
            onPressed: _changeStatus,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Dados do talhão ---
            _SectionTitle(title: 'Informações do Talhão'),
            _InfoCard(children: [
              _InfoRow(icon: Icons.terrain, label: 'Nome', value: talhao.nome ?? '-'),
              _InfoRow(icon: Icons.grass, label: 'Cultura', value: talhao.cultura ?? '-'),
              _InfoRow(
                icon: Icons.straighten,
                label: 'Área',
                value: '${talhao.areaHectares?.toStringAsFixed(2) ?? '-'} ha',
              ),
              _InfoRow(
                icon: Icons.location_on,
                label: 'Latitude',
                value: talhao.latitude?.toString() ?? '-',
              ),
              _InfoRow(
                icon: Icons.location_on,
                label: 'Longitude',
                value: talhao.longitude?.toString() ?? '-',
              ),
              Row(
                children: [
                  const Icon(Icons.health_and_safety, size: 20, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  const Text('Status:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  StatusBadge(status: talhao.status ?? 'Indefinido'),
                ],
              ),
            ]),

            const SizedBox(height: 20),

            // --- Dados NASA POWER ---
            _SectionTitle(title: '🛰️ Dados NASA POWER (últimos 7 dias)'),
            Consumer<HomeViewModel>(
              builder: (context, vm, _) {
                if (vm.isLoadingWeather) {
                  return const LoadingIndicator(message: 'Consultando NASA POWER API...');
                }
                if (vm.weatherError != null) {
                  return _ErrorCard(message: vm.weatherError!);
                }
                if (vm.weather == null) {
                  return const _ErrorCard(
                      message: 'Coordenadas não informadas. Não é possível buscar dados climáticos.');
                }
                return _WeatherCard(weather: vm.weather!);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- Widgets internos ---

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children
              .expand((w) => [w, const SizedBox(height: 10)])
              .toList()
            ..removeLast(),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  const _WeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (weather.date != null)
              Text(
                'Referência: ${weather.date}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            const SizedBox(height: 12),
            _WeatherRow(
              icon: Icons.thermostat,
              label: 'Temp. Máx.',
              value: '${weather.temperatureMax?.toStringAsFixed(1) ?? '-'} °C',
            ),
            _WeatherRow(
              icon: Icons.thermostat_outlined,
              label: 'Temp. Mín.',
              value: '${weather.temperatureMin?.toStringAsFixed(1) ?? '-'} °C',
            ),
            _WeatherRow(
              icon: Icons.water_drop,
              label: 'Precipitação',
              value: '${weather.precipitation?.toStringAsFixed(2) ?? '-'} mm',
            ),
            _WeatherRow(
              icon: Icons.opacity,
              label: 'Umidade Relativa',
              value: '${weather.humidity?.toStringAsFixed(1) ?? '-'} %',
            ),
            _WeatherRow(
              icon: Icons.wb_sunny,
              label: 'Radiação Solar',
              value: '${weather.solarRadiation?.toStringAsFixed(2) ?? '-'} MJ/m²',
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _WeatherRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}
