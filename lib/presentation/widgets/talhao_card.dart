import 'package:flutter/material.dart';
import '../../domain/models/talhao_model.dart';
import 'status_badge.dart';

/// Card reutilizável que exibe o resumo de um talhão na listagem.
class TalhaoCard extends StatelessWidget {
  final TalhaoModel talhao;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TalhaoCard({
    super.key,
    required this.talhao,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      talhao.nome ?? 'Sem nome',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: talhao.status ?? 'Indefinido'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.grass, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    talhao.cultura ?? 'Cultura não informada',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.straighten, size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 4),
                  Text(
                    '${talhao.areaHectares?.toStringAsFixed(1) ?? '-'} ha',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.blueGrey),
                      const SizedBox(width: 4),
                      Text(
                        'Lat: ${talhao.latitude?.toStringAsFixed(4) ?? '-'} / '
                        'Lon: ${talhao.longitude?.toStringAsFixed(4) ?? '-'}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Excluir talhão',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
