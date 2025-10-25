import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
// removed unused imports
import '../../../shared/presentation/widgets/custom_text_field.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  String? _phoneNumberE164;
  PhoneNumber _initialPhone = PhoneNumber(isoCode: 'US');
  String? _selectedCountryIso;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    _phoneNumberE164 = number.phoneNumber;
                    _selectedCountryIso = number.isoCode;
                  },
                  onInputValidated: (bool value) {
                    // Optional: provide immediate UI feedback if needed
                  },
                  selectorConfig: SelectorConfig(
                    selectorType: PhoneInputSelectorType.DROPDOWN,
                  ),
                  ignoreBlank: true,
                  autoValidateMode: AutovalidateMode.disabled,
                  initialValue: _initialPhone,
                  textFieldController: _phoneController,
                  inputDecoration: InputDecoration(
                    hintText: 'Phone number',
                    filled: true,
                    fillColor: AppTheme.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.grey300),
                    ),
                  ),
                  selectorTextStyle: TextStyle(color: AppTheme.grey700),
                  formatInput: true,
                  keyboardType: TextInputType.number,
                )
                    .animate(delay: Duration(milliseconds: 200))
                    .fadeIn(duration: AppTheme.mediumAnimation)
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 12),
                Text(
                  'Create your account and start trading animals as NFTs in our blockchain marketplace',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: AppTheme.grey600,
                    height: 1.4,
                  ),
                )
                    .animate(delay: Duration(milliseconds: 300))
                    .fadeIn(duration: AppTheme.mediumAnimation)
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.success.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.hub_outlined,
                        size: 16,
                        color: AppTheme.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Blockchain Powered',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(delay: Duration(milliseconds: 400))
                    .fadeIn(duration: AppTheme.mediumAnimation)
                    .scaleXY(begin: 0.8, end: 1.0),
                const SizedBox(height: 24),
                _buildRegisterForm(),
                const SizedBox(height: 20),
                _buildTermsAndConditions(),
                const SizedBox(height: 20),
                _buildRegisterButton(),
                const SizedBox(height: 20),
                _buildSignInSection(),
              ],
            ), // Column
          ), // SingleChildScrollView
        ), // SafeArea
      ), // LoadingOverlay
    ); // Scaffold
  }

  Widget _buildRegisterForm() {
    return PremiumCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(32),
      backgroundColor: Colors.white.withOpacity(0.05),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Details',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.getPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 24),

            // Name fields
            Column(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    hint: 'Enter first name',
                    prefixIcon: Icons.person_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  )
                      .animate(delay: Duration(milliseconds: 500))
                      .fadeIn(duration: AppTheme.mediumAnimation)
                      .slideX(begin: -0.3, end: 0),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    hint: 'Enter last name',
                    prefixIcon: Icons.person_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  )
                      .animate(delay: Duration(milliseconds: 550))
                      .fadeIn(duration: AppTheme.mediumAnimation)
                      .slideX(begin: 0.3, end: 0),
                ),
              ],
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            )
                .animate(delay: Duration(milliseconds: 600))
                .fadeIn(duration: AppTheme.mediumAnimation)
                .slideX(begin: -0.3, end: 0),
            const SizedBox(height: 20),

            const SizedBox.shrink(),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outlined,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppTheme.grey500,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)')
                    .hasMatch(value)) {
                  return 'Password must contain uppercase, lowercase, and number';
                }
                return null;
              },
            )
                .animate(delay: Duration(milliseconds: 700))
                .fadeIn(duration: AppTheme.mediumAnimation)
                .slideX(begin: -0.3, end: 0),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Confirm your password',
              obscureText: _obscureConfirmPassword,
              prefixIcon: Icons.lock_outlined,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppTheme.grey500,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            )
                .animate(delay: Duration(milliseconds: 750))
                .fadeIn(duration: AppTheme.mediumAnimation)
                .slideX(begin: -0.3, end: 0),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 400))
        .fadeIn(duration: AppTheme.mediumAnimation)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildTermsAndConditions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CheckboxListTile(
        title: Text(
          'I agree to the Terms of Service and Privacy Policy',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.grey700,
          ),
        ),
        subtitle: GestureDetector(
          onTap: () {
            setState(() {
              _agreeToTerms = !_agreeToTerms;
            });
          },
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.grey500,
              ),
              children: [
                const TextSpan(
                    text: 'By creating an account, you agree to our '),
                TextSpan(
                  text: 'Terms of Service',
                  style: GoogleFonts.poppins(
                    color: AppTheme.getPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: GoogleFonts.poppins(
                    color: AppTheme.getPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        value: _agreeToTerms,
        onChanged: (value) {
          setState(() {
            _agreeToTerms = value ?? false;
          });
        },
        activeColor: AppTheme.getPrimaryColor(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        dense: true,
      ),
    )
        .animate(delay: Duration(milliseconds: 800))
        .fadeIn(duration: AppTheme.mediumAnimation)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildRegisterButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: GradientButton(
            text: 'Create Account',
            onPressed: _agreeToTerms ? _handleRegister : null,
            isLoading: ref.watch(authNotifierProvider).isLoading,
            icon: Icon(
              Icons.person_add_outlined,
              color: Colors.white,
              size: 22,
            ),
            gradient: AppTheme.getNeonPrimaryGradient(
              direction: GradientDirection.topLeft,
            ),
            size: ButtonSize.large,
          ),
        )
            .animate(delay: Duration(milliseconds: 900))
            .fadeIn(duration: AppTheme.mediumAnimation)
            .slideY(begin: 0.3, end: 0)
            .scaleXY(begin: 0.95, end: 1.0),
        const SizedBox(height: 16),
        Text(
          'Secure registration with blockchain integration',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppTheme.success,
            fontWeight: FontWeight.w500,
          ),
        )
            .animate(delay: Duration(milliseconds: 1000))
            .fadeIn(duration: AppTheme.mediumAnimation),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.security, color: AppTheme.success, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Your account data is encrypted and secured',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTheme.grey500,
                ),
              ),
            ),
          ],
        )
            .animate(delay: Duration(milliseconds: 1100))
            .fadeIn(duration: AppTheme.mediumAnimation),
      ],
    );
  }

  Widget _buildSignInSection() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.grey500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        )
            .animate(delay: Duration(milliseconds: 1200))
            .fadeIn(duration: AppTheme.mediumAnimation),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.grey600),
            ),
            TextButton(
              onPressed: () {
                context.push('/login');
              },
              child: Text(
                'Sign In',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getPrimaryColor(context),
                ),
              ),
            ),
          ],
        )
            .animate(delay: Duration(milliseconds: 1300))
            .fadeIn(duration: AppTheme.mediumAnimation)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      ref.read(authNotifierProvider.notifier).register(
            email: _emailController.text.trim(),
            phone: _phoneNumberE164 ??
                (_phoneController.text.trim().isNotEmpty
                    ? _phoneController.text.trim()
                    : null),
            password: _passwordController.text,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            country: _selectedCountryIso,
          );
    }
  }
}
