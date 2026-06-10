class TalhaoModel {
  String? id;
  String? nome;
  String? cultura;
  double? areaHectares;
  double? latitude;
  double? longitude;
  String? status; // "Saudável", "Atenção", "Crítico"
  String? dataCadastro;

  TalhaoModel({
    this.id,
    this.nome,
    this.cultura,
    this.areaHectares,
    this.latitude,
    this.longitude,
    this.status,
    this.dataCadastro,
  });

  TalhaoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    cultura = json['cultura'];
    areaHectares = (json['areaHectares'] as num?)?.toDouble();
    latitude = (json['latitude'] as num?)?.toDouble();
    longitude = (json['longitude'] as num?)?.toDouble();
    status = json['status'];
    dataCadastro = json['dataCadastro'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cultura': cultura,
      'areaHectares': areaHectares,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'dataCadastro': dataCadastro,
    };
  }
}
