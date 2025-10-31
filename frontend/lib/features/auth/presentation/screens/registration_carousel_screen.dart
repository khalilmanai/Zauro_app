import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:country_picker/country_picker.dart';
import '../../../../core/services/location_service.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../shared/presentation/widgets/custom_button.dart';
import '../../../shared/presentation/widgets/custom_text_field.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';
import '../../data/models/auth_models.dart';
import '../../providers/auth_provider.dart';
import '../widgets/avatar_selection_widget.dart';

// Registration State Provider
final registrationStateProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  return RegistrationNotifier();
});

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  RegistrationNotifier() : super(const RegistrationState());

  void updateFirstName(String firstName) {
    state = state.copyWith(firstName: firstName);
  }

  void updateLastName(String lastName) {
    state = state.copyWith(lastName: lastName);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  void updateCountry(String? country) {
    state = state.copyWith(country: country);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword);
  }

  void selectAvatar(Avatar avatar) {
    state = state.copyWith(selectedAvatar: avatar);
  }

  void toggleTermsAgreement() {
    state = state.copyWith(agreeToTerms: !state.agreeToTerms);
  }

  void nextStep() {
    if (state.canProceedToNextStep) {
      final currentIndex = RegistrationStep.values.indexOf(state.currentStep);
      if (currentIndex < RegistrationStep.values.length - 1) {
        state = state.copyWith(
          currentStep: RegistrationStep.values[currentIndex + 1],
        );
      }
    }
  }

  void previousStep() {
    if (state.canGoToPreviousStep) {
      final currentIndex = RegistrationStep.values.indexOf(state.currentStep);
      if (currentIndex > 0) {
        state = state.copyWith(
          currentStep: RegistrationStep.values[currentIndex - 1],
        );
      }
    }
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void reset() {
    state = const RegistrationState();
  }
}

class RegistrationCarouselScreen extends ConsumerStatefulWidget {
  const RegistrationCarouselScreen({super.key});

  @override
  ConsumerState<RegistrationCarouselScreen> createState() =>
      _RegistrationCarouselScreenState();
}

class _RegistrationCarouselScreenState
    extends ConsumerState<RegistrationCarouselScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedCountryCode = 'US';
  final List<Map<String, String>> _countryList = [
    {'code': 'US', 'dial': '+1', 'name': 'United States', 'flag': '🇺🇸'},
    {'code': 'GB', 'dial': '+44', 'name': 'United Kingdom', 'flag': '🇬🇧'},
    {'code': 'CA', 'dial': '+1', 'name': 'Canada', 'flag': '🇨🇦'},
    {'code': 'AU', 'dial': '+61', 'name': 'Australia', 'flag': '🇦🇺'},
    {'code': 'IN', 'dial': '+91', 'name': 'India', 'flag': '🇮🇳'},
    {'code': 'DE', 'dial': '+49', 'name': 'Germany', 'flag': '🇩🇪'},
    {'code': 'FR', 'dial': '+33', 'name': 'France', 'flag': '🇫🇷'},
  ];
  String _phoneNumberE164 = '';
  PhoneNumber _initialPhone = PhoneNumber(isoCode: 'US');
  String? _selectedCountryIso;

  // Avatars from avatar-placeholder.iran.liara.run API
  final List<Avatar> _avatars = [
    const Avatar(
      id: '1',
      name: 'Professional #1',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/1',
      category: 'Professional',
    ),
    const Avatar(
      id: '2',
      name: 'Professional #2',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/2',
      category: 'Professional',
    ),
    const Avatar(
      id: '3',
      name: 'Professional #3',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/3',
      category: 'Professional',
    ),
    const Avatar(
      id: '4',
      name: 'Professional #4',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/4',
      category: 'Professional',
    ),
    const Avatar(
      id: '5',
      name: 'Professional #5',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/5',
      category: 'Professional',
    ),
    const Avatar(
      id: '6',
      name: 'Professional #6',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/6',
      category: 'Professional',
    ),
    const Avatar(
      id: '7',
      name: 'Professional #7',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/7',
      category: 'Professional',
    ),
    const Avatar(
      id: '8',
      name: 'Professional #8',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/8',
      category: 'Professional',
    ),
    const Avatar(
      id: '9',
      name: 'Professional #9',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/9',
      category: 'Professional',
    ),
    const Avatar(
      id: '10',
      name: 'Professional #10',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/10',
      category: 'Professional',
    ),
    const Avatar(
      id: '11',
      name: 'Professional #11',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/11',
      category: 'Professional',
    ),
    const Avatar(
      id: '12',
      name: 'Professional #12',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/12',
      category: 'Professional',
    ),
    const Avatar(
      id: '13',
      name: 'Professional #13',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/13',
      category: 'Professional',
    ),
    const Avatar(
      id: '14',
      name: 'Professional #14',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/14',
      category: 'Professional',
    ),
    const Avatar(
      id: '15',
      name: 'Professional #15',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/15',
      category: 'Professional',
    ),
    const Avatar(
      id: '16',
      name: 'Professional #16',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/16',
      category: 'Professional',
    ),
    const Avatar(
      id: '17',
      name: 'Professional #17',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/17',
      category: 'Professional',
    ),
    const Avatar(
      id: '18',
      name: 'Professional #18',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/18',
      category: 'Professional',
    ),
    const Avatar(
      id: '19',
      name: 'Professional #19',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/19',
      category: 'Professional',
    ),
    const Avatar(
      id: '20',
      name: 'Professional #20',
      imageUrl: 'https://avatar-placeholder.iran.liara.run/avatar/20',
      category: 'Professional',
    ),
  ];

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
    // On first build, try to set default country from device locale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localeCountry = Localizations.localeOf(context).countryCode;
      if (localeCountry != null && localeCountry.isNotEmpty) {
        final exists = _countryList.any((c) => c['code'] == localeCountry);
        if (exists) {
          _selectedCountryCode = localeCountry;
          ref
              .read(registrationStateProvider.notifier)
              .updateCountry(_selectedCountryCode);
        }
      }
    });
    final registrationState = ref.watch(registrationStateProvider);
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
      } else if (next.isAuthenticated) {
        context.go('/');
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: LoadingOverlay(
        isLoading: registrationState.isLoading || authState.isLoading,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(registrationState),
              Expanded(
                child: _buildStepContent(registrationState),
              ),
              _buildNavigation(registrationState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(RegistrationState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (state.canGoToPreviousStep) {
                    ref.read(registrationStateProvider.notifier).previousStep();
                  } else {
                    context.pop();
                  }
                },
                icon: const Icon(Icons.arrow_back_ios, color: AppTheme.grey700),
                iconSize: 20,
              ),
              Expanded(
                child: Text(
                  'Create Account',
                  style: GoogleFonts.poppins(
                    fontSize: MediaQuery.of(context).size.width < 380 ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.grey900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 40), // Balance the back button
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressIndicator(state),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(RegistrationState state) {
    final currentStepIndex = RegistrationStep.values.indexOf(state.currentStep);
    final totalSteps = RegistrationStep.values.length;

    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isActive = index <= currentStepIndex;

            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  right: index < totalSteps - 1 ? 6 : 0,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primaryColor : AppTheme.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'Step ${currentStepIndex + 1} of $totalSteps',
          style: GoogleFonts.poppins(
            fontSize: MediaQuery.of(context).size.width < 380 ? 11 : 12,
            color: AppTheme.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(RegistrationState state) {
    switch (state.currentStep) {
      case RegistrationStep.personalInfo:
        return _buildPersonalInfoStep(state);
      case RegistrationStep.avatarSelection:
        return _buildAvatarSelectionStep(state);
      case RegistrationStep.accountDetails:
        return _buildAccountDetailsStep(state);
      case RegistrationStep.termsAndConditions:
        return _buildTermsAndConditionsStep(state);
    }
  }

  Widget _buildPersonalInfoStep(RegistrationState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: GoogleFonts.poppins(
                fontSize: MediaQuery.of(context).size.width < 380 ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.grey900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us about yourself',
              style: GoogleFonts.poppins(
                fontSize: MediaQuery.of(context).size.width < 380 ? 14 : 16,
                color: AppTheme.grey600,
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                CustomTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  hint: 'Enter first name',
                  prefixIcon: Icons.person_outlined,
                  onChanged: (value) {
                    ref
                        .read(registrationStateProvider.notifier)
                        .updateFirstName(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  hint: 'Enter last name',
                  prefixIcon: Icons.person_outlined,
                  onChanged: (value) {
                    ref
                        .read(registrationStateProvider.notifier)
                        .updateLastName(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Country selection
            Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.grey300),
              ),
              child: ListTile(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: true,
                    searchAutofocus: true,
                    onSelect: (Country country) {
                      setState(() {
                        _selectedCountryIso = country.countryCode;
                        _initialPhone = PhoneNumber(
                          isoCode: country.countryCode,
                          phoneNumber: _phoneController.text,
                        );
                      });
                      ref
                          .read(registrationStateProvider.notifier)
                          .updateCountry(country.countryCode);
                    },
                  );
                },
                title: Text(
                  'Select Country',
                  style: TextStyle(
                    color: AppTheme.grey600,
                    fontSize: 16,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final countryCode = _selectedCountryIso ??
                            ref.watch(currentCountryProvider).value;
                        return Text(
                          countryCode ?? 'Select',
                          style: TextStyle(
                            color: AppTheme.grey900,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 16, color: AppTheme.grey600),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                _phoneNumberE164 = number.phoneNumber ?? '';
                _selectedCountryIso = number.isoCode;
                // update registration state with formatted value and country ISO
                ref
                    .read(registrationStateProvider.notifier)
                    .updatePhone(number.phoneNumber ?? '');
              },
              onInputValidated: (bool value) {
                // no-op for now
              },
              selectorConfig: const SelectorConfig(
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.grey300),
                ),
              ),
              selectorTextStyle: TextStyle(color: AppTheme.grey700),
              formatInput: true,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSelectionStep(RegistrationState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Expanded(
            child: AvatarSelectionWidget(
              selectedAvatar: state.selectedAvatar,
              onAvatarSelected: (avatar) {
                ref
                    .read(registrationStateProvider.notifier)
                    .selectAvatar(avatar);
              },
              avatars: _avatars,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsStep(RegistrationState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Details',
              style: GoogleFonts.poppins(
                fontSize: MediaQuery.of(context).size.width < 380 ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.grey900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your account credentials',
              style: GoogleFonts.poppins(
                fontSize: MediaQuery.of(context).size.width < 380 ? 14 : 16,
                color: AppTheme.grey600,
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'Enter email address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                ref.read(registrationStateProvider.notifier).updateEmail(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter password',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscurePassword,
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
              onChanged: (value) {
                ref
                    .read(registrationStateProvider.notifier)
                    .updatePassword(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
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
              label: 'Confirm Password',
              hint: 'Confirm your password',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscureConfirmPassword,
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
              onChanged: (value) {
                ref
                    .read(registrationStateProvider.notifier)
                    .updateConfirmPassword(value);
              },
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
          ],
        ),
      ),
    );
  }

  Widget _buildTermsAndConditionsStep(RegistrationState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms & Conditions',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.grey900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review and accept our terms',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppTheme.grey600,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.grey50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.grey200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terms of Service',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.grey900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'By creating an account, you agree to our Terms of Service and Privacy Policy. You understand that:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.grey700,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTermItem(
                    'You are responsible for the security of your account'),
                _buildTermItem(
                    'All transactions are final and cannot be reversed'),
                _buildTermItem(
                    'You must comply with all applicable laws and regulations'),
                _buildTermItem('We may update these terms at any time'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: state.agreeToTerms,
                onChanged: (value) {
                  ref
                      .read(registrationStateProvider.notifier)
                      .toggleTermsAgreement();
                },
                activeColor: AppTheme.primaryColor,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(registrationStateProvider.notifier)
                        .toggleTermsAgreement();
                  },
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.grey700,
                      ),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.grey700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(RegistrationState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          if (state.canGoToPreviousStep)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ref.read(registrationStateProvider.notifier).previousStep();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: GoogleFonts.poppins(
                    fontSize: MediaQuery.of(context).size.width < 380 ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (state.canGoToPreviousStep)
            SizedBox(width: MediaQuery.of(context).size.width < 380 ? 12 : 16),
          Expanded(
            child: CustomButton(
              text: state.currentStep == RegistrationStep.termsAndConditions
                  ? 'Create Account'
                  : 'Continue',
              onPressed: state.canProceedToNextStep ? _handleNext : null,
              isLoading: state.isLoading,
              height: MediaQuery.of(context).size.width < 380 ? 48 : 56,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    final state = ref.read(registrationStateProvider);

    // Validate current step before proceeding
    if (!_validateCurrentStep()) {
      return;
    }

    if (state.currentStep == RegistrationStep.termsAndConditions) {
      _handleRegister();
    } else {
      ref.read(registrationStateProvider.notifier).nextStep();
    }
  }

  bool _validateCurrentStep() {
    final state = ref.read(registrationStateProvider);

    switch (state.currentStep) {
      case RegistrationStep.personalInfo:
        if (_formKey.currentState?.validate() != true) {
          return false;
        }
        break;
      case RegistrationStep.avatarSelection:
        if (state.selectedAvatar == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please select an avatar'),
              backgroundColor: AppTheme.error,
            ),
          );
          return false;
        }
        break;
      case RegistrationStep.accountDetails:
        if (_formKey.currentState?.validate() != true) {
          return false;
        }
        break;
      case RegistrationStep.termsAndConditions:
        if (!state.agreeToTerms) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please agree to the terms and conditions'),
              backgroundColor: AppTheme.error,
            ),
          );
          return false;
        }
        break;
    }

    return true;
  }

  void _handleRegister() {
    final state = ref.read(registrationStateProvider);

    if (state.agreeToTerms) {
      // Additional validation before registration
      if (state.email == null || state.email!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter your email address'),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }

      if (state.password == null || state.password!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter your password'),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }

      if (state.firstName == null || state.firstName!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter your first name'),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }

      if (state.lastName == null || state.lastName!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter your last name'),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }

      ref.read(authNotifierProvider.notifier).register(
            email: state.email!,
            // state.phone is stored as E.164 by the phone input widget
            phone: state.phone?.isNotEmpty == true ? state.phone : null,
            password: state.password!,
            firstName: state.firstName!,
            lastName: state.lastName!,
            // Prefer the state.country (ISO) set by the phone input; fall back to selected country ISO or legacy code
            country:
                state.country ?? _selectedCountryIso ?? _selectedCountryCode,
          );
    }
  }
}
