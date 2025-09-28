import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../shared/presentation/widgets/custom_button.dart';
import '../../../shared/presentation/widgets/custom_text_field.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _useEmail = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordResetState = ref.watch(passwordResetNotifierProvider);

    ref.listen<PasswordResetState>(passwordResetNotifierProvider, (
      previous,
      next,
    ) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        ref.read(passwordResetNotifierProvider.notifier).clearError();
      } else if (next.isPasswordReset) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message!),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.go('/login');
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: LoadingOverlay(
        isLoading: passwordResetState.isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildBackButton(),
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildContent(passwordResetState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      onPressed: () => context.pop(),
      icon: const Icon(Icons.arrow_back_ios, color: AppTheme.grey700),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reset Password',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.grey900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email or phone number to reset your password',
          style: GoogleFonts.poppins(fontSize: 16, color: AppTheme.grey600),
        ),
      ],
    );
  }

  Widget _buildContent(PasswordResetState state) {
    if (state.isPasswordReset) {
      return _buildSuccessMessage();
    } else if (state.isOtpVerified) {
      return _buildResetPasswordForm();
    } else if (state.isOtpSent) {
      return _buildOtpVerificationForm();
    } else {
      return _buildRequestForm();
    }
  }

  Widget _buildRequestForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email/Phone Toggle
          Container(
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _useEmail = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _useEmail
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Email',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                _useEmail ? AppTheme.white : AppTheme.grey600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _useEmail = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_useEmail
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Phone',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                !_useEmail ? AppTheme.white : AppTheme.grey600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Input Field
          if (_useEmail)
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
          else
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Send Reset Code',
              onPressed: _handleSendCode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpVerificationForm() {
    return Column(
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 24),
        Text(
          'Check your ${_useEmail ? 'email' : 'phone'}',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a verification code to ${_useEmail ? _emailController.text : _phoneController.text}',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 16, color: AppTheme.grey600),
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: _otpController,
          label: 'Verification Code',
          hint: 'Enter 6-digit code',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.security,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the verification code';
            }
            if (value.length != 6) {
              return 'Code must be 6 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: CustomButton(text: 'Verify Code', onPressed: _handleVerifyOtp),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _handleResendCode,
          child: Text(
            'Resend Code',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordForm() {
    return Column(
      children: [
        CustomTextField(
          controller: _passwordController,
          label: 'New Password',
          hint: 'Enter new password',
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
              return 'Please enter your new password';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _confirmPasswordController,
          label: 'Confirm New Password',
          hint: 'Confirm your new password',
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
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Reset Password',
            onPressed: _handleResetPassword,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 80,
          color: AppTheme.successColor,
        ),
        const SizedBox(height: 24),
        Text(
          'Password Reset Successful!',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your password has been successfully reset. You can now sign in with your new password.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 16, color: AppTheme.grey600),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Back to Sign In',
            onPressed: () => context.go('/login'),
          ),
        ),
      ],
    );
  }

  void _handleSendCode() {
    if (_formKey.currentState!.validate()) {
      ref.read(passwordResetNotifierProvider.notifier).requestPasswordReset(
            email: _useEmail ? _emailController.text.trim() : null,
            phone: !_useEmail ? _phoneController.text.trim() : null,
          );
    }
  }

  void _handleVerifyOtp() {
    if (_otpController.text.length == 6) {
      ref.read(passwordResetNotifierProvider.notifier).verifyOtp(
            code: _otpController.text,
            email: _useEmail ? _emailController.text.trim() : null,
            phone: !_useEmail ? _phoneController.text.trim() : null,
          );
    }
  }

  void _handleResetPassword() {
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text) {
      ref.read(passwordResetNotifierProvider.notifier).resetPassword(
            code: _otpController.text,
            newPassword: _passwordController.text,
            email: _useEmail ? _emailController.text.trim() : null,
            phone: !_useEmail ? _phoneController.text.trim() : null,
          );
    }
  }

  void _handleResendCode() {
    ref.read(passwordResetNotifierProvider.notifier).requestPasswordReset(
          email: _useEmail ? _emailController.text.trim() : null,
          phone: !_useEmail ? _phoneController.text.trim() : null,
        );
  }
}
