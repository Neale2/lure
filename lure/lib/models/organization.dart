// lib/models/organization.dart

import 'package:flutter/material.dart';

// Helper function to convert hex color strings.
Color hexToColor(String code) {
  try {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  } catch (e) {
    return Colors.grey;
  }
}

// NEW: A dedicated class for the address.
class Address {
  final String string;
  final double lat;
  final double long;

  Address({required this.string, required this.lat, required this.long});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      string: json['string'] as String,
      lat: (json['lat'] as num).toDouble(),
      long: (json['long'] as num).toDouble(),
    );
  }
}

class Organization {
  final String name;
  final String cat;
  final Address address; // UPDATED: Use the new Address class.
  final String logo;
  final String icon;
  final String background;
  final Color cardColour;
  final Color textColour;
  final String message;
  
  String? localLogoPath; 
  String? localIconPath;
  String? localBackgroundPath;

  Organization({
    required this.name,
    required this.cat,
    required this.address, // UPDATED
    required this.logo,
    required this.icon,
    required this.background,
    required this.cardColour,
    required this.textColour,
    required this.message,
    this.localLogoPath,
    this.localIconPath,
    this.localBackgroundPath,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      name: json['name'] as String,
      cat: json['cat'] as String,
      address: Address.fromJson(json['address']), // UPDATED
      logo: json['logo'] as String,
      icon: json['icon'] as String,
      background: json['background'] as String,
      cardColour: hexToColor(json['card_colour'] as String),
      textColour: hexToColor(json['text_colour'] as String),
      message: json['message'] as String,
    );
  }
}