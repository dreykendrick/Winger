import 'package:flutter/material.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../domain/entities/product_review.dart';

class ReviewsList extends StatelessWidget {
  final List<ProductReview> reviews;

  const ReviewsList({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const WingerCard(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
              'No customer reviews yet. Be the first to purchase and review!'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: reviews
          .map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: WingerCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(review.authorName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: WingerTokens.accentAmber),
                            const SizedBox(width: 4),
                            Text('${review.rating}'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(review.comment,
                        style: TextStyle(
                            color: Colors.grey.shade800, fontSize: 13)),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
