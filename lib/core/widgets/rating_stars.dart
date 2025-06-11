import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final Color? unratedColor;
  final int? reviewCount;
  final bool showReviewCount;
  final bool allowHalfRating;
  final MainAxisAlignment mainAxisAlignment;

  const RatingStars({
    Key? key,
    required this.rating,
    this.size = 20.0,
    this.color,
    this.unratedColor,
    this.reviewCount,
    this.showReviewCount = true,
    this.allowHalfRating = true,
    this.mainAxisAlignment = MainAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Colors.amber;
    final unratedStarColor = unratedColor ?? Colors.grey.shade300;
    final textTheme = Theme.of(context).textTheme;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            if (allowHalfRating) {
              if (index < rating.floor()) {
                // Full star
                return Icon(Icons.star, color: starColor, size: size);
              } else if (index == rating.floor() && rating % 1 != 0) {
                // Half star
                return Icon(Icons.star_half, color: starColor, size: size);
              } else {
                // Empty star
                return Icon(Icons.star_border, color: unratedStarColor, size: size);
              }
            } else {
              // No half rating, just round
              return Icon(
                index < rating.round() ? Icons.star : Icons.star_border,
                color: index < rating.round() ? starColor : unratedStarColor,
                size: size,
              );
            }
          }),
        ),
        
        if (showReviewCount && reviewCount != null) ...[
          const SizedBox(width: 4.0),
          Text(
            '($reviewCount)',
            style: textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}
