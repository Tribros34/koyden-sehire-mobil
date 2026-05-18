import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../features/public/farmers/models/farmer_model.dart';
import 'founding_badge.dart';
import 'verified_badge.dart';

class FarmerCard extends StatelessWidget {
  final FarmerSummary farmer;

  const FarmerCard({super.key, required this.farmer});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => context.push('/farmers/${farmer.id}'),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.background,
                  backgroundImage: farmer.profileImageUrl == null
                      ? null
                      : CachedNetworkImageProvider(farmer.profileImageUrl!),
                  child: farmer.profileImageUrl == null
                      ? const Icon(Icons.person, color: AppColors.textSecondary)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  farmer.displayName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${farmer.city}, ${farmer.district}',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                if (farmer.isFoundingFarmer)
                  const FoundingBadge()
                else if (farmer.isVerified)
                  const VerifiedBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
