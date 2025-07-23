// lib/organization.dart

class Organization {
  final String name;
  final String logo;
  final String icon;
  final String background;
  
  String? localLogoPath; 
  String? localIconPath;
  String? localBackgroundPath;

  Organization({
    required this.name,
    required this.logo,
    required this.icon,
    required this.background,
    this.localLogoPath,
    this.localIconPath,
    this.localBackgroundPath,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      name: json['name'] as String,
      logo: json['logo'] as String,
      icon: json['icon'] as String,
      background: json['background'] as String,
    );
  }
}