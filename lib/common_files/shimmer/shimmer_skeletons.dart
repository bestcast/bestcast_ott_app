import 'package:flutter/material.dart';
import 'app_shimmer.dart';

/// Screen-level Shimmer Skeleton for Dashboard (Home Screen)
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final double bannerHeight =
        (MediaQuery.of(context).size.height - 320).clamp(380.0, 520.0);

    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          margin: const EdgeInsets.only(top: 160, left: 15, right: 15, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner Skeleton
              Stack(
                children: [
                  ShimmerBox(
                    width: double.infinity,
                    height: bannerHeight,
                    borderRadius: 16.0,
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const ShimmerText(width: 180, height: 22, borderRadius: 6),
                        const SizedBox(height: 10),
                        const ShimmerText(width: 120, height: 13, borderRadius: 4),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            ShimmerBox(width: 110, height: 40, borderRadius: 20),
                            SizedBox(width: 14),
                            ShimmerBox(width: 110, height: 40, borderRadius: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Categories Filter Chips Skeleton
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) => ShimmerBox(
                    width: index == 0 ? 60 : 80,
                    height: 32,
                    borderRadius: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Horizontal Movie Blocks Skeleton (2 blocks)
              _buildBlockSection(titleWidth: 140),
              const SizedBox(height: 24),
              _buildBlockSection(titleWidth: 170),
              const SizedBox(height: 24),
              _buildBlockSection(titleWidth: 130),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockSection({required double titleWidth}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerText(width: titleWidth, height: 18, borderRadius: 4),
              const ShimmerText(width: 45, height: 13, borderRadius: 4),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, __) => const ShimmerPosterCard(
              width: 124,
              height: 165,
              borderRadius: 8,
              margin: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

/// Screen-level Shimmer Skeleton for Movie / Webseries Detail Screen
class DetailScreenSkeleton extends StatelessWidget {
  const DetailScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video / Backdrop Banner Hero
            const ShimmerBox(
              width: double.infinity,
              height: 230,
              borderRadius: 0,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const ShimmerText(width: 220, height: 24, borderRadius: 6),
                  const SizedBox(height: 12),

                  // Metadata Badges Row
                  Row(
                    children: const [
                      ShimmerBox(width: 44, height: 22, borderRadius: 4),
                      SizedBox(width: 8),
                      ShimmerBox(width: 48, height: 22, borderRadius: 4),
                      SizedBox(width: 8),
                      ShimmerBox(width: 60, height: 22, borderRadius: 4),
                      SizedBox(width: 8),
                      ShimmerBox(width: 70, height: 22, borderRadius: 4),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons Row
                  Row(
                    children: const [
                      Expanded(
                        child: ShimmerBox(height: 44, borderRadius: 8),
                      ),
                      SizedBox(width: 12),
                      ShimmerCircle(size: 44),
                      SizedBox(width: 12),
                      ShimmerCircle(size: 44),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Synopsis Description
                  const ShimmerText(width: double.infinity, height: 12),
                  const SizedBox(height: 6),
                  const ShimmerText(width: double.infinity, height: 12),
                  const SizedBox(height: 6),
                  FractionallySizedBox(
                    widthFactor: 0.65,
                    child: const ShimmerText(width: double.infinity, height: 12),
                  ),
                  const SizedBox(height: 26),

                  // Season Tabs / Episodes Section
                  Row(
                    children: const [
                      ShimmerBox(width: 90, height: 32, borderRadius: 16),
                      SizedBox(width: 10),
                      ShimmerBox(width: 90, height: 32, borderRadius: 16),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Episode List items
                  _buildEpisodeItemSkeleton(),
                  const SizedBox(height: 12),
                  _buildEpisodeItemSkeleton(),
                  const SizedBox(height: 12),
                  _buildEpisodeItemSkeleton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodeItemSkeleton() {
    return Row(
      children: [
        const ShimmerBox(width: 110, height: 70, borderRadius: 6),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ShimmerText(width: 140, height: 14, borderRadius: 4),
              SizedBox(height: 8),
              ShimmerText(width: 90, height: 11, borderRadius: 4),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shimmer Skeleton for 3-Column Poster Grid (Search Results & Block Movies)
class SearchGridSkeleton extends StatelessWidget {
  final int itemCount;
  const SearchGridSkeleton({super.key, this.itemCount = 9});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 0.64,
        ),
        itemCount: itemCount,
        itemBuilder: (_, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(
              child: ShimmerBox(
                width: double.infinity,
                borderRadius: 8.0,
              ),
            ),
            SizedBox(height: 6),
            ShimmerText(width: 80, height: 10, borderRadius: 3),
          ],
        ),
      ),
    );
  }
}

/// Shimmer Skeleton for Search Catalog / Popular Movies List
class SearchListSkeleton extends StatelessWidget {
  final int itemCount;
  const SearchListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, __) => Row(
          children: [
            const ShimmerBox(width: 110, height: 64, borderRadius: 6),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerText(width: 160, height: 14, borderRadius: 4),
                  SizedBox(height: 8),
                  ShimmerText(width: 90, height: 11, borderRadius: 4),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const ShimmerCircle(size: 28),
          ],
        ),
      ),
    );
  }
}

/// Shimmer Skeleton for Notification Screen
class NotificationSkeleton extends StatelessWidget {
  final int itemCount;
  const NotificationSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: const Color(0xFF141418),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10, width: 0.6),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerCircle(size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerText(width: 140, height: 14, borderRadius: 4),
                    SizedBox(height: 8),
                    ShimmerText(width: double.infinity, height: 11, borderRadius: 3),
                    SizedBox(height: 4),
                    ShimmerText(width: 180, height: 11, borderRadius: 3),
                    SizedBox(height: 8),
                    ShimmerText(width: 70, height: 10, borderRadius: 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer Skeleton for Profile Main Page
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Profile Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF141418),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const ShimmerCircle(size: 64),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerText(width: 150, height: 18, borderRadius: 4),
                        SizedBox(height: 8),
                        ShimmerText(width: 110, height: 12, borderRadius: 4),
                        SizedBox(height: 10),
                        ShimmerBox(width: 75, height: 22, borderRadius: 11),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions (Downloads & TV Login)
            Row(
              children: const [
                Expanded(child: ShimmerBox(height: 52, borderRadius: 10)),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(height: 52, borderRadius: 10)),
              ],
            ),
            const SizedBox(height: 26),

            // Continue Watching section
            const ShimmerText(width: 150, height: 16, borderRadius: 4),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => const ShimmerBox(
                  width: 160,
                  height: 100,
                  borderRadius: 8,
                ),
              ),
            ),
            const SizedBox(height: 26),

            // My List section
            const ShimmerText(width: 100, height: 16, borderRadius: 4),
            const SizedBox(height: 12),
            SizedBox(
              height: 165,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, __) => const ShimmerPosterCard(
                  width: 120,
                  height: 160,
                  borderRadius: 8,
                  margin: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer Skeleton for Plan Details (Subscriptions)
class PlanDetailsSkeleton extends StatelessWidget {
  final int itemCount;
  const PlanDetailsSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, __) => Container(
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: const Color(0xFF16161C),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  ShimmerText(width: 120, height: 18, borderRadius: 4),
                  ShimmerBox(width: 70, height: 26, borderRadius: 13),
                ],
              ),
              const SizedBox(height: 16),
              const ShimmerText(width: 80, height: 28, borderRadius: 4),
              const SizedBox(height: 16),
              const ShimmerText(width: double.infinity, height: 12, borderRadius: 3),
              const SizedBox(height: 8),
              const ShimmerText(width: 220, height: 12, borderRadius: 3),
              const SizedBox(height: 8),
              const ShimmerText(width: 170, height: 12, borderRadius: 3),
              const SizedBox(height: 20),
              const ShimmerBox(width: double.infinity, height: 44, borderRadius: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer Skeleton for Who's Watching Profile Selector
class WhoWatchingSkeleton extends StatelessWidget {
  final int count;
  const WhoWatchingSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: List.generate(
              count,
              (index) => Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  ShimmerBox(width: 95, height: 95, borderRadius: 12),
                  SizedBox(height: 10),
                  ShimmerText(width: 70, height: 14, borderRadius: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
