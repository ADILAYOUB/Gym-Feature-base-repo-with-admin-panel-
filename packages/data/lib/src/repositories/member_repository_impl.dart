import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:domain/domain.dart';

class MemberRepositoryImpl implements MemberRepository {
  final FirebaseFirestore? _firestoreOverride;
  final List<Member> _localMembers = [];
  late final StreamController<List<Member>> _streamController;

  MemberRepositoryImpl({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore {
    _streamController = StreamController<List<Member>>.broadcast();
    _localMembers.addAll(_defaultMembers());
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
  Stream<List<Member>> getMembersStream() {
    final fs = _firestore;
    if (fs == null) {
      return _localStream();
    }
    try {
      return fs.collection('members').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return List<Member>.from(_localMembers);
        }
        final list = snapshot.docs.map((doc) => Member.fromJson(doc.data(), doc.id)).toList();
        _localMembers.clear();
        _localMembers.addAll(list);
        return list;
      }).handleError((_) => List<Member>.from(_localMembers));
    } catch (_) {
      return _localStream();
    }
  }

  Stream<List<Member>> _localStream() async* {
    yield List<Member>.from(_localMembers);
    yield* _streamController.stream;
  }

  void _notify() {
    if (!_streamController.isClosed) {
      _streamController.add(List<Member>.from(_localMembers));
    }
  }

  @override
  Future<void> addMember(Member member) async {
    final newMember = Member(
      id: member.id.isEmpty ? 'M-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}' : member.id,
      name: member.name,
      email: member.email,
      photoUrl: member.photoUrl.isEmpty ? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200' : member.photoUrl,
      packageTier: member.packageTier,
      joiningDate: member.joiningDate,
      expireDate: member.expireDate,
      paidAmount: member.paidAmount,
      dueAmount: member.dueAmount,
      status: member.status,
      qrCode: member.qrCode.isEmpty ? 'GYM-PASS-${DateTime.now().millisecondsSinceEpoch}' : member.qrCode,
    );

    _localMembers.insert(0, newMember);
    _notify();

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('members').add(newMember.toJson());
      } catch (_) {}
    }
  }

  @override
  Future<void> updateMember(Member member) async {
    final index = _localMembers.indexWhere((m) => m.id == member.id);
    if (index != -1) {
      _localMembers[index] = member;
      _notify();
    }

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('members').doc(member.id).set(member.toJson(), SetOptions(merge: true));
      } catch (_) {}
    }
  }

  @override
  Future<void> deleteMember(String id) async {
    _localMembers.removeWhere((m) => m.id == id);
    _notify();

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('members').doc(id).delete();
      } catch (_) {}
    }
  }

  List<Member> _defaultMembers() {
    return [
      Member(
        id: '3536',
        name: 'Cody Fisher',
        email: 'cody@example.com',
        photoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200',
        packageTier: 'Gold Membership',
        joiningDate: DateTime(2023, 8, 21),
        expireDate: DateTime(2024, 12, 4),
        paidAmount: 450.0,
        dueAmount: 0.0,
        status: 'Paid',
        qrCode: 'GYM-PASS-3536',
      ),
      Member(
        id: '4152',
        name: 'Marvin McKinney',
        email: 'marvin@example.com',
        photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200',
        packageTier: 'Silver Membership',
        joiningDate: DateTime(2023, 5, 19),
        expireDate: DateTime(2024, 11, 12),
        paidAmount: 450.0,
        dueAmount: 450.0,
        status: 'Not paid',
        qrCode: 'GYM-PASS-4152',
      ),
    ];
  }
}

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final FirebaseFirestore? _firestoreOverride;
  final List<SubscriptionTier> _localTiers = [];
  late final StreamController<List<SubscriptionTier>> _streamController;

  SubscriptionRepositoryImpl({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore {
    _streamController = StreamController<List<SubscriptionTier>>.broadcast();
    _localTiers.addAll(_defaultTiers());
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
  Stream<List<SubscriptionTier>> getSubscriptionsStream() {
    final fs = _firestore;
    if (fs == null) {
      return _localStream();
    }
    try {
      return fs.collection('subscriptions').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return List<SubscriptionTier>.from(_localTiers);
        }
        final list = snapshot.docs.map((doc) => SubscriptionTier.fromJson(doc.data(), doc.id)).toList();
        _localTiers.clear();
        _localTiers.addAll(list);
        return list;
      }).handleError((_) => List<SubscriptionTier>.from(_localTiers));
    } catch (_) {
      return _localStream();
    }
  }

  Stream<List<SubscriptionTier>> _localStream() async* {
    yield List<SubscriptionTier>.from(_localTiers);
    yield* _streamController.stream;
  }

  void _notify() {
    if (!_streamController.isClosed) {
      _streamController.add(List<SubscriptionTier>.from(_localTiers));
    }
  }

  @override
  Future<void> addSubscriptionTier(SubscriptionTier tier) async {
    final newTier = SubscriptionTier(
      id: tier.id.isEmpty ? 'sub-${DateTime.now().millisecondsSinceEpoch}' : tier.id,
      name: tier.name,
      price: tier.price,
      durationMonths: tier.durationMonths,
      features: tier.features,
    );

    _localTiers.add(newTier);
    _notify();

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('subscriptions').add(newTier.toJson());
      } catch (_) {}
    }
  }

  List<SubscriptionTier> _defaultTiers() {
    return const [
      SubscriptionTier(
        id: 'gold',
        name: 'Gold Membership',
        price: 49.99,
        durationMonths: 1,
        features: ['Full Gym Access', 'Personalized Workouts', 'Diet Plans', 'Sauna Access'],
      ),
      SubscriptionTier(
        id: 'silver',
        name: 'Silver Membership',
        price: 29.99,
        durationMonths: 1,
        features: ['Gym Floor Access', 'Basic Workout Routines', 'Locker Room'],
      ),
      SubscriptionTier(
        id: 'platinum',
        name: 'Platinum Membership',
        price: 89.99,
        durationMonths: 1,
        features: ['24/7 All Access', 'Personal Coach Sessions', 'Unlimited Diet Charts', 'VIP Lounge'],
      ),
    ];
  }
}
