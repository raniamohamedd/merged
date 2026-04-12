import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/book/widget_screen/appointment_type.dart';
import 'package:flutter_application_2/Features/patient_side/book/widget_screen/available_time.dart';
import 'package:flutter_application_2/Features/patient_side/book/widget_screen/gender.dart';
import 'package:flutter_application_2/Features/patient_side/book/widget_screen/patient_information.dart';
import 'package:flutter_application_2/Features/patient_side/book/widget_screen/select_date.dart';
import 'package:flutter_application_2/Features/patient_side/book/widget_screen/text_field_view.dart';
import 'package:flutter_application_2/data/models/doctor_model.dart';
import '../appointment/your_appointment.dart';

class BookAppointment extends StatefulWidget {
  const BookAppointment({
    super.key,
    required this.doctorName,
    // required this.doctorId,
    required this.specialty,
    required this.hospitalName,
    required this.rating,
    required this.doctorImageUrl,
    required this.numberOfReviews,
    required this.workingDays,
    required this.workingHours,
    required this.price,
     required this.docModel,
  });

  final String doctorName;
  // final String doctorId;
  
  final DoctorModel docModel;
  final String specialty;
  final String hospitalName;
  final double rating;
  final String doctorImageUrl;
  final int numberOfReviews;
  final String workingDays;
  final String workingHours;
  final double price;

  @override
  State<BookAppointment> createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  String? appointmentType;
  String fullName = '';
  String age = '';
  String gender = '';
  bool bookingForYou = true;

  // 🟢 متغيرات لتخزين التاريخ والوقت المختار
  DateTime? selectedDate;
  String? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text("Book Appointment"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectDate(
                onDateSelected: (date) {
                  selectedDate = date;
                },
              ),
              const SizedBox(height: 20),

              // 🟢 اختيار الوقت
              AvailableTime(
                onTimeSelected: (time) {
                  selectedTime = time;
                },
              ),
              const SizedBox(height: 20),

              // 🟢 اختيار نوع الموعد
              AppointmentType(
                onTypeSelected: (value) {
                  setState(() {
                    appointmentType = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xff6D7CCD)),
              const SizedBox(height: 5),

              // 🟢 اختيار لمن يتم الحجز
              PatientInformation(
                onSelectionChanged: (value) {
                  setState(() {
                    bookingForYou = value;
                  });
                },
              ),
              const SizedBox(height: 10),

              // 🟢 الاسم والعمر
              TextFieldView(
                onNameChanged: (value) => fullName = value,
                onAgeChanged: (value) => age = value,
              ),
              const SizedBox(height: 7),

              // 🟢 اختيار الجنس
              Gender(onGenderChanged: (value) => gender = value),
              const SizedBox(height: 15),

              // 🟢 زر المتابعة
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff247CFF),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // 🟢 التحقق من ملء جميع الحقول
                  if (fullName.isEmpty ||
                      age.isEmpty ||
                      gender.isEmpty ||
                      selectedDate == null ||
                      selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please fill all fields and select date/time",
                        ),
                      ),
                    );
                    return;
                  }

                  // 🟢 الانتقال لصفحة YourAppointment
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => YourAppointment(
                        // docId: ,
                        docModel: widget.docModel,
                        bookingFor: bookingForYou ? "You" : "Someone Else",
                        fullName: fullName,
                        age: age,
                        gender: gender,
                        appointmentDate: selectedDate!,
                        appointmentTime: selectedTime!,
                        doctorName: widget.doctorName,
                        specialty: widget.specialty,
                        hospitalName: widget.hospitalName,
                        rating: widget.rating,
                        doctorImageUrl: widget.doctorImageUrl,
                        numberOfReviews: widget.numberOfReviews,
                        workingDays: widget.workingDays,
                        workingHours: widget.workingHours,
                        price: widget.price,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
