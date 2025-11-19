import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:flutter_application_2/shared/user_session.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/colors.dart';
import '../../../../models/review_model.dart';
import '../../../../services/firestore_services.dart';
import '../widgets/review_card.dart';

class DoctorDetailsReviewScreen extends StatefulWidget {
  final String doctorId;

  const DoctorDetailsReviewScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailsReviewScreen> createState() =>
      _DoctorDetailsReviewScreenState();
}

class _DoctorDetailsReviewScreenState extends State<DoctorDetailsReviewScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _showReviewBottomSheet() {
    double selectedRating = 0;
    TextEditingController reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Give Rate",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color: index < selectedRating
                              ? Colors.amber
                              : Colors.grey.shade300,
                          size: 32,
                        ),
                        onPressed: () {
                          setModalState(() {
                            selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Write your review here...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedRating == 0 ||
                          reviewController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please add a rating and a comment"),
                          ),
                        );
                        return;
                      }

                      if (UserSession.currentUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("You must be logged in to make a review."),
                          ),
                        );
                        return;
                      }

                      try {
                        // 🟢 إنشاء الريفيو
                        final newReview = ReviewModel(
                          reviewId: const Uuid().v4(),
                          patientId: UserSession.currentUser!.user_id,
                          doctorId: widget.doctorId,
                          rating: selectedRating,
                          comment: reviewController.text,
                        );

                        await _firestoreService.addReview(newReview);

                        // 🟢 تحديث بيانات الدكتور بعد إضافة الريفيو
                        final doctorDoc = await _firestoreService.getDoctor(widget.doctorId);

                        if (doctorDoc != null) {
                          final currentReviews = doctorDoc.reviews;
                          final currentRating = doctorDoc.rating;

                          // حساب المتوسط الجديد
                          final newTotalReviews = currentReviews + 1;
                          final newAverageRating = ((currentRating * currentReviews) + selectedRating) / newTotalReviews;

                          await _firestoreService.updateDoctorData(
                            widget.doctorId,
                            {
                              'reviews': newTotalReviews,
                              'rating': double.parse(newAverageRating.toStringAsFixed(1)),
                            },
                          );
                        }

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Review added successfully!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error adding review: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: StreamBuilder<List<ReviewModel>>(
        stream: _firestoreService.getDoctorReviews(widget.doctorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final reviews = snapshot.data ?? [];
          if (reviews.isEmpty) {
            return const Center(
              child: Text(
                "No reviews yet.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return FutureBuilder<UserModel?>(
                future: _firestoreService.getUser(review.patientId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const SizedBox();
                  }

                  final userModel = snapshot.data!;

                  return ReviewCard(
                    reviewerName: userModel.name,
                    reviewerImageUrl:
                    userModel.image ?? 'lib/images/doctor_avatar.png',
                    rating: review.rating ?? 0,
                    reviewText: review.comment ?? '',
                    timeAgo: review.createdAt
                        .toLocal()
                        .toString()
                        .split(' ')[0],
                  );
                },
              );
            },
          );
        },
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _showReviewBottomSheet,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blueColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Make a Review",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}