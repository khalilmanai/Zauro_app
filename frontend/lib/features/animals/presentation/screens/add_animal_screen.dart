import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/network/api_client.dart';
import '../../../shared/presentation/widgets/custom_button.dart';
import '../../../shared/presentation/widgets/custom_text_field.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';
import '../../providers/animals_provider.dart';
import '../../data/models/animal_models.dart';
import 'package:dio/dio.dart';

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
  File? _selectedImage;
  File? _selectedVetRecord;
  double? _aiPredictionValue;
  bool _isPredicting = false;
  final ImagePicker _imagePicker = ImagePicker();

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
            content: const Text(
              'Animal posted successfully! It is now pending expert review. You will be notified once it\'s approved.',
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
        // Navigate to My Animals screen
        context.go('/animals');
      }
      if (next.hasError) {
        final errorMessage = next.error
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('ServerFailure: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.grey50,
      resizeToAvoidBottomInset: true,
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
        isLoading: animalsState.isLoading,
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
              SizedBox(height: isDesktop ? 32 : 24),
              _buildVetRecordSection(),
              if (_aiPredictionValue != null) ...[
                SizedBox(height: isDesktop ? 32 : 24),
                _buildAIPredictionCard(),
              ],
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
              ),

              SizedBox(height: isDesktop ? 20 : 16),

              Text(
                'Create Animal NFT',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 32 : 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getPrimaryColor(context),
                ),
              ),

              SizedBox(height: isDesktop ? 12 : 8),

              Text(
                'Register your animal and create an NFT on the Hedera blockchain',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 18 : 16,
                  color: AppTheme.grey600,
                  height: 1.4,
                ),
              ),

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
              ),
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
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
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
            _tryPredictAI();
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a species';
            }
            return null;
          },
        ),

        SizedBox(height: 16),

        // Gender Radio Buttons
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gender',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.grey700,
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedGender != null
                      ? AppTheme.primaryColor
                      : AppTheme.grey300,
                  width: _selectedGender != null ? 2 : 1,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'MALE',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                          _tryPredictAI();
                        });
                      },
                      title: Text(
                        'Male',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppTheme.grey900,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'FEMALE',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                          _tryPredictAI();
                        });
                      },
                      title: Text(
                        'Female',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppTheme.grey900,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ),
            if (_formKey.currentState?.validate() == false &&
                _selectedGender == null)
              Padding(
                padding: EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  'Please select a gender',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.error,
                  ),
                ),
              ),
          ],
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

  Widget _buildVetRecordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vet Record (Optional)',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey900,
          ),
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: _selectVetRecord,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedVetRecord != null
                  ? AppTheme.success.withValues(alpha: 0.1)
                  : AppTheme.grey100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedVetRecord != null
                    ? AppTheme.success
                    : AppTheme.grey300,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _selectedVetRecord != null
                      ? Icons.description
                      : Icons.upload_file,
                  color: _selectedVetRecord != null
                      ? AppTheme.success
                      : AppTheme.grey600,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedVetRecord != null
                            ? _selectedVetRecord!.path.split('/').last
                            : 'Tap to upload vet record',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _selectedVetRecord != null
                              ? AppTheme.success
                              : AppTheme.grey700,
                        ),
                      ),
                      if (_selectedVetRecord == null)
                        Text(
                          'PDF or document file',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.grey500,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_selectedVetRecord != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedVetRecord = null;
                      });
                    },
                    icon: Icon(Icons.close, color: AppTheme.error),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAIPredictionCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Predicted Value',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.grey600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${_aiPredictionValue!.toStringAsFixed(2)} HBAR',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          if (_isPredicting)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ),
        ],
      ),
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
                  'Your animal will be reviewed by an expert before NFT minting',
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
          child: Consumer(
            builder: (context, ref, _) {
              final isLoading = ref.watch(myAnimalsProvider).isLoading;
              return CustomButton(
                text: 'Post Animal',
                onPressed: isLoading ? null : _handleSubmit,
                isLoading: isLoading,
              );
            },
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
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        _tryPredictAI();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to take photo: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        _tryPredictAI();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _selectVetRecord() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Upload Document'),
              onTap: () {
                Navigator.pop(context);
                _pickVetRecord();
              },
            ),
            if (_selectedVetRecord != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.error),
                title: const Text('Remove Document'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedVetRecord = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVetRecord() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      // For PDF, we'd typically use file_picker, but for now allow image selection
      // In production, use file_picker package for PDF support
      if (pickedFile != null) {
        setState(() {
          _selectedVetRecord = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick file: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _tryPredictAI() async {
    // Only predict if both species and image are available
    if (_selectedSpecies == null || _selectedImage == null) {
      return;
    }

    setState(() {
      _isPredicting = true;
    });

    try {
      // Call AI prediction endpoint
      // Note: This endpoint might need to be added to the API client
      // For now, we'll use a mock or skip if endpoint doesn't exist
      final dio = ref.read(dioProvider);
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: _selectedImage!.path.split('/').last,
        ),
        'species': _selectedSpecies,
        if (_selectedGender != null) 'gender': _selectedGender,
      });

      try {
        final response = await dio.post(
          '/ai/predict',
          data: formData,
          options: Options(
            headers: {
              'Content-Type': 'multipart/form-data',
            },
          ),
        );

        if (response.statusCode == 200 && mounted) {
          final data = response.data;
          final predictedPrice = data['predicted_market_price'] ??
              data['market_price'] ??
              data['price'];

          if (predictedPrice != null) {
            setState(() {
              _aiPredictionValue = (predictedPrice is num)
                  ? predictedPrice.toDouble()
                  : double.tryParse(predictedPrice.toString());
            });
          }
        }
      } catch (e) {
        // AI endpoint might not be available, silently fail
        debugPrint('AI prediction not available: $e');
      }
    } catch (e) {
      debugPrint('Error predicting AI value: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPredicting = false;
        });
      }
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSpecies == null || _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields.'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    try {
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

      // Create animal with AI prediction value if available
      final finalRequest = CreateAnimalRequest(
        name: createRequest.name,
        species: createRequest.species,
        breed: createRequest.breed,
        age: createRequest.age,
        gender: createRequest.gender,
        description: createRequest.description,
        aiPredictionValue: _aiPredictionValue,
      );

      // Create animal - the provider will handle loading state
      await ref.read(myAnimalsProvider.notifier).createAnimal(
            request: finalRequest,
            imageFile: _selectedImage,
            vetRecordFile: _selectedVetRecord,
          );
    } catch (e) {
      // Error is already handled by the listener above
      debugPrint('Error creating animal: $e');
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
