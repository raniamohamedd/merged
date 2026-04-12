
class DoctorModel {
  final String doctorId;
  final String name;
  final String email;
  final String phoneNumber;
  final String speciality;
  final String imageUrl;
  final String hospital;
  final double rating;
  final int reviews;

  DoctorModel({
    required this.doctorId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.speciality,
    required this.imageUrl,
    required this.hospital,
    this.rating = 0.0,
    this.reviews = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'speciality': speciality,
      'image': imageUrl, 
      'hospital': hospital,
      'rating': rating,
      'reviews': reviews,
      'createdAt': DateTime.now(),
    };
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      doctorId: map['doctorId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      speciality: map['speciality'] ?? '',
      imageUrl: map['image'] ?? '',
      hospital: map['hospital'] ?? 'Not specified',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 0.0,
      reviews: map['reviews'] ?? 0,
    );
  }
}



class ChatModel {
  final String name;
  final String? specialization;
  final String lastMessage;
  final String time;
  final String image;
  int unreadCount;

  ChatModel({
    required this.name,
    this.specialization,
    required this.lastMessage,
    required this.time,
    required this.image,
    required this.unreadCount,
  });
}

List<ChatModel> patientChats = [
  ChatModel(
    name: "Mazen Elsayed",
    lastMessage: "It's been about the last 3 days.",
    time: "7:11 PM",
    image: "lib/images/img.png",
    unreadCount: 1,
  ),
  ChatModel(
    name: "Mahmoud Elsayed",
    lastMessage: "Let's meet tomorrow.",
    time: "7:20 PM",
    image: "lib/images/img.png",
    unreadCount: 0,
  ),
  ChatModel(
    name: "Ali Elsayed",
    lastMessage: "See you soon!",
    time: "6:50 PM",
    image: "lib/images/img.png",
    unreadCount: 3,
  ),
  ChatModel(
    name: "Noor Elsayed",
    lastMessage: "Thanks for your help.",
    time: "5:30 PM",
    image: "lib/images/img.png",
    unreadCount: 1,
  ),
];

List<ChatModel> doctorChats = [
  ChatModel(
    name: "Dr. Randy Wigham",
    specialization: "General Doctor | RSUD Gatot Subroto",
    lastMessage: "Please continue your medication.",
    time: "7:11 PM",
    image: "lib/images/doc1(chat).jpg",
    unreadCount: 1,
  ),
  ChatModel(
    name: "Dr. Jack Sullivan",
    specialization: "General Doctor | RSUD Gatot Subroto",
    lastMessage: "See you next week!",
    time: "8:00 PM",
    image: "lib/images/doc2(chat).jpg",
    unreadCount: 2,
  ),
  ChatModel(
    name: "Dr. Hanna Stanton",
    specialization: "Pediatrician | RSUD Gatot Subroto",
    lastMessage: "Your child is doing better now.",
    time: "9:30 PM",
    image: "lib/images/doc3(chat).jpg",
    unreadCount: 0,
  ),
  ChatModel(
    name: "Dr. Emery Lubin",
    specialization: "Cardiologist | RSUD Gatot Subroto",
    lastMessage: "Keep monitoring your blood pressure.",
    time: "10:00 PM",
    image: "lib/images/doc4(chat).jpg",
    unreadCount: 1,
  ),
];