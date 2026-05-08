import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/doctorProfile2.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/doctorsProfile.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';

// ─────────────────────────────────────────────
// Doctor Model
// ─────────────────────────────────────────────
class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String location;
  final int experience;
  final double rating;
  final bool available;
  final bool verified;
  final bool isMyDoctor; // ✅ جديد
  final Map<String, dynamic> rawData;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.experience,
    required this.rating,
    required this.available,
    required this.verified,
    required this.isMyDoctor, // ✅ جديد
    required this.rawData,
  });

factory Doctor.fromJson(Map<String, dynamic> json) {
  final user = (json['userId'] is Map) ? json['userId'] as Map<String, dynamic> : {};
  return Doctor(
    id: (user['_id'] ?? user['id'] ?? json['_id'] ?? '').toString(),
    name: (user['fullName'] ?? 'Unknown Doctor').toString(),
    specialty: (json['specialization'] ?? 'General').toString(),
    location: (json['clinicLocation'] ?? 'Unknown Location').toString(),
    experience: int.tryParse((json['experienceYears'] ?? '0').toString()) ?? 0,
    rating: 0.0,
    available: true,
    verified: json['isVerified'] ?? false,
    rawData: json, isMyDoctor: json['isMyDoctor'] ?? false,
  );
}
}

// ─────────────────────────────────────────────
// Search Page
// ─────────────────────────────────────────────
class DoctorSearchPage extends StatefulWidget {
  const DoctorSearchPage({super.key});

  @override
  State<DoctorSearchPage> createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage> {
  List<Doctor> allDoctors = [];
  bool isLoading = true;
  String errorMessage = '';

  String searchQuery = '';
  String filterSpecialty = '';
  String filterAvailability = 'all';
  double? filterMinRating;

  // ✅ بتتملى تلقائياً من isMyDoctor في الـ API response
  Set<String> requestedDoctors = {};

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchDoctors() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final doctors = await ApiService.getDoctors();

      setState(() {
        allDoctors = doctors;
        // ✅ الدكاترة اللي isMyDoctor = true بيتحطوا في requestedDoctors تلقائياً
        requestedDoctors = doctors
            .where((d) => d.isMyDoctor)
            .map((d) => d.id)
            .toSet();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<String> get specialties =>
      allDoctors.map((d) => d.specialty).toSet().toList();

  List<Doctor> get filteredDoctors {
    return allDoctors.where((doctor) {
      final matchesQuery =
          doctor.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              doctor.specialty
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              doctor.location
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());

      final matchesSpecialty =
          filterSpecialty.isEmpty ? true : doctor.specialty == filterSpecialty;

      final matchesAvailability = filterAvailability == 'all'
          ? true
          : filterAvailability == 'available'
              ? doctor.available
              : !doctor.available;

      final matchesRating =
          filterMinRating != null ? doctor.rating >= filterMinRating! : true;

      return matchesQuery &&
          matchesSpecialty &&
          matchesAvailability &&
          matchesRating;
    }).toList();
  }

  void sendRequest(String doctorId) {
    // ✅ أضفه في requestedDoctors على طول عشان الـ UI يتحدث فوراً
    setState(() {
      requestedDoctors.add(doctorId);
    });

    ApiService.sendContactRequest(doctorId).then((response) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ Connection request sent'),
        backgroundColor: Colors.green,
      ));
    }).catchError((e) {
      // ✅ لو فشل، ارجع الحالة
      setState(() {
        requestedDoctors.remove(doctorId);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('❌ Failed to send request: $e'),
        backgroundColor: Colors.red,
      ));
    });
  }

  Widget buildSpecialtyFilters() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text("All"),
              selected: filterSpecialty.isEmpty,
              showCheckmark: false,
              selectedColor: AppColors.blueColor,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: filterSpecialty.isEmpty ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: filterSpecialty.isEmpty
                      ? AppColors.blueColor
                      : Colors.grey.shade300,
                ),
              ),
              onSelected: (_) {
                setState(() {
                  filterSpecialty = '';
                });
              },
            ),
          ),
          ...specialties.map(
            (specialty) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(specialty),
                selected: filterSpecialty == specialty,
                showCheckmark: false,
                selectedColor: AppColors.blueColor,
                backgroundColor: Colors.grey.shade200,
                labelStyle: TextStyle(
                  color: filterSpecialty == specialty
                      ? Colors.white
                      : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: filterSpecialty == specialty
                        ? AppColors.blueColor
                        : Colors.grey.shade300,
                  ),
                ),
                onSelected: (_) {
                  setState(() {
                    filterSpecialty =
                        filterSpecialty == specialty ? '' : specialty;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    // ✅ بيشيل من requestedDoctors أو من isMyDoctor
    final isRequested =
        requestedDoctors.contains(doctor.id) || doctor.isMyDoctor;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorPublicProfileScreen2(doctor: doctor),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Name + Verified
        Row(
  children: [
    // ── صورة الدكتور ──────────────────────────
    // Builder(
    //   builder: (_) {
    //     final raw = doctor.rawData;final imageUrl = raw['proofDocument']?['secure_url']?.toString() ?? '';
    //    return CircleAvatar(
    //       radius: 28,
    //       backgroundColor: AppColors.blueColor.withOpacity(0.1),
    //       backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
    //       child: imageUrl.isEmpty
    //           ? Icon(Icons.person, color: AppColors.blueColor, size: 28)
    //           : null,
    //     );
    //   },
    // ),
    const SizedBox(width: 12),
    // ── اسم + verified ────────────────────────
    Expanded(
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Dr ${doctor.name}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (doctor.verified)
                          const Icon(
                            Icons.verified_user,
                            color: Colors.blue,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(doctor.specialty),
              const SizedBox(height: 16),

              // ── Location
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      doctor.location,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // ── Experience
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    "Experience: ${doctor.experience} years",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // ── Rating
              Row(
                children: [
                  const Icon(Icons.star_outline, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    "Rating: ${doctor.rating}/5",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Send Request Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: isRequested
                      ? const Icon(Icons.check, color: Colors.white)
                      : const Icon(Icons.person_add, color: Colors.white),
                  label: Text(
                    isRequested ? "Accepted" : "Send Connection Request",
                    style: const TextStyle(color: Colors.white),
                  ),
                  // ✅ المشكلة كانت هنا — دلوقتي بيشيك على isRequested بدل available
                  onPressed: isRequested ? null : () => sendRequest(doctor.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isRequested ? Colors.grey : AppColors.blueColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title:  Text(
          "Find a Doctor",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.blueColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => searchQuery = v),
                      decoration: InputDecoration(
                        hintText: "Search by name, specialty or location...",
                        prefixIcon: const Icon(CupertinoIcons.search,
                            color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  if (searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => searchQuery = '');
                      },
                    ),
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      onPressed: () => setState(() {}),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      child: const Text(
                        "Search",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Specialty Filters
            if (!isLoading && allDoctors.isNotEmpty) ...[
              Text(
                "Filter by Specialty",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              buildSpecialtyFilters(),
              const SizedBox(height: 14),
              Text(
                "${filteredDoctors.length} doctors found",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
            ],

            // ── Doctor List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                errorMessage,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: fetchDoctors,
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        )
                      : filteredDoctors.isEmpty
                          ? const Center(child: Text("No results found"))
                          : RefreshIndicator(
                              onRefresh: fetchDoctors,
                              child: ListView.builder(
                                itemCount: filteredDoctors.length,
                                itemBuilder: (context, index) {
                                  return _buildDoctorCard(
                                      filteredDoctors[index]);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}