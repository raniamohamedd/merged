import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> registerUser(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<UserCredential> loginUser(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(userCredential.user!.uid)
  //           .get();


  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:health_care_app/models/user_model.dart';
// import 'package:health_care_app/models/doctor_model.dart';
// import 'package:health_care_app/models/patient_model.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   /// Getter to get the current logged in user
//   User? get currentUser => _auth.currentUser;

//   /// Register new user
//   Future<String> registerUser({
//     required String name,
//     required String email,
//     required String password,
//     required int phone,
//     required String role,
//     String? specialization,
//   }) async {
//     try {
//       // Step 1: Create user in Firebase Authentication
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );

//       final userId = userCredential.user!.uid;

//       // Step 2: Create user model
//       UserModel newUser = UserModel(
//         user_id: userId,
//         name: name.trim(),
//         email: email.trim(),
//         password: password.trim(),
//         phoneNum: phone,
//         role: role,
//       );

//       // Step 3: Store in 'users' collection
//       await _firestore.collection('users').doc(userId).set(newUser.toMap());

//       // Step 4: Depending on role, create doctor or patient document
//       if (role == 'Doctor') {
//         DoctorModel doctor = DoctorModel(
//           doctorId: userId,
//           specialization: specialization ?? '',
//         );
//         await _firestore.collection('doctors').doc(userId).set(doctor.toMap());
//       } else {
//         PatientModel patient = PatientModel(
//           patientId: userId,
//         );
//         await _firestore.collection('patients').doc(userId).set(patient.toMap());
//       }

//       return "success"; // ✅ success message

//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'weak-password') {
//         return "The password provided is too weak.";
//       } else if (e.code == 'email-already-in-use') {
//         return "The account already exists for that email.";
//       } else if (e.code == 'invalid-email') {
//         return "Invalid email format.";
//       } else {
//         return "FirebaseAuth error: ${e.message}";
//       }
//     } catch (e) {
//       return "Something went wrong: $e";
//     }
//   }
// }
