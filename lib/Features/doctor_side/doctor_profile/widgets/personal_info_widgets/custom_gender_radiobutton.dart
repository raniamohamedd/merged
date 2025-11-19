import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/doctor_profile/widgets/personal_info_widgets/custom_profile_button.dart';
import 'package:flutter_application_2/services/firestore_services.dart';
import 'package:flutter_application_2/shared/user_session.dart';

class CustomGenderSelector extends StatefulWidget {
  const CustomGenderSelector({super.key});

  @override
  State<CustomGenderSelector> createState() => _CustomGenderSelectorState();
}

class _CustomGenderSelectorState extends State<CustomGenderSelector> {
  String? _selectedGender;
  bool _isEditing = false;

  final FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _selectedGender = UserSession.currentUser?.gender ?? "Male";
  }

  void _toggleEdit() async {
    if (_isEditing) {
      if (_selectedGender != null) {
        String formattedGender = _selectedGender![0].toUpperCase() +
            _selectedGender!.substring(1).toLowerCase();

        await firestoreService.updateUserField('gender', formattedGender);

        setState(() {
          UserSession.currentUser =
              UserSession.currentUser!.copyWith(gender: formattedGender);
          _isEditing = false;
        });
      }
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          const Text(
            '   Gender',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
  SizedBox(height: 8),
     Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          Expanded(
            child: _isEditing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    
                    children: [
                      Row(
                        children: [
                          const Text('Male'),
                          Radio<String>(
                            value: 'Male',
                            groupValue: _selectedGender,
                            activeColor:
                                Colors.blue, 
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                          ),
                          
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Female'),
                          Radio<String>(
                            value: 'Female',
                            groupValue: _selectedGender,
                            activeColor: Colors.blue,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                          ),
                          
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          _selectedGender!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.right,
                        ),
                      ),
                  ],
                ),
          ),

          const SizedBox(width: 6),

          CustomProfileButton(
            label: _isEditing ? "Save" : "Edit",
            onPressed: _toggleEdit,
          ),
        ],
      ),
    ],);
    
  }
}
