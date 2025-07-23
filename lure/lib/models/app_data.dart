import 'organization.dart';

class AppData {
  final List<Organization> organizations;
  final List<String> categories;

  AppData({required this.organizations, required this.categories});

  factory AppData.fromJson(Map<String, dynamic> json) {
    // Parse the list of organizations
    final orgsJson = json['orgs'] as List<dynamic>;
    final organizations = orgsJson.map((orgJson) => Organization.fromJson(orgJson)).toList();

    // Parse the list of categories
    final catsJson = json['cats'] as List<dynamic>;
    final categories = catsJson.map((cat) => cat as String).toList();

    return AppData(
      organizations: organizations,
      categories: categories,
    );
  }
}