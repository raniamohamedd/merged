import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';


class ReviewCard extends StatelessWidget {
  final String reviewerName;
  final String reviewerImageUrl;
  final double rating;
  final String reviewText;
  final String timeAgo;

  const ReviewCard({
    super.key,
    required this.reviewerName,
    required this.reviewerImageUrl,
    required this.rating,
    required this.reviewText,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(reviewerImageUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reviewerName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackColor,
                  ),
                ),
              ),
              Text(
                timeAgo,
                style: TextStyle(fontSize: 12, color: AppColors.greyColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                color: AppColors.starColor,
                size: 20,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            reviewText,
            style: TextStyle(fontSize: 14, color: AppColors.greyColor),
          ),
        ],
      ),
    );
  }
}
