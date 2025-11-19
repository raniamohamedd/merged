import 'package:flutter_application_2/models/doctor_model.dart';
import 'package:flutter_application_2/models/patient_model.dart';
import 'package:flutter_application_2/models/user_model.dart';

class UserSession {
  static UserModel? currentUser;
  static DoctorModel? currentDoctor;
  static PatientModel? currentPatient;

  static void clear() {
    currentUser = null;
    currentDoctor = null;
    currentPatient = null;
  }
}