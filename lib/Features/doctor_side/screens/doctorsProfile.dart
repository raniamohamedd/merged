import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';
import 'package:flutter_application_2/Features/patient_side/search/search_screen.dart';

class DoctorPublicProfileScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorPublicProfileScreen({super.key, required this.doctor});

  @override
  State<DoctorPublicProfileScreen> createState() =>
      _DoctorPublicProfileScreenState();
}

class _DoctorPublicProfileScreenState
    extends State<DoctorPublicProfileScreen> {
  bool isRequesting = false;
  bool requestSent = false;

  Future<void> sendRequest() async {
    setState(() => isRequesting = true);
    try {
      await ApiService.sendContactRequest(widget.doctor.id);
      setState(() => requestSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("✅ Request sent successfully"),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isRequesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doctor;
    final raw = doc.rawData;
    final imageUrl =
        raw['proofDocument']?['secure_url']?.toString() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.blueColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.blueColor,
                      AppColors.blueColor.withOpacity(0.75)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white.withOpacity(0.2),
                     backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.person,
                              color: Colors.white, size: 48)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Dr. ${doc.name}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      doc.specialty,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Info row
                  Row(
                    children: [
                      _infoCard(Icons.work_outline,
                          "${doc.experience} yrs", "Experience"),
                      const SizedBox(width: 10),
                      _infoCard(Icons.location_on_outlined,
                          doc.location, "Location"),
                      const SizedBox(width: 10),
                      _infoCard(
                        doc.verified
                            ? Icons.verified
                            : Icons.pending_outlined,
                        doc.verified ? "Verified" : "Pending",
                        "Status",
                        color:
                            doc.verified ? Colors.green : Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Qualification
                  if (raw['qualification'] != null)
                    _detailCard("Qualification", Icons.school_outlined,
                        raw['qualification'].toString()),

                  // ── License
                  if (raw['licenseNumbers'] != null)
                    _detailCard("License Number", Icons.badge_outlined,
                        raw['licenseNumbers'].toString()),

                  // ── Clinic
                  if (doc.location.isNotEmpty)
                    _detailCard("Clinic Location",
                        Icons.local_hospital_outlined, doc.location),

                  const SizedBox(height: 24),

                  // ── Request Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            requestSent ? Colors.green : AppColors.blueColor,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed:
                          requestSent || isRequesting ? null : sendRequest,
                      icon: isRequesting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Icon(
                              requestSent
                                  ? Icons.check
                                  : Icons.person_add_outlined,
                              color: Colors.white),
                      label: Text(
                        requestSent
                            ? "Request Sent"
                            : "Send Connection Request",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String value, String label,
      {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F2F5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color ?? AppColors.blueColor, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            Text(label,
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _detailCard(String title, IconData icon, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F2F5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.blueColor.withOpacity(.1),
            child:
                Icon(icon, color: AppColors.blueColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12)),
                Text(value,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}