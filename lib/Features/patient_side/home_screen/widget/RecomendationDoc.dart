import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_application_2/Features/patient_side/doctor_review/screens/doctor_details_tabBar.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/constants/sizes.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/model/recomendation_doctor.dart';
import 'package:flutter_application_2/core/services/firestore_services.dart';

import '../../../../data/models/doctor_model.dart';

class RecomendationDoc extends StatelessWidget {
  const RecomendationDoc({super.key, this.searchQuery = ''});

  final String searchQuery;

  Stream<List<RecomendationDoctorModel>> _stream() {
    return FirebaseFirestore.instance
        .collection('doctors')
        .where('isRecommended', isEqualTo: true)
        .orderBy('rating', descending: true)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => RecomendationDoctorModel.fromDoc(d)).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final q = searchQuery.trim().toLowerCase();
    return StreamBuilder<List<RecomendationDoctorModel>>(
      stream: _stream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = (snap.data ?? []);
        final filtered = q.isEmpty
            ? list
            : list
                  .where(
                    (d) =>
                        d.name.toLowerCase().contains(q) ||
                        d.specialization.toLowerCase().contains(q),
                  )
                  .toList();

        if (filtered.isEmpty) {
          return const Center(child: Text("No recommended doctors found."));
        }

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: filtered.length,
          itemBuilder: (context, i) {
            final d = filtered[i];
            final hasHospital = (d.hospital ?? '').trim().isNotEmpty;

            return InkWell(
              onTap: () async {
                FirestoreService firestoreService = FirestoreService();
                DoctorModel? doctorModel = await firestoreService.getDoctor(
                  d.id,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorDetailsTabbarScreen(
                      docModel: doctorModel,
                      doctorId: d.id,

                      
                    ),
                  ),
                );
                            },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                

                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [

                      // Container(
                        
                          // decoration: BoxDecoration(
                          //     // color: AppColors.blueColor,
                          //     borderRadius: BorderRadius.circular(9),
                          //    border: Border.all(
                          //      width: 0.8,
                          //      color: AppColors.blueColor
                              
                               
                            //  ),),
                        // child: 
                        
                        ClipRRect(

                          borderRadius: BorderRadius.circular(10),
                         
                              child: Image.asset(d.imageUrl , fit: BoxFit.contain
                              ,width : 80 , height : 80 ),
                          
                         
                        ),
                      // ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: 
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.name,
                              style: AppFonts.bodyLarge.copyWith(
                                color: AppColors.textColorBlack,
                              ),
                            ),
                            const SizedBox(height: 5),

                            Text(
                              hasHospital
                                  ? '${d.specialization} • ${d.hospital}'
                                  : d.specialization,
                              style: TextStyle(color: AppColors.greyColor),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text("${d.rating}"),
                                const SizedBox(width: 4),
                                Text("(${d.reviews} reviews)"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
