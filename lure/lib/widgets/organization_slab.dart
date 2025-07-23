// lib/organization_slab.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../organization.dart';

class OrganizationSlab extends StatelessWidget {
  final Organization org;

  const OrganizationSlab({super.key, required this.org});

  @override
  Widget build(BuildContext context) {
    // A tap on the background will close the slab.
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent taps inside the slab from closing it
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: org.cardColour,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Make column wrap content
                children: [
                  // This Hero widget's tag MUST match the one in the card.
                  Hero(
                    tag: 'org-logo-${org.name}',
                    child: _buildLogoOrText(70), // Larger logo
                  ),
                  
                  // NEW: Display the background image here
                  _buildBackgroundImage(),

                  const SizedBox(height: 8), // Adjusted spacing

                  Text(
                    org.addressString,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: org.textColour.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    org.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: org.textColour,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build the logo with its fallback
  Widget _buildLogoOrText(double height) {
    final hasLogo = org.localLogoPath != null && File(org.localLogoPath!).existsSync();

    return SizedBox(
      height: height,
      child: hasLogo
          ? Image.file(File(org.localLogoPath!), fit: BoxFit.contain)
          : Text(
              org.name,
              style: TextStyle(
                color: org.textColour,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
    );
  }
  
  // NEW: Helper widget to build the background image view
  Widget _buildBackgroundImage() {
    final hasBackground = org.localBackgroundPath != null && File(org.localBackgroundPath!).existsSync();

    // If there's no background image, return an empty box.
    if (!hasBackground) {
      return const SizedBox(height: 24);
    }

    // If it exists, return it with padding and rounded corners.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.file(
          File(org.localBackgroundPath!),
          height: 150, // Give it a nice, fixed height
          width: double.infinity, // Make it take the full width of the slab
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}