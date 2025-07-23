// lib/organization_card.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../hero_dialog_route.dart';
import '../organization.dart';
import 'organization_slab.dart';

class OrganizationCard extends StatelessWidget {
  // It should accept the full Organization object.
  final Organization org;

  const OrganizationCard({ super.key, required this.org });

  @override
  Widget build(BuildContext context) {
    final hasBackground = org.localBackgroundPath != null && File(org.localBackgroundPath!).existsSync();
    const double cardHeight = 180.0;
    const double stripHeight = cardHeight / 3;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: InkWell( // Makes the card tappable
        onTap: () {
          // Push our custom hero dialog route
          Navigator.of(context).push(HeroDialogRoute(
            builder: (context) => OrganizationSlab(org: org),
          ));
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: cardHeight,
              decoration: hasBackground
                  ? BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(File(org.localBackgroundPath!)),
                        fit: BoxFit.cover,
                      ),
                    )
                  : BoxDecoration(color: org.cardColour),
            ),
            // The Hero widget initiates the transition. Its tag must be unique.
            Hero(
              tag: 'org-logo-${org.name}',
              child: _buildCenterPiece(stripHeight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterPiece(double height) {
    final hasLogo = org.localLogoPath != null && File(org.localLogoPath!).existsSync();

    return Container(
      color: org.cardColour,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      child: Center(
        child: hasLogo
            ? Image.file(File(org.localLogoPath!), fit: BoxFit.contain)
            : Text(
                org.name,
                style: TextStyle(
                  color: org.textColour,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}