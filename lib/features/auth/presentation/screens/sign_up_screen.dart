import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../navigation/main_nav_scaffold.dart';
import '../controllers/auth_provider.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedCountryCode = '+1';
  bool _obscurePassword = true;

  final List<Map<String, String>> _countryCodes = [
    {'code': '+1', 'label': '🇺🇸 +1 (US/CA)'},
    {'code': '+44', 'label': '🇬🇧 +44 (UK)'},
    {'code': '+251', 'label': '🇪🇹 +251 (ET)'},
    {'code': '+971', 'label': '🇦🇪 +971 (UAE)'},
    {'code': '+49', 'label': '🇩🇪 +49 (DE)'},
    {'code': '+33', 'label': '🇫🇷 +33 (FR)'},
    {'code': '+91', 'label': '🇮🇳 +91 (IN)'},
    {'code': '+61', 'label': '🇦🇺 +61 (AU)'},
    {'code': '+254', 'label': '🇰🇪 +254 (KE)'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();

    if (!_formKey.currentState!.validate()) return;

    final fullName = _nameController.text.trim();
    final fullPhoneNumber = '$_selectedCountryCode ${_phoneController.text.trim()}';
    final password = _passwordController.text;

    final success = await auth.signUp(
      fullName: fullName,
      phoneNumber: fullPhoneNumber,
      password: password,
    );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavScaffold()),
        (route) => false,
      );
    }
  }

  int _calculatePasswordStrength(String pass) {
    if (pass.isEmpty) return 0;
    int strength = 0;
    if (pass.length >= 6) strength++;
    if (pass.contains(RegExp(r'[A-Z]')) || pass.contains(RegExp(r'[0-9]'))) strength++;
    if (pass.length >= 8 && pass.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) strength++;
    return strength;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final strength = _calculatePasswordStrength(_passwordController.text);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Adaptive Theme Tokens
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.lightBorder;
    final textPrimary = isDark ? Colors.white : AppColors.lightTextPrimary;
    final textSecondary = isDark ? Colors.white.withValues(alpha: 0.65) : AppColors.lightTextSecondary;
    final textMuted = isDark ? Colors.white.withValues(alpha: 0.35) : AppColors.lightTextMuted;
    final backBtnBg = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05);
    final backBtnBorder = isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.lightBorder;
    final backBtnIcon = isDark ? Colors.white : AppColors.lightTextPrimary;
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.15) : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Back Button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: backBtnBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: backBtnBorder),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: backBtnIcon,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Official App Icon Badge (blends seamlessly in dark & light themes)
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : AppColors.lightBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? AppColors.primary.withValues(alpha: 0.25)
                            : AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    AppConstants.appIconTransparentAsset,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 24),

                // Title & Subtitle
                Row(
                  children: [
                    Text(
                      'Create Account',
                      style: AppTypography.displaySmall.copyWith(
                        color: textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      '.',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Join E\'kid to elevate your daily productivity and focus.',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // Error message banner
                if (auth.errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            auth.errorMessage!,
                            style: TextStyle(
                              color: isDark ? const Color(0xFFFCA5A5) : AppColors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 1. Full Name
                Text(
                  'Full Name',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    style: TextStyle(color: textPrimary, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'e.g. Linda C. Ng',
                      hintStyle: TextStyle(color: textMuted),
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: textMuted,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      if (val.trim().length < 2) {
                        return 'Full name too short';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Phone Number
                Text(
                  'Phone Number',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            dropdownColor: surfaceColor,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: textSecondary,
                              size: 18,
                            ),
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCountryCode = val);
                              }
                            },
                            items: _countryCodes.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['code'],
                                child: Text(
                                  item['label']!,
                                  style: TextStyle(color: textPrimary),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: dividerColor,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: textPrimary, fontSize: 15),
                          decoration: InputDecoration(
                            hintText: '555 0199',
                            hintStyle: TextStyle(color: textMuted),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter phone number';
                            }
                            if (val.trim().length < 4) {
                              return 'Enter valid phone number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Password
                Text(
                  'Password',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: textPrimary, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Minimum 6 characters',
                      hintStyle: TextStyle(color: textMuted),
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: textMuted,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: textMuted,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (val.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),

                // Password strength indicator bars
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: strength >= 1
                                ? Colors.orange
                                : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: strength >= 2
                                ? Colors.amber
                                : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: strength >= 3
                                ? AppColors.success
                                : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 36),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Bottom switch to Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const SignInScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
