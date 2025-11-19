import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/chats/view/chat_details_screen.dart';
import 'package:flutter_application_2/Features/patient_side/doctor_review/screens/doctor_details_about_screen.dart';
import 'package:flutter_application_2/Features/patient_side/doctor_review/screens/doctor_details_tabBar.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/models/doctor_model.dart';
import 'package:flutter_application_2/services/firestore_services.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchDoctorsFullUIState();
}

class _SearchDoctorsFullUIState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = "";
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List searchHistory = [];

  String? selectedSpeciality;
  double? selectedRating;

  List specialities = ["All"];

 void _openFilterBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.whiteColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 30,
              right: 30,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.greyColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Center(
                    child: Text(
                      "Sort By",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 20),
                  const Text(
                    "Speciality",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: specialities.map((filter) {
                        final isSelected = selectedSpeciality == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected ? AppColors.whiteColor : AppColors.blackColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            selected: isSelected,
                            showCheckmark: false,
                            selectedColor: AppColors.blueColor,
                            backgroundColor: Colors.grey.shade200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(
                                color: isSelected ? AppColors.blueColor : Colors.grey.shade300,
                              ),
                            ),
                            onSelected: (val) {
                              setModalState(() {
                                selectedSpeciality = val ? filter : null;
                              });
                              setState(() {});},
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Rating",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text("All"),
                          selected: selectedRating == null,
                          showCheckmark: false,
                          selectedColor: AppColors.blueColor,
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: selectedRating == null ? AppColors.whiteColor : Colors.black,
                          ),
                          onSelected: (val) {
                            setModalState(() {
                              selectedRating = null;
                            });
                          },
                        ),
                        ...[5.0, 4.0, 3.0].map((rate) => Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, size: 16, color: AppColors.whiteColor),
                                    const SizedBox(width: 3),
                                    Text(rate.toInt().toString()),
                                  ],
                                ),
                                selected: selectedRating == rate,
                                showCheckmark: false,
                                selectedColor: AppColors.blueColor,
                                backgroundColor: Colors.grey.shade200,
                                labelStyle: TextStyle(
                                  color: selectedRating == rate ? AppColors.whiteColor : Colors.black,
                                ),
                                onSelected: (val) {
                                  setModalState(() {
                                    selectedRating = rate;
                                  });
                                },
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(fontSize: 16, color: AppColors.whiteColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
} @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _loadSpecialities();
  }

  Future _loadSearchHistory() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('search_history')
          .doc(currentUserId)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          searchHistory = List.from(data['history'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Failed to load search history: $e');
    }
  }

  Future _saveSearchHistoryToRemote() async {
    await FirebaseFirestore.instance
        .collection('search_history')
        .doc(currentUserId)
        .set({'history': searchHistory});
  }

  Future _addToSearchHistory(String term) async {
    term = term.trim();
    if (term.isEmpty) return;
    searchHistory.removeWhere((t) => t.toLowerCase() == term.toLowerCase());
    searchHistory.insert(0, term);
    if (searchHistory.length > 10) searchHistory = searchHistory.sublist(0, 10);
    setState(() {});
    await _saveSearchHistoryToRemote();
  }

  Future _loadSpecialities() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('doctors').get();
      final specs = snapshot.docs
          .map((doc) => (doc.data()['specialization'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();
      setState(() {
        specialities = ["All", ...specs];
      });
    } catch (e) {
      debugPrint("Error loading specialities: $e");
    }
  }

  Stream getDoctorsStream() {
    return FirebaseFirestore.instance.collection('doctors').snapshots();
  }

  Future createOrGetChat(String doctorId, String doctorName, String doctorImage) async {
    final patient = FirebaseAuth.instance.currentUser!;
    final patientId = patient.uid;
    final patientDoc = await FirebaseFirestore.instance.collection('users').doc(patientId).get();
    final patientData = patientDoc.data() ?? {};
    final patientName = patientData['name'] ?? 'Patient';
    final patientImage = patientData['image'] ?? 'lib/images/patientt.png';

    final chatId = "${doctorId}_$patientId";
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'doctorId': doctorId,
        'doctorName': doctorName,
        'doctorImage': doctorImage,
        'patientId': patientId,
        'patientName': patientName,
        'patientImage': patientImage,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': "",
      });
    }

    return chatId;
  }

  void _onDoctorTapAndOpenChat({
    required String doctorId,
    required String name,
    required String image,
  }) async {
    await _addToSearchHistory(name);
    final chatId = await createOrGetChat(doctorId, name, image);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatsPagePatient(
          chatId: chatId,
          chatName: name,
          doctorName: name,
        ),
      ),
    );
  }

List<Map<String, dynamic>> _filterDoctors(List docs) {
  final filtered = docs.where((doc) {
    final data = doc.data() as Map<String, dynamic>;

    final name = (data['name'] ?? '').toString().toLowerCase();
    final speciality = (data['specialization'] ?? 'General').toString().toLowerCase();
    final hospital = (data['hospital'] ?? '').toString().toLowerCase();

    final matchesSearch = name.contains(searchText.toLowerCase()) ||
        hospital.contains(searchText.toLowerCase()) ||
        speciality.contains(searchText.toLowerCase());

    final matchesSpeciality =
        selectedSpeciality == null || selectedSpeciality == "All" || speciality == selectedSpeciality!.toLowerCase();

    return matchesSearch && matchesSpeciality;
  }).toList();

  return filtered.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return {
      'id': doc.id,
      'name': data['name'] ?? 'Unknown',
      'image': data['imageUrl'] ?? 'lib/images/patientt.png',
      'specialization': data['specialization'] ?? 'General',
      'hospital': data['hospital'] ?? 'Default Hospital',
      'rating': (data['rating'] != null) ? data['rating'].toDouble() : 4.0,
      'reviews': data['reviews'] ?? 0,
    };
  }).toList();
}


  Widget _buildDoctorsList(List<Map<String, dynamic>> doctors) {
    if (doctors.isEmpty) return const Center(child: Text("No doctors found"));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.greyColor.withOpacity(.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: InkWell(
        onTap: () async {
  FirestoreService firestoreService = FirestoreService();
  DoctorModel? doctorModel = await firestoreService.getDoctor(doctor['id']);

  if (doctorModel != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailsTabbarScreen(docModel: doctorModel, doctorId:doctor['id'],
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Doctor data not found")),
    );
  }
},



            child:
             Expanded(
               child: Container(
                padding: const EdgeInsets.all(15),
                child: 
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      // borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        doctor['image'],
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'lib/images/patientt.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dr. ${doctor['name']}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 5),
                          Row(children: [
               
                             Text(doctor['specialization'], style: TextStyle(color: AppColors.greyColor, fontSize: 13)),
                             const SizedBox(width: 5),
                Text('|'),
                             const SizedBox(width: 5),
               
                          Text("${doctor['hospital']}", style: TextStyle(color: AppColors.greyColor, fontSize: 13)),
                         
               
                          ],),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, color: AppColors.starColor, size: 16),
                              const SizedBox(width: 5),
                              Text("${doctor['rating']} (${doctor['reviews']} reviews)",
                                  style: TextStyle(color: AppColors.greyColor, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // IconButton(
                    //   icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                    //   onPressed: () =>
                    //       _onDoctorTapAndOpenChat(doctorId: doctor['id'], name: doctor['name'], image: doctor['image']),
                    // )
                  ],
                ),
                           ),
             ),
          ),
        );
      },
    );
  }

  Widget _buildFilters() {
    if (searchText.isEmpty) return const SizedBox.shrink();

    return 
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: specialities.map((filter) {
      final isSelected = selectedSpeciality == filter;
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: ChoiceChip(
          label: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              filter,
              style: TextStyle(
                color: isSelected ? AppColors.whiteColor : AppColors.blackColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          selected: isSelected,
          showCheckmark: false,
          selectedColor: AppColors.blueColor,
          backgroundColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(
              color: isSelected ? AppColors.blueColor : Colors.grey.shade300,
            ),
          ),
          onSelected: (val) {
            setState(() {
              selectedSpeciality = val ? filter : null;
            });
          },
        ),
      );
    }).toList(),
  ),
);
  }

  Widget _buildSearchHistoryView() {
    if (searchHistory.isEmpty) {
      return const Center(
        child: Text(
          "Start typing to search",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final reversed = searchHistory.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent searches",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () async {
                  setState(() {
                    searchHistory.clear();
                  });
                  await FirebaseFirestore.instance.collection('search_history').doc(currentUserId).delete();
                },
                child: Text(
                  "Clear All History",
                  style: TextStyle(color: AppColors.blueColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: reversed.length,
            itemBuilder: (context, index) {
              final term = reversed[index];
              return ListTile(
                leading: const Icon(CupertinoIcons.clock),
                title: Text(term),
                trailing: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchHistory.remove(term);
                    _saveSearchHistoryToRemote();
                    setState(() {});
                  },
                ),
                onTap: () {
                  _searchController.text = term;
                  setState(() => searchText = term);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.whiteColor,
        title: const Text(
          "Search ",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => searchText = v.trim()),
                      onSubmitted: (v) async => await _addToSearchHistory(v.trim()),
                      decoration: InputDecoration(
                        hintText: "Search ...",
                        prefixIcon: const Icon(CupertinoIcons.search),
                        filled: true,
                        fillColor: AppColors.greyColor.withOpacity(0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _openFilterBottomSheet,
                    borderRadius: BorderRadius.circular(100),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.filter_list, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildFilters(),
            const SizedBox(height: 20),
            Expanded(
              child: searchText.isEmpty
                  ? _buildSearchHistoryView()
                  : StreamBuilder(
                      stream: getDoctorsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No doctors found"));
                        }

                        final filteredDoctors = _filterDoctors(snapshot.data!.docs);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              child: Text(
                                "${filteredDoctors.length} founds",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
Expanded(child: _buildDoctorsList(filteredDoctors)),
                          ],
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