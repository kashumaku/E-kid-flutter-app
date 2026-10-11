import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/core/theme/app_colors.dart';
import 'package:my_flutter_app/features/auth/data/auth_repository.dart';
import 'package:my_flutter_app/features/auth/presentation/controllers/auth_provider.dart';
import 'package:my_flutter_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:my_flutter_app/features/auth/presentation/screens/sign_up_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late AuthRepository repository;
  late AuthProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = AuthRepository(prefs);
    provider = AuthProvider(repository);
  });

  group('Authentication Unit Tests', () {
    test('Default seed demo user exists', () async {
      final user = await repository.signIn(
        phoneNumber: '+1 555 0199',
        password: 'password123',
      );
      expect(user.fullName, equals('Linda C. Ng'));
      expect(user.initials, equals('LN'));
    });

    test('Sign up creates new user profile and sets as current user', () async {
      final success = await provider.signUp(
        fullName: 'Alex Johnson',
        phoneNumber: '+1 555 4321',
        password: 'secretPassword',
      );

      expect(success, isTrue);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser?.fullName, equals('Alex Johnson'));
      expect(provider.currentUser?.phoneNumber, equals('+1 555 4321'));
      expect(provider.currentUser?.initials, equals('AJ'));

      // Verify persistence in repository
      final currentUser = await repository.getCurrentUser();
      expect(currentUser?.fullName, equals('Alex Johnson'));
    });

    test('Sign in fails with wrong password and sets error message', () async {
      final success = await provider.signIn(
        phoneNumber: '+1 555 0199',
        password: 'wrongPassword',
      );

      expect(success, isFalse);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.errorMessage, contains('Incorrect password'));
    });

    test('Sign up fails if phone number is already registered', () async {
      final first = await provider.signUp(
        fullName: 'User One',
        phoneNumber: '+1 555 7777',
        password: 'password123',
      );
      expect(first, isTrue);

      final duplicate = await provider.signUp(
        fullName: 'User Two',
        phoneNumber: '+1 555 7777',
        password: 'password123',
      );
      expect(duplicate, isFalse);
      expect(provider.errorMessage, contains('already exists'));
    });

    test('Sign out clears session', () async {
      await provider.signIn(
        phoneNumber: '+1 555 0199',
        password: 'password123',
      );
      expect(provider.isAuthenticated, isTrue);

      await provider.signOut();
      expect(provider.isAuthenticated, isFalse);
      expect(provider.currentUser, isNull);
    });
  });

  group('Authentication Theme Tests', () {
    testWidgets('SignInScreen adapts to Light and Dark themes', (tester) async {
      // Light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: provider,
            child: const SignInScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Welcome Back'), findsOneWidget);
      final scaffoldLight = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffoldLight.backgroundColor, equals(AppColors.lightBackground));

      // Dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: provider,
            child: const SignInScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final scaffoldDark = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffoldDark.backgroundColor, equals(AppColors.darkBackground));
    });

    testWidgets('SignUpScreen adapts to Light and Dark themes', (tester) async {
      // Light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: provider,
            child: const SignUpScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Create Account'), findsOneWidget);
      final scaffoldLight = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffoldLight.backgroundColor, equals(AppColors.lightBackground));

      // Dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: provider,
            child: const SignUpScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final scaffoldDark = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffoldDark.backgroundColor, equals(AppColors.darkBackground));
    });
  });
}
