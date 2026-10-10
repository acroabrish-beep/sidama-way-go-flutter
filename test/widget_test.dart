import 'package:flutter_test/flutter_test.dart';
import 'package:sidama_way_go/models/user_model.dart';

void main() {
  test('Sidama Way Go citizen profile defaults are safe', () {
    final user = UserModel(
      uid: 'test-uid',
      fullName: 'Test User',
      email: 'test@example.com',
      phone: '+251900000000',
      role: UserRole.citizen,
      department: '',
      createdAt: DateTime(2026, 1, 1),
      lastLogin: DateTime(2026, 1, 1),
    );

    expect(user.role, UserRole.citizen);
    expect(user.isActive, isTrue);
    expect(user.walletBalance, 0);
  });
}
