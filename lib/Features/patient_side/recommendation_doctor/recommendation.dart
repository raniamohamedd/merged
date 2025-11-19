import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/model/recomendation_doctor.dart';
import 'package:flutter_application_2/Features/patient_side/recommendation_doctor/widget/doctor_list_view.dart';
import 'package:flutter_application_2/Features/patient_side/recommendation_doctor/widget/search_and_sort_bar.dart';
import 'package:flutter_application_2/Features/patient_side/recommendation_doctor/widget/sort_bottom_sheet.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/constants/sizes.dart';

class Recommendation extends StatefulWidget {
  const Recommendation({super.key, this.initialQuery = '', this.initialSpec});

  final String initialQuery; // من الهوم
  final String? initialSpec; // من Speciality

  @override
  State<Recommendation> createState() => _RecommendationState();
}

class _RecommendationState extends State<Recommendation> {
  final TextEditingController _searchController = TextEditingController();

  /// حالة الفلاتر
  String _searchQuery = '';
  String? _selectedSpec; // فلتر تخصص أساسي (من Speciality أو من BottomSheet)
  String _sheetSpec = 'All'; // اختيار الـ BottomSheet لعرضه في UI فقط
  double _minRating = 0; // فلتر تقييم كـ double لتفادي مشاكل int

  @override
  void initState() {
    super.initState();
    _searchQuery = (widget.initialQuery).trim();
    _searchController.text = widget.initialQuery;

    // استقبل التخصص الممرَّر من الشاشة السابقة لو موجود
    _selectedSpec = (widget.initialSpec?.trim().isNotEmpty ?? false)
        ? widget.initialSpec!.trim()
        : null;

    // عشان يظهر في الشيب كـ UI (لكن الفلتر الفعلي على _selectedSpec)
    _sheetSpec = _selectedSpec ?? 'All';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Stream واحد من Firestore (الموصى بهم + orderBy rating)
  /// وبعدين هنعمل الفلاتر كلها محليًا (عشان نتجنب مشاكل اختلاف أسماء الحقول/القيم)
  Stream<List<RecomendationDoctorModel>> _stream() {
    return FirebaseFirestore.instance
        .collection('doctors')
        .where('isRecommended', isEqualTo: true)
        .orderBy('rating', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => RecomendationDoctorModel.fromDoc(d))
              .toList(),
        );
  }

  /// تطبيق الفلاتر محليًا بشكل واضح
  List<RecomendationDoctorModel> _applyFilters(
    List<RecomendationDoctorModel> list,
  ) {
    var res = List<RecomendationDoctorModel>.from(list);

    // فلتر التخصص الأساسي (من Speciality أو من BottomSheet لو اختار spec != All)
    if (_selectedSpec != null && _selectedSpec!.trim().isNotEmpty) {
      final want = _selectedSpec!.trim().toLowerCase();
      res = res
          .where((d) => d.specialization.trim().toLowerCase() == want)
          .toList();
    }

    // فلتر البحث (بالاسم/التخصص/المستشفى)
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      res = res
          .where(
            (d) =>
                d.name.toLowerCase().contains(q) ||
                d.specialization.toLowerCase().contains(q) ||
                d.hospital.toLowerCase().contains(q),
          )
          .toList();
    }

    // فلتر التقييم (مثلاً 3.0 فما فوق)
    if (_minRating > 0) {
      res = res.where((d) => d.rating >= _minRating).toList();
    }

    return res;
  }

  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.textColorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return SortBottomSheet(
          selectedSpeciality: _sheetSpec,
          selectedRating: _minRating.toInt(), // لو شيت بتتعامل بالأعداد الصحيحة
          onApply: (spec, rate) {
            setState(() {
              _sheetSpec = spec;

              // طبّق spec فعليًا: لو All يبقى نشيل الفلتر
              if (spec != 'All' && spec.trim().isNotEmpty) {
                _selectedSpec = spec.trim();
              } else {
                _selectedSpec = null;
              }

              // خليه double
              _minRating = rate.toDouble();
            });
          },
        );
      },
    );
  }

  void _clearSpec() {
    setState(() {
      _selectedSpec = null;
      _sheetSpec = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSpec = _selectedSpec != null && _selectedSpec!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(hasSpec ? _selectedSpec! : "Recommendation Doctor"),
        centerTitle: true,
        actions: [
          if (hasSpec)
            TextButton.icon(
              onPressed: _clearSpec,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Clear'),
            ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث + زر الفرز
          SearchAndSortBar(
            controller: _searchController,
            onSearchChanged: (v) => setState(() => _searchQuery = v.trim()),
            onSortPressed: _openSortSheet,
          ),
          SizedBox(height: AppFonts.spaceSmall),

          if (hasSpec)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilterChip(
                  selected: true,
                  label: Text(_selectedSpec!),
                  onSelected: (val) {
                    if (!val) _clearSpec();
                  },
                  avatar: const Icon(Icons.local_hospital_outlined, size: 16),
                ),
              ),
            ),

          Expanded(
            child: StreamBuilder<List<RecomendationDoctorModel>>(
              stream: _stream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data ?? [];
                final items = _applyFilters(data);

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      hasSpec
                          ? "No doctors found in $_selectedSpec."
                          : "No doctors found.",
                    ),
                  );
                }

                return DoctorListView(items: items );
              },
            ),
          ),
        ],
      ),
    );
  }
}
