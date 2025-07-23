// lib/organization_card.dart

import 'dart:io';
import 'package:flutter/material.dart';

class OrganizationCard extends StatelessWidget {
  final String name;
  final String? logoPath;
  final String? iconPath;
  final String? backgroundPath;

  const OrganizationCard({
    super.key,
    required this.name,
    this.logoPath,
    this.iconPath,
    this.backgroundPath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias, 
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildBackgroundImage(),
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                _buildCachedImage(logoPath, isLogo: true),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            const Shadow(blurRadius: 2.0, color: Colors.black54)
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCachedImage(iconPath, isLogo: false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBackgroundImage() {
    if (backgroundPath == null) return const SizedBox.shrink();

    final imageFile = File(backgroundPath!);
    if (imageFile.existsSync()) {
      return Positioned.fill(
        child: Image.file(
          imageFile,
          fit: BoxFit.cover,
          height: 120,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCachedImage(String? path, {required bool isLogo}) {
    final double size = isLogo ? 80.0 : 24.0;
    final iconOnFail = isLogo ? Icons.business : Icons.info_outline;

    if (path == null) {
      return SizedBox(width: size, height: size);
    }

    final imageFile = File(path);
    if (!imageFile.existsSync()) {
      return Container(
        width: size,
        height: size,
        color: Colors.grey[200]?.withOpacity(0.3),
        child: Icon(iconOnFail, color: Colors.white70),
      );
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(isLogo ? 8.0 : 4.0),
      child: Image.file(
        imageFile,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}