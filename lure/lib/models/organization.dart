// lib/models/organization.dart

import 'package:flutter/material.dart';

// Helper function to convert hex color strings to the Color type.
Color hexToColor(String code) {
  try {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  } catch (e) {
    // Return a default color if parsing fails
    return Colors.grey;
  }
}

class Organization {
  final String name;
  final String cat; // NEW: The category field
  final String logo;
  final String icon;
  final String background;
  final Color cardColour;
  final Color textColour;
  final String addressString;
  final String message;
  
  String? localLogoPath; 
  String? localIconPath;
  String? localBackgroundPath;

  Organization({
    required this.name,
    required this.cat, // NEW
    required this.logo,
    required this.icon,
    required this.background,
    required this.cardColour,
    required this.textColour,
    required this.addressString,
    required this.message,
    this.localLogoPath,
    this.localIconPath,
    this.localBackgroundPath,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      name: json['name'] as String,
      cat: json['cat'] as String, // NEW: Parse the category from the JSON
      logo: json['logo'] as String,
      icon: json['icon'] as String,
      background: json['background'] as String,
      cardColour: hexToColor(json['card_colour'] as String),
      textColour: hexToColor(json['text_colour'] as String),
      addressString: json['address']['string'] as String,
      message: json['message'] as String,
    );
  }
}