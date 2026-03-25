// Tests unitaires basiques de l'application e-commerce

import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    test('Email validator accepts valid emails', () {
      expect(Validators.validateEmail('test@example.com'), null);
      expect(Validators.validateEmail('user.name@domain.co.uk'), null);
    });

    test('Email validator rejects invalid emails', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('invalid'), isNotNull);
      expect(Validators.validateEmail('test@'), isNotNull);
      expect(Validators.validateEmail('@example.com'), isNotNull);
    });

    test('Password validator works correctly', () {
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword('123'), isNotNull); // trop court
      expect(Validators.validatePassword('password123'), null);
    });

    test('Required validator function works', () {
      final validator = Validators.required('Field is required');
      expect(validator(''), equals('Field is required'));
      expect(validator(null), equals('Field is required'));
      expect(validator('valid'), null);
    });
  });
}
