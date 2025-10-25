import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../shared/presentation/widgets/custom_button.dart';
import '../../../shared/presentation/widgets/custom_text_field.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';
import '../../providers/animals_provider.dart';
import '../../data/models/animal_models.dart';

class AddAnimalScreen extends ConsumerStatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  ConsumerState<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends ConsumerState<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedSpecies;
  String? _selectedGender;
  final bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animalsState = ref.watch(myAnimalsProvider);
    final isDesktop = context.isDesktop;

    ref.listen(myAnimalsProvider, (previous, next) {
      if (next.hasValue &&
          previous?.isLoading != false &&
          next.isLoading == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Animal created successfully! NFT has been minted.'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.pop();
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: Text(
          'Add Animal',
          style: GoogleFonts.poppins(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey900,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.grey700),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          if (isDesktop)
            Container(
              margin: EdgeInsets.only(right: 16),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.security, color: AppTheme.success, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Blockchain Secured',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading || animalsState.isLoading,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: isDesktop ? 40 : 32),
              _buildImageSection(),
              SizedBox(height: isDesktop ? 32 : 24),
              _buildBasicInfoSection(),
              SizedBox(height: isDesktop ? 32 : 24),
              _buildDescriptionSection(),
              SizedBox(height: isDesktop ? 40 : 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDesktop = context.isDesktop;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              // Premium Card Logo
              PremiumCard(
                borderRadius: 30,
                gradient: AppTheme.getNeonPrimaryGradient(
                  direction: GradientDirection.topLeft,
                ),
                padding: EdgeInsets.all(isDesktop ? 24 : 20),
                hasElevation: true,
                customShadows: AppTheme.getPrimaryNeonGlow(isDark: false),
                child: Icon(
                  Icons.pets,
                  color: Colors.white,
                  size: isDesktop ? 48 : 40,
                ),
              ).animate(delay: Duration(milliseconds: 100)).scale(
                  duration: AppTheme.mediumAnimation,
                  begin: Offset(0.7, 0.7),
                  end: Offset(1.0, 1.0)),

              SizedBox(height: isDesktop ? 20 : 16),

              Text(
                'Create Animal NFT',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 32 : 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getPrimaryColor(context),
                ),
              )
                  .animate(delay: Duration(milliseconds: 200))
                  .fadeIn(duration: AppTheme.mediumAnimation)
                  .slideY(begin: 0.3, end: 0),

              SizedBox(height: isDesktop ? 12 : 8),

              Text(
                'Register your animal and create an NFT on the Hedera blockchain',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 18 : 16,
                  color: AppTheme.grey600,
                  height: 1.4,
                ),
              )
                  .animate(delay: Duration(milliseconds: 300))
                  .fadeIn(duration: AppTheme.mediumAnimation)
                  .slideY(begin: 0.3, end: 0),

              SizedBox(height: 16),

              // Features Pills
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildFeaturePill(
                      'Secure NFT', Icons.security, AppTheme.success),
                  _buildFeaturePill(
                      'Blockchain', Icons.hub_outlined, AppTheme.primaryColor),
                  _buildFeaturePill(
                      'Ownership', Icons.vpn_key, AppTheme.warning),
                ],
              )
                  .animate(delay: Duration(milliseconds: 400))
                  .fadeIn(duration: AppTheme.mediumAnimation)
                  .scaleXY(begin: 0.8, end: 1.0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturePill(String text, IconData icon, Color color) {
    final isDesktop = context.isDesktop;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 12 : 10,
        vertical: isDesktop ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isDesktop ? 14 : 12,
            color: color,
          ),
          SizedBox(width: isDesktop ? 6 : 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 12 : 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Animal Photo',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey900,
          ),
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: _selectImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.grey300,
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppTheme.primaryColor,
                    size: 30,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Tap to add photo',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.grey600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Recommended: High-quality image',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.grey500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        CustomTextField(
          controller: _nameController,
          label: 'Animal Name',
          hint: 'Enter animal name',
          prefixIcon: Icons.pets,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the animal name';
            }
            return null;
          },
        ),
        SizedBox(height: 16),

        // Species Dropdown
        DropdownButtonFormField<String>(
          initialValue: _selectedSpecies,
          decoration: InputDecoration(
            labelText: 'Species',
            hintText: 'Select species',
            prefixIcon: Icon(
              Icons.category,
              color: AppTheme.grey500,
              size: 20,
            ),
            filled: true,
            fillColor: AppTheme.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            labelStyle: GoogleFonts.poppins(
              color: AppTheme.grey700,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          items: AppConfig.animalSpecies.map((species) {
            return DropdownMenuItem(
              value: species,
              child: Text(
                species.toLowerCase().replaceFirst(
                      species[0],
                      species[0].toUpperCase(),
                    ),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppTheme.grey900,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSpecies = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a species';
            }
            return null;
          },
        ),

        SizedBox(height: 16),

        // Gender Dropdown
        DropdownButtonFormField<String>(
          initialValue: _selectedGender,
          decoration: InputDecoration(
            labelText: 'Gender',
            hintText: 'Select gender',
            prefixIcon: Icon(
              Icons.pets,
              color: AppTheme.grey500,
              size: 20,
            ),
            filled: true,
            fillColor: AppTheme.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            labelStyle: GoogleFonts.poppins(
              color: AppTheme.grey700,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          items: AppConfig.animalGenders.map((gender) {
            return DropdownMenuItem(
              value: gender,
              child: Text(
                gender.toLowerCase().replaceFirst(
                      gender[0],
                      gender[0].toUpperCase(),
                    ),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppTheme.grey900,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a gender';
            }
            return null;
          },
        ),

        SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _breedController,
                    label: 'Breed (Optional)',
                    hint: _getBreedHint(),
                    prefixIcon: Icons.info_outline,
                  ),
                  if (_selectedSpecies != null) ...[
                    SizedBox(height: 8),
                    Text(
                      'Popular breeds:',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.grey600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _getPopularBreedsForSpecies()
                          .map((breed) => GestureDetector(
                                onTap: () {
                                  _breedController.text = breed;
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme.primaryColor
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    breed,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _ageController,
                label: 'Age (Optional)',
                hint: 'Enter age',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.cake,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final age = int.tryParse(value);
                    if (age == null || age < 0 || age > 50) {
                      return 'Enter valid age (0-50)';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return CustomTextField(
      controller: _descriptionController,
      label: 'Description (Optional)',
      hint: 'Tell us about this animal...',
      maxLines: 4,
      prefixIcon: Icons.description,
      validator: (value) {
        if (value != null && value.length > 500) {
          return 'Description must be less than 500 characters';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your animal will be minted as an NFT on Hedera Hashgraph',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Register Animal & Mint NFT',
            onPressed: _handleSubmit,
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }

  void _selectImage() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Take Photo'),
              onTap: () {
                context.pop();
                // TODO: Implement camera functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                context.pop();
                // TODO: Implement gallery selection
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate() &&
        _selectedSpecies != null &&
        _selectedGender != null) {
      final createRequest = CreateAnimalRequest(
        name: _nameController.text.trim(),
        species: _selectedSpecies!,
        breed: _breedController.text.trim().isNotEmpty
            ? _breedController.text.trim()
            : null,
        age: _ageController.text.trim().isNotEmpty
            ? int.tryParse(_ageController.text.trim())
            : null,
        gender: _selectedGender!,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      ref.read(myAnimalsProvider.notifier).createAnimal(
            request: createRequest,
          );
    }
  }

  String _getBreedHint() {
    switch (_selectedSpecies) {
      case 'COW':
        return 'e.g. Holstein, Jersey, Angus';
      case 'GOAT':
        return 'e.g. Boer, Nubian, Alpine';
      case 'SHEEP':
        return 'e.g. Dorset, Suffolk, Merino';
      default:
        return 'Enter breed';
    }
  }

  List<String> _getPopularBreedsForSpecies() {
    switch (_selectedSpecies) {
      case 'COW':
        return [
          'Holstein Friesian',
          'Jersey',
          'Angus',
          'Hereford',
          'Simmental',
          'Charolais',
          'Limousin'
        ];
      case 'GOAT':
        return [
          'Boer',
          'Nubian',
          'Alpine',
          'Saanen',
          'Toggenburg',
          'LaMancha',
          'Nigora'
        ];
      case 'SHEEP':
        return [
          'Dorset',
          'Suffolk',
          'Merino',
          'Rambouillet',
          'Dorper',
          'Cheviot'
        ];
      default:
        return [];
    }
  }
}
