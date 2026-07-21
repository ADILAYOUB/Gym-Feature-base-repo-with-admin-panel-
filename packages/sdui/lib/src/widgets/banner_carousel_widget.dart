import 'dart:async';
import 'package:flutter/material.dart';

class BannerCarouselWidget extends StatefulWidget {
  final double height;
  final bool autoScroll;

  const BannerCarouselWidget({
    Key? key,
    required this.height,
    required this.autoScroll,
  }) : super(key: key);

  @override
  State<BannerCarouselWidget> createState() => _BannerCarouselWidgetState();
}

class _BannerCarouselWidgetState extends State<BannerCarouselWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _banners = [
    {
      'title': 'SUMMER SHRED 2026',
      'subtitle': 'Push your limits, shape your future.',
      'image': 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=600'
    },
    {
      'title': 'STRENGTH TRAINING',
      'subtitle': 'Build power & dynamic endurance.',
      'image': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600'
    },
    {
      'title': 'NUTRITIONAL GUIDES',
      'subtitle': 'Feed the machine correctly.',
      'image': 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=600'
    }
  ];

  @override
  void initState() {
    super.initState();
    if (widget.autoScroll) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients) {
          final nextPage = (_currentPage + 1) % _banners.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(banner['image']!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.srcOver,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        banner['title']!,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        banner['subtitle']!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: _currentPage == index ? 20 : 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? theme.colorScheme.primary
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
