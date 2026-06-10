import '../services/weather_service.dart';
import '../../domain/models/weather_model.dart';

class WeatherRepository {
  final WeatherService _weatherService;

  WeatherRepository(this._weatherService);

  Future<WeatherModel> getWeather(double latitude, double longitude) {
    return _weatherService.getWeather(latitude, longitude);
  }
}
