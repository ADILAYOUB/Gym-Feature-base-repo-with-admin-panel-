class Member {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final String packageTier;
  final DateTime joiningDate;
  final DateTime expireDate;
  final double paidAmount;
  final double dueAmount;
  final String status;
  final String qrCode;

  const Member({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.packageTier,
    required this.joiningDate,
    required this.expireDate,
    required this.paidAmount,
    required this.dueAmount,
    required this.status,
    required this.qrCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'packageTier': packageTier,
      'joiningDate': joiningDate.toIso8601String(),
      'expireDate': expireDate.toIso8601String(),
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'status': status,
      'qrCode': qrCode,
    };
  }

  factory Member.fromJson(Map<String, dynamic> json, String docId) {
    return Member(
      id: docId.isNotEmpty ? docId : (json['id'] ?? ''),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      packageTier: json['packageTier'] ?? 'Gold Membership',
      joiningDate: DateTime.tryParse(json['joiningDate'] ?? '') ?? DateTime.now(),
      expireDate: DateTime.tryParse(json['expireDate'] ?? '') ?? DateTime.now().add(const Duration(days: 365)),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      dueAmount: (json['dueAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Paid',
      qrCode: json['qrCode'] ?? 'GYM-MEMBER-$docId',
    );
  }
}

class SubscriptionTier {
  final String id;
  final String name;
  final double price;
  final int durationMonths;
  final List<String> features;

  const SubscriptionTier({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMonths,
    required this.features,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'durationMonths': durationMonths,
      'features': features,
    };
  }

  factory SubscriptionTier.fromJson(Map<String, dynamic> json, String docId) {
    return SubscriptionTier(
      id: docId.isNotEmpty ? docId : (json['id'] ?? ''),
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationMonths: json['durationMonths'] ?? 1,
      features: List<String>.from(json['features'] ?? []),
    );
  }
}

abstract class MemberRepository {
  Stream<List<Member>> getMembersStream();
  Future<void> addMember(Member member);
  Future<void> updateMember(Member member);
  Future<void> deleteMember(String id);
}

abstract class SubscriptionRepository {
  Stream<List<SubscriptionTier>> getSubscriptionsStream();
  Future<void> addSubscriptionTier(SubscriptionTier tier);
}
