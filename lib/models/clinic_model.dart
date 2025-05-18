// model/clinic_model.dart

class Clinic {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String phone;

  Clinic({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.phone,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      name: json['name'],
      address: json['address'],
      lat: json['lat'].toDouble(),
      lng: json['lng'].toDouble(),
      phone: json['phone'],
    );
  }
}
