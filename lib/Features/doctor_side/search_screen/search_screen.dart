import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/chats_doctor/view/chat_details_screen.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class SearchScreenD extends StatefulWidget {
  const SearchScreenD({super.key});

  @override
  State<SearchScreenD> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreenD> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = "";
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<String> searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('search_history')
          .doc(currentUserId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          searchHistory = List<String>.from(data['history'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Failed to load search history: $e');
    }
  }

  Future<void> _saveSearchHistoryToRemote() async {
    await FirebaseFirestore.instance
        .collection('search_history')
        .doc(currentUserId)
        .set({'history': searchHistory});
  }

  Future<void> _addToSearchHistory(String term) async {
    term = term.trim();
    if (term.isEmpty) return;
    searchHistory.removeWhere((t) => t.toLowerCase() == term.toLowerCase());
    searchHistory.add(term);
    if (searchHistory.length > 10) {
      searchHistory = searchHistory.sublist(searchHistory.length - 10);
    }
    setState(() {});
    await _saveSearchHistoryToRemote();
  }

  Stream<QuerySnapshot> getPatientsStream() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

 Future<String> createOrGetChat(
    String patientId, String patientName, String patientImage) async {
  final doctor = FirebaseAuth.instance.currentUser!;
  final doctorId = doctor.uid;

  final doctorDoc =
      await FirebaseFirestore.instance.collection('users').doc(doctorId).get();
  final doctorData = doctorDoc.data() ?? {};

  final doctorName = doctorData['name'] ?? 'Doctor';
  final doctorImage = doctorData['imageUrl'] ?? 'lib/images/doctor.png';

  final sortedIds = [doctorId, patientId]..sort();
  final chatId = "${sortedIds[0]}_${sortedIds[1]}";

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
      'unreadCountForPatient': 0,
      'unreadCountForDoctor': 0,
    });
  }

  return chatId;
} void _onPatientTapAndOpenChat({
    required String patientId,
    required String name,
    required String image,
  }) 
  async {
    await _addToSearchHistory(name);
    final chatId = await createOrGetChat(patientId, name, image);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatsPageDoctor(chatName: name, chatId: chatId, doctorName: name)
      ),
    );
  }

  Widget _buildSearchHistoryView() {
    if (searchHistory.isEmpty) {
      return  Center(
        child: Text("Start typing to search", style: TextStyle(color:AppColors.greyColor)),
      );
    }

    final reversed = searchHistory.reversed.toList();

    return ListView.builder(
      itemCount: reversed.length,
      itemBuilder: (context, index) {
        final term = reversed[index];
        return ListTile(
          leading: const Icon(CupertinoIcons.clock),
          title: Text(term),
          trailing: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () async {
              searchHistory.remove(term);
              await _saveSearchHistoryToRemote();
              setState(() {});
            },
          ),
          onTap: () {
            _searchController.text = term;
            setState(() => searchText = term);
          },
        );
      },
    );
  }

  Widget _buildPatientsResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: getPatientsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No patients found."));
        }

        final patients = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final q = searchText.toLowerCase();
          return name.contains(q);
        }).toList();

        if (patients.isEmpty) {
          return const Center(child: Text("No matching patients found."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final docSnap = patients[index];
            final data = docSnap.data() as Map<String, dynamic>;
            final patientId = docSnap.id;
            final name = (data['name'] ?? 'Unknown').toString();
            final image = (data['image'] ?? '').toString();

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.greyColor.withOpacity(.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 12,),
                  ListTile(
                    minTileHeight: 100,
                    leading:
                         ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        data['image'],
                        width: 80,
                        height: 100,
                        fit: BoxFit.fitHeight,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'lib/images/patientt.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing:  Icon(Icons.chat_bubble_outline, color:AppColors.blueColor),
                    onTap: () => _onPatientTapAndOpenChat(
                      patientId: patientId,
                      name: name,
                      image: image,
                    ),
                    
                  ),
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
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.whiteColor,
        title: const Text("Search",
        textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => searchText = v.trim()),
                onSubmitted: (v) async => await _addToSearchHistory(v.trim()),
                decoration: InputDecoration(
                  hintText: "Search by name...",
                  prefixIcon: const Icon(CupertinoIcons.search),
                  filled: true,
                  fillColor: AppColors.greyColor.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  searchText.isEmpty ? _buildSearchHistoryView() : _buildPatientsResults(),
            ),
          ],
        ),
      ),
    );
  }
}