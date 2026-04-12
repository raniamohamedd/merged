import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class Doctor {
  final int id;
  final String name;
  final String specialty;
  final String location;
  final int experience;
  final double rating;
  final bool available;
  final bool verified;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.experience,
    required this.rating,
    required this.available,
    required this.verified,
  });
}

class DoctorSearchPage extends StatefulWidget {
  const DoctorSearchPage({super.key});

  @override
  State<DoctorSearchPage> createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage> {
  final List<Doctor> allDoctors = [
    Doctor(
      id: 1,
      name: "Dr. Ahmed Hassan",
      specialty: "Cardiology",
      location: "Cairo Medical Center",
      experience: 15,
      rating: 4.8,
      available: true,
      verified: true,
    ),
    Doctor(
      id: 2,
      name: "Dr. Fatima Ali",
      specialty: "Internal Medicine",
      location: "Alexandria Hospital",
      experience: 10,
      rating: 4.9,
      available: true,
      verified: true,
    ),
    Doctor(
      id: 3,
      name: "Dr. Mohammed Salem",
      specialty: "General Practice",
      location: "City Clinic",
      experience: 8,
      rating: 4.7,
      available: false,
      verified: true,
    ),
    Doctor(
      id: 4,
      name: "Dr. Sarah Ibrahim",
      specialty: "Endocrinology",
      location: "Diabetes Care Center",
      experience: 12,
      rating: 4.9,
      available: true,
      verified: true,
    ),
    Doctor(
      id: 5,
      name: "Dr. Omar Khalil",
      specialty: "Family Medicine",
      location: "Health Plus Clinic",
      experience: 20,
      rating: 4.6,
      available: true,
      verified: true,
    ),
  ];

  String searchQuery = '';
  String filterSpecialty = '';
  String filterAvailability = 'all';
  double? filterMinRating;
  Set<int> requestedDoctors = {};

  List<String> get specialties =>
      allDoctors.map((d) => d.specialty).toSet().toList();

  List<Doctor> get filteredDoctors {
    return allDoctors.where((doctor) {
      final matchesQuery =
          doctor.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              doctor.specialty.toLowerCase().contains(searchQuery.toLowerCase()) ||
              doctor.location.toLowerCase().contains(searchQuery.toLowerCase());

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

  void sendRequest(int doctorId) {
    setState(() {
      requestedDoctors.add(doctorId);
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
                  color:
                      filterSpecialty == specialty ? Colors.white : Colors.black87,
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
                    filterSpecialty = specialty;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 249, 249),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Column(
          children: [
            const SizedBox(height: 37),
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Text(
                "Search Doctor",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueColor,
                ),
              ),
            ),
            const SizedBox(height: 30),

            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search doctor or specialty",
                          prefixIcon: const Icon(CupertinoIcons.search),
                          filled: true,
                          fillColor: AppColors.greyColor.withOpacity(0.08),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            searchQuery = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Search",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Filter by Specialty",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueColor,
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(height: 10),

            buildSpecialtyFilters(),

            const SizedBox(height: 14),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${filteredDoctors.length} doctors found",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: filteredDoctors.isEmpty
                  ? const Center(
                      child: Text("No results found"),
                    )
                  : ListView.builder(
                      itemCount: filteredDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = filteredDoctors[index];
                        final isRequested =
                            requestedDoctors.contains(doctor.id);

                        return Card(
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              doctor.name,
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
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        doctor.location,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Experience: ${doctor.experience} years",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_outline,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Rating: ${doctor.rating}/5",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    // Chip(
                                    //   label: Text(
                                    //     doctor.available
                                    //         ? "Available"
                                    //         : "Not Available",
                                    //   ),
                                    //   backgroundColor: doctor.available
                                    //       ? Colors.green[600]
                                    //       : Colors.grey[600],
                                    //   labelStyle:
                                    //       const TextStyle(color: Colors.white),
                                    // ),
                                    // if (doctor.verified)
                                    //   Chip(
                                    //     label: const Text("Verified"),
                                    //     backgroundColor: AppColors.blueColor,
                                    //     labelStyle: const TextStyle(
                                    //       color: Colors.white,
                                    //     ),
                                    //   ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: isRequested
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.grey,
                                          )
                                        : const Icon(
                                            Icons.person_add,
                                            color: Colors.white,
                                          ),
                                    label: Text(
                                      isRequested
                                          ? "Request Sent"
                                          : "Send Connection Request",
                                      style: isRequested
                                          ? const TextStyle(
                                              color: Colors.grey,
                                            )
                                          : const TextStyle(
                                              color: Colors.white,
                                            ),
                                    ),
                                    onPressed: doctor.available && !isRequested
                                        ? () => sendRequest(doctor.id)
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          doctor.available && !isRequested
                                              ? AppColors.blueColor
                                              : Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}