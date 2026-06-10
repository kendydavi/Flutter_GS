import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/weather_model.dart';

/// Serviço de dados agrometeorológicos via NASA POWER API.
/// Documentação: https://power.larc.nasa.gov/docs/services/api/
class WeatherService {
  static const String _baseUrl = 'https://power.larc.nasa.gov/api/temporal/daily/point';

  /// Busca os dados climáticos dos últimos 7 dias para as coordenadas informadas.
  /// Parâmetros solicitados:
  /// - T2M_MAX / T2M_MIN: temperatura máx e mín a 2m
  /// - PRECTOTCORR: precipitação corrigida
  /// - RH2M: umidade relativa a 2m
  /// - ALLSKY_SFC_SW_DWN: radiação solar total (útil para estimar NDVI)
  Future<WeatherModel> getWeather(double latitude, double longitude) async {
    final now = DateTime.now();
    final end = _formatDate(now);
    final start = _formatDate(now.subtract(const Duration(days: 7)));

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'parameters': 'T2M_MAX,T2M_MIN,PRECTOTCORR,RH2M,ALLSKY_SFC_SW_DWN',
      'community': 'AG', // comunidade agrícola
      'longitude': longitude.toString(),
      'latitude': latitude.toString(),
      'start': start,
      'end': end,
      'format': 'JSON',
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

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
