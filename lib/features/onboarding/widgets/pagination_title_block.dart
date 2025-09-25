import 'package:daily_exposures/constants/gaps.dart';
import 'package:daily_exposures/constants/sizes.dart';
import 'package:flutter/material.dart';

class PaginationTitleBlock extends StatelessWidget {
  const PaginationTitleBlock({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: Sizes.size32),
        ),
        Gaps.v6,
        Text(subtitle, style: TextStyle(fontSize: Sizes.size16)),
      ],
    );
  }
}
