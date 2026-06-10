import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../../domain/models/weather_model.dart';

/// Serviço de dados agrometeorológicos via NASA POWER API.
/// Documentação: https://power.larc.nasa.gov/docs/services/api/
class WeatherService {
  static const String _baseUrl =
      'https://power.larc.nasa.gov/api/temporal/daily/point';

  // No web, o navegador bloqueia chamadas cross-origin (CORS).
  // O corsproxy.io atua como intermediário e adiciona os headers necessários.
  static const String _corsProxy = 'https://corsproxy.io/?';

  /// Busca os dados climáticos dos últimos 30 dias para as coordenadas informadas.
  /// Janela de 30 dias garante dados válidos mesmo com o lag típico de 5+ dias da API.
  /// Parâmetros solicitados:
  /// - T2M_MAX / T2M_MIN: temperatura máx e mín a 2m
  /// - PRECTOTCORR: precipitação corrigida
  /// - RH2M: umidade relativa a 2m
  /// - ALLSKY_SFC_SW_DWN: radiação solar total (útil para estimar NDVI)
  Future<WeatherModel> getWeather(double latitude, double longitude) async {
    final now = DateTime.now();
    final end = _formatDate(now);
    final start = _formatDate(now.subtract(const Duration(days: 30)));

    final nasaUri = Uri.parse(_baseUrl).replace(queryParameters: {
      'parameters': 'T2M_MAX,T2M_MIN,PRECTOTCORR,RH2M,ALLSKY_SFC_SW_DWN',
      'community': 'AG',
      'longitude': longitude.toString(),
      'latitude': latitude.toString(),
      'start': start,
      'end': end,
      'format': 'JSON',
    });

    // No web usa proxy CORS; em mobile/desktop chama a API diretamente.
    final uri = kIsWeb
        ? Uri.parse('$_corsProxy${Uri.encodeComponent(nasaUri.toString())}')
        : nasaUri;

    final response = await http.get(uri).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherModel.fromNasaJson(json);
    } else {
      throw Exception('Erro ao buscar dados da NASA POWER API: ${response.statusCode}');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }
}