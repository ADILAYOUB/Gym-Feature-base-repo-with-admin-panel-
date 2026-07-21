import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

class MemberRepositoryImpl implements MemberRepository {
  final FirebaseFirestore _firestore;

  MemberRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Member>> getMembersStream() {
    return _firestore.collection('members').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return _defaultMembers();
      }
      return snapshot.docs.map((doc) => Member.fromJson(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addMember(Member member) async {
    await _firestore.collection('members').add(member.toJson());
  }

  @override
  Future<void> updateMember(Member member) async {
    await _firestore.collection('members').doc(member.id).set(member.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteMember(String id) async {
    await _firestore.collection('members').doc(id).delete();
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
  final FirebaseFirestore _firestore;

  SubscriptionRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<SubscriptionTier>> getSubscriptionsStream() {
    return _firestore.collection('subscriptions').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return _defaultTiers();
      }
      return snapshot.docs.map((doc) => SubscriptionTier.fromJson(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addSubscriptionTier(SubscriptionTier tier) async {
    await _firestore.collection('subscriptions').add(tier.toJson());
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
