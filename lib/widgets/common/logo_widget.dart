import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double width;
  final double height;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.width = 200,
    this.height = 80,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(
        'assets/images/travelgate_logo.png',
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text(
              'TravelGate',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppLogoWithTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double logoWidth;
  final double logoHeight;

  const AppLogoWithTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.logoWidth = 150,
    this.logoHeight = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppLogo(
          width: logoWidth,
          height: logoHeight,
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
