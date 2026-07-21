import 'package:flutter_riverpod/flutter_riverpod.dart';

// App UI specific state providers
final selectedGenderProvider = StateProvider<String>((ref) => 'men');
final userRoleProvider = StateProvider<String>((ref) => 'super_admin');
