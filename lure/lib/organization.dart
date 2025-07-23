// lib/organization.dart

import 'package:flutter/material.dart';

Color hexToColor(String code) {
  try {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  } catch (e) {
    return Colors.grey;
  }
}

class Organization {
  final String name;
  final String logo;
  final String icon;
  final String background;
  final Color cardColour;
  final Color textColour;
  final String addressString; // NEW
  final String message;       // NEW
  
  String? localLogoPath; 
  String? localIconPath;
  String? localBackgroundPath;

  Organization({
    required this.name,
    required this.logo,
    required this.icon,
    required this.background,
    required this.cardColour,
    required this.textColour,
    required this.addressString, // NEW
    required this.message,       // NEW
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
      cardColour: hexToColor(json['card_colour'] as String),
      textColour: hexToColor(json['text_colour'] as String),
      // Access nested and new fields
      addressString: json['address']['string'] as String, // NEW
      message: json['message'] as String,               // NEW
    );
  }
}