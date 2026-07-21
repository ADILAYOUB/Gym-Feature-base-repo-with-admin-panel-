class TrainerScheduleItem {
  final String title;
  final String dateStr;
  final String timeStr;
  final int participantsCount;
  final int durationMins;

  const TrainerScheduleItem({
    required this.title,
    required this.dateStr,
    required this.timeStr,
    required this.participantsCount,
    required this.durationMins,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'dateStr': dateStr,
      'timeStr': timeStr,
      'participantsCount': participantsCount,
      'durationMins': durationMins,
    };
  }

  factory TrainerScheduleItem.fromJson(Map<String, dynamic> json) {
    return TrainerScheduleItem(
      title: json['title'] ?? '',
      dateStr: json['dateStr'] ?? 'Today',
      timeStr: json['timeStr'] ?? '08:00 AM',
      participantsCount: json['participantsCount'] ?? 16,
      durationMins: json['durationMins'] ?? 40,
    );
  }
}

class Trainer {
  final String id;
  final String name;
  final String role;
  final String photoUrl;
  final String bio;
  final int experienceYears;
  final int memberCount;
  final double rating;
  final String email;
  final String phone;
  final String address;
  final List<String> certifications;
  final List<TrainerScheduleItem> schedule;

  const Trainer({
    required this.id,
    required this.name,
    required this.role,
    required this.photoUrl,
    required this.bio,
    required this.experienceYears,
    required this.memberCount,
    required this.rating,
    required this.email,
    required this.phone,
    required this.address,
    required this.certifications,
    required this.schedule,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
      'bio': bio,
      'experienceYears': experienceYears,
      'memberCount': memberCount,
      'rating': rating,
      'email': email,
      'phone': phone,
      'address': address,
      'certifications': certifications,
      'schedule': schedule.map((s) => s.toJson()).toList(),
    };
  }

  factory Trainer.fromJson(Map<String, dynamic> json, String docId) {
    return Trainer(
      id: docId.isNotEmpty ? docId : (json['id'] ?? ''),
      name: json['name'] ?? '',
      role: json['role'] ?? 'Strength Coach',
      photoUrl: json['photoUrl'] ?? '',
      bio: json['bio'] ?? 'Certified elite fitness trainer.',
      experienceYears: json['experienceYears'] ?? 5,
      memberCount: json['memberCount'] ?? 150,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      email: json['email'] ?? 'trainer@fitflow.com',
      phone: json['phone'] ?? '+1 234 567 890',
      address: json['address'] ?? '4517 Washington Ave.',
      certifications: List<String>.from(json['certifications'] ?? []),
      schedule: (json['schedule'] as List?)
              ?.map((e) => TrainerScheduleItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class ClassBooking {
  final String id;
  final String userId;
  final String trainerName;
  final String className;
  final DateTime bookingTime;
  final String status;

  const ClassBooking({
    required this.id,
    required this.userId,
    required this.trainerName,
    required this.className,
    required this.bookingTime,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'trainerName': trainerName,
      'className': className,
      'bookingTime': bookingTime.toIso8601String(),
      'status': status,
    };
  }

  factory ClassBooking.fromJson(Map<String, dynamic> json, String docId) {
    return ClassBooking(
      id: docId.isNotEmpty ? docId : (json['id'] ?? ''),
      userId: json['userId'] ?? 'user_1',
      trainerName: json['trainerName'] ?? 'Brooklyn Simmons',
      className: json['className'] ?? 'Chest & Tricep Day',
      bookingTime: DateTime.tryParse(json['bookingTime'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'Confirmed',
    );
  }
}

abstract class TrainerRepository {
  Stream<List<Trainer>> getTrainersStream();
  Future<void> addTrainer(Trainer trainer);
}

abstract class BookingRepository {
  Stream<List<ClassBooking>> getUserBookingsStream(String userId);
  Future<void> createBooking(ClassBooking booking);
}
