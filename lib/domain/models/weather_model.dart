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
  ///
  /// O valor -999.0 é o fill value da NASA (dado indisponível) e é tratado como null.
  /// A API tem lag de 2-3 dias, então buscamos a última data com dado válido.
  factory WeatherModel.fromNasaJson(Map<String, dynamic> json) {
    try {
      final params = json['properties']['parameter'] as Map<String, dynamic>;

      final tMax = params['T2M_MAX'] as Map<String, dynamic>?;
      final tMin = params['T2M_MIN'] as Map<String, dynamic>?;
      final prec = params['PRECTOTCORR'] as Map<String, dynamic>?;
      final rh = params['RH2M'] as Map<String, dynamic>?;
      final allsky = params['ALLSKY_SFC_SW_DWN'] as Map<String, dynamic>?;

      // Itera do mais recente para o mais antigo e retorna o primeiro dia
      // onde T2M_MAX tem valor válido (diferente do fill value -999).
      final sortedDates = (tMax?.keys.toList() ?? [])..sort((a, b) => b.compareTo(a));
      final lastValidDate = sortedDates.firstWhere(
        (date) => (tMax?[date] as num?)?.toDouble() != -999.0,
        orElse: () => sortedDates.isNotEmpty ? sortedDates.last : '',
      );

      return WeatherModel(
        temperatureMax: _validValue(tMax?[lastValidDate]),
        temperatureMin: _validValue(tMin?[lastValidDate]),
        precipitation: _validValue(prec?[lastValidDate]),
        humidity: _validValue(rh?[lastValidDate]),
        solarRadiation: _validValue(allsky?[lastValidDate]),
        date: lastValidDate.isEmpty ? null : lastValidDate,
      );
    } catch (_) {
      return WeatherModel();
    }
  }

  /// Retorna null se o valor for o fill value -999 da NASA POWER API.
  static double? _validValue(dynamic value) {
    if (value == null) return null;
    final d = (value as num).toDouble();
    return d == -999.0 ? null : d;
  }
}