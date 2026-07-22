import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:domain/domain.dart';

class TrainerRepositoryImpl implements TrainerRepository {
  final FirebaseFirestore? _firestoreOverride;
  final List<Trainer> _localTrainers = [];
  late final StreamController<List<Trainer>> _streamController;

  TrainerRepositoryImpl({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore {
    _streamController = StreamController<List<Trainer>>.broadcast();
    _localTrainers.addAll(_defaultTrainers());
  }

  FirebaseFirestore? get _firestore {
    if (_firestoreOverride != null) return _firestoreOverride;
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (_) {}
    return null;
  }

  @override
  Stream<List<Trainer>> getTrainersStream() {
    final fs = _firestore;
    if (fs == null) {
      return _localStream();
    }
    try {
      return fs.collection('trainers').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return List<Trainer>.from(_localTrainers);
        }
        final list = snapshot.docs.map((doc) => Trainer.fromJson(doc.data(), doc.id)).toList();
        _localTrainers.clear();
        _localTrainers.addAll(list);
        return list;
      }).handleError((_) => List<Trainer>.from(_localTrainers));
    } catch (_) {
      return _localStream();
    }
  }

  Stream<List<Trainer>> _localStream() async* {
    yield List<Trainer>.from(_localTrainers);
    yield* _streamController.stream;
  }

  void _notify() {
    if (!_streamController.isClosed) {
      _streamController.add(List<Trainer>.from(_localTrainers));
    }
  }

  @override
  Future<void> addTrainer(Trainer trainer) async {
    final newTrainer = Trainer(
      id: trainer.id.isEmpty ? 'tr-${DateTime.now().millisecondsSinceEpoch}' : trainer.id,
      name: trainer.name,
      role: trainer.role,
      photoUrl: trainer.photoUrl.isEmpty ? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300' : trainer.photoUrl,
      bio: trainer.bio,
      experienceYears: trainer.experienceYears,
      memberCount: trainer.memberCount,
      rating: trainer.rating,
      email: trainer.email,
      phone: trainer.phone,
      address: trainer.address,
      certifications: trainer.certifications,
      schedule: trainer.schedule,
    );

    _localTrainers.insert(0, newTrainer);
    _notify();

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('trainers').add(newTrainer.toJson());
      } catch (_) {}
    }
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
  final FirebaseFirestore? _firestoreOverride;
  final List<ClassBooking> _localBookings = [];
  late final StreamController<List<ClassBooking>> _streamController;

  BookingRepositoryImpl({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore {
    _streamController = StreamController<List<ClassBooking>>.broadcast();
    _localBookings.addAll(_defaultBookings());
  }

  FirebaseFirestore? get _firestore {
    if (_firestoreOverride != null) return _firestoreOverride;
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (_) {}
    return null;
  }

  @override
  Stream<List<ClassBooking>> getUserBookingsStream(String userId) {
    final fs = _firestore;
    if (fs == null) {
      return _localStream();
    }
    try {
      return fs
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return List<ClassBooking>.from(_localBookings);
        }
        final list = snapshot.docs.map((doc) => ClassBooking.fromJson(doc.data(), doc.id)).toList();
        _localBookings.clear();
        _localBookings.addAll(list);
        return list;
      }).handleError((_) => List<ClassBooking>.from(_localBookings));
    } catch (_) {
      return _localStream();
    }
  }

  Stream<List<ClassBooking>> _localStream() async* {
    yield List<ClassBooking>.from(_localBookings);
    yield* _streamController.stream;
  }

  @override
  Future<void> createBooking(ClassBooking booking) async {
    final newBooking = ClassBooking(
      id: booking.id.isEmpty ? 'bk-${DateTime.now().millisecondsSinceEpoch}' : booking.id,
      userId: booking.userId,
      trainerName: booking.trainerName,
      className: booking.className,
      bookingTime: booking.bookingTime,
      status: booking.status,
    );

    _localBookings.insert(0, newBooking);
    _streamController.add(List<ClassBooking>.from(_localBookings));

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('bookings').add(newBooking.toJson());
      } catch (_) {}
    }
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
