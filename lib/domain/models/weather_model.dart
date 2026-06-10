/// Modelo com dados agrometeorológicos retornados pela NASA POWER API.
/// Endpoint: https://power.larc.nasa.gov/api/temporal/daily/point
class WeatherModel {
  final double? temperatureMax;
  final double? temperatureMin;
  final double? precipitation;
  final double? humidity;
  final double? solarRadiation; // MJ/m²/dia — relevante para NDVI estimado
  final String? date;

  WeatherModel({
    this.temperatureMax,
    this.temperatureMin,
    this.precipitation,
    this.humidity,
    this.solarRadiation,
    this.date,
  });

  /// Parseia a resposta da NASA POWER API.
  /// A API retorna os dados no formato:
  /// properties.parameter.<PARAM>.<YYYYMMDD>: valor
  factory WeatherModel.fromNasaJson(Map<String, dynamic> json) {
    try {
      final params = json['properties']['parameter'] as Map<String, dynamic>;

      // Pega a última data disponível de qualquer parâmetro
      final tMax = params['T2M_MAX'] as Map<String, dynamic>?;
      final tMin = params['T2M_MIN'] as Map<String, dynamic>?;
      final prec = params['PRECTOTCORR'] as Map<String, dynamic>?;
      final rh = params['RH2M'] as Map<String, dynamic>?;
      final allsky = params['ALLSKY_SFC_SW_DWN'] as Map<String, dynamic>?;

      final lastDate = tMax?.keys.last;

      return WeatherModel(
        temperatureMax: (tMax?[lastDate] as num?)?.toDouble(),
        temperatureMin: (tMin?[lastDate] as num?)?.toDouble(),
        precipitation: (prec?[lastDate] as num?)?.toDouble(),
        humidity: (rh?[lastDate] as num?)?.toDouble(),
        solarRadiation: (allsky?[lastDate] as num?)?.toDouble(),
        date: lastDate,
      );
    } catch (_) {
      return WeatherModel();
    }
  }
}
