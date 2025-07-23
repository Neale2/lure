// lib/organization.dart

class Organization {
  final String name;
  final String logo; // e.g., "images/peter_logo.png"
  final String icon; // NEW: e.g., "images/peter_icon.png"
  
  // These will hold the paths to the images on the device after they're cached
  String? localLogoPath; 
  String? localIconPath; // NEW

  Organization({
    required this.name,
    required this.logo,
    required this.icon, // NEW
    this.localLogoPath,
    this.localIconPath, // NEW
  });

  // Update the factory to parse the new 'icon' field
  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      name: json['name'] as String,
      logo: json['logo'] as String,
      icon: json['icon'] as String, // NEW
    );
  }
}