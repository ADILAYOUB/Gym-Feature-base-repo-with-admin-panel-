import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

class TrainerRepositoryImpl implements TrainerRepository {
  final FirebaseFirestore _firestore;

  TrainerRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Trainer>> getTrainersStream() {
    return _firestore.collection('trainers').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return _defaultTrainers();
      }
      return snapshot.docs.map((doc) => Trainer.fromJson(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addTrainer(Trainer trainer) async {
    await _firestore.collection('trainers').add(trainer.toJson());
  }

  List<Trainer> _defaultTrainers() {
    return const [
      Trainer(
        id: 'tr1',
        name: 'Brooklyn Simmons',
        role: 'Strength Coach',
        photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300',
        bio: 'Certified NASM strength coach specializing in athletic hypertrophy and heavy lifting power.',
        experienceYears: 5,
        memberCount: 150,
        rating: 4.9,
        email: 'brooklyn@fitflow.com',
        phone: '+01234567890',
        address: '4517 Washington Ave. Manchester',
        certifications: ['NASM - National Academy of Sports Medicine', 'ACE - American Council on Exercise'],
        schedule: [
          TrainerScheduleItem(title: 'Chest Day', dateStr: 'Thu, 2 Jan', timeStr: '08:00 AM', participantsCount: 16, durationMins: 40),
          TrainerScheduleItem(title: 'Shoulder Day', dateStr: 'Thu, 2 Jan', timeStr: '10:00 AM', participantsCount: 12, durationMins: 40),
          TrainerScheduleItem(title: 'Core Stability', dateStr: 'Thu, 2 Jan', timeStr: '02:00 PM', participantsCount: 18, durationMins: 45),
        ],
      ),
      Trainer(
        id: 'tr2',
        name: 'Savannah Nguyen',
        role: 'HIIT & Mobility Specialist',
        photoUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=300',
        bio: 'ISSA certified trainer focusing on endurance, flexibility, and high-intensity interval training.',
        experienceYears: 4,
        memberCount: 120,
        rating: 4.8,
        email: 'savannah@fitflow.com',
        phone: '+01987654321',
        address: '8910 Broadway St. New York',
        certifications: ['ISSA - International Sports Sciences', 'CrossFit Level 2 Coach'],
        schedule: [
          TrainerScheduleItem(title: 'HIIT Cardio Blast', dateStr: 'Fri, 3 Jan', timeStr: '09:00 AM', participantsCount: 20, durationMins: 45),
          TrainerScheduleItem(title: 'Full Body Mobility', dateStr: 'Fri, 3 Jan', timeStr: '11:00 AM', participantsCount: 15, durationMins: 30),
        ],
      ),
    ];
  }
}

class BookingRepositoryImpl implements BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<ClassBooking>> getUserBookingsStream(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return _defaultBookings();
      }
      return snapshot.docs.map((doc) => ClassBooking.fromJson(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> createBooking(ClassBooking booking) async {
    await _firestore.collection('bookings').add(booking.toJson());
  }

  List<ClassBooking> _defaultBookings() {
    return [
      ClassBooking(
        id: 'b1',
        userId: 'user_1',
        trainerName: 'Brooklyn Simmons',
        className: 'Chest Day',
        bookingTime: DateTime.now().add(const Duration(days: 1)),
        status: 'Confirmed',
      ),
    ];
  }
}
