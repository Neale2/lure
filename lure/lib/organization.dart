// lib/organization.dart

class Organization {
  final String name;
  final String logo; // This is the remote filename, e.g., "images/peter_logo.png"
  
  // This will hold the path to the image on the device after it's cached
  String? localLogoPath; 

  Organization({
    required this.name,
    required this.logo,
    this.localLogoPath,
  });

  // A factory constructor for creating a new Organization instance from a map.
  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      name: json['name'] as String,
      logo: json['logo'] as String,
    );
  }
}