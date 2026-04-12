import 'package:flutter_application_2/data/models/doctor_model.dart';
import 'package:flutter_application_2/data/models/patient_model.dart';
import 'package:flutter_application_2/data/models/user_model.dart';

class UserSession {
    static String? accessToken;
  static String? refreshToken;
  static UserModel? currentUser;
  static DoctorModel? currentDoctor;
  static PatientModel? currentPatient;

  static void clear() {
    currentUser = null;
    currentDoctor = null;
    currentPatient = null;
     accessToken = null;
    refreshToken = null;
  }
}

