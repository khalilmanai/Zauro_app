import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../shared/presentation/widgets/custom_button.dart';
import '../../../shared/presentation/widgets/custom_text_field.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';
import '../../providers/animals_provider.dart';
import '../../data/models/animal_models.dart';
import '../../../auth/providers/auth_provider.dart';

class EditAnimalScreen extends ConsumerStatefulWidget {
  final String animalId;

  const EditAnimalScreen({super.key, required this.animalId});

  @override
  ConsumerState<EditAnimalScreen> createState() => _EditAnimalScreenState();
}

class _EditAnimalScreenState extends ConsumerState<EditAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _breedController;
  late final TextEditingController _ageController;
  late final TextEditingController _descriptionController;

  String? _selectedSpecies;
  String? _selectedGender;
  bool _isLoading = false;
  Animal? _animal;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _breedController = TextEditingController();
    _ageController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadAnimal();
  }

  void _loadAnimal() {
    Future.microtask(() async {
      final animalState = ref.read(animalProvider(widget.animalId));
      if (animalState.hasValue && animalState.value != null) {
        setState(() {
          _animal = animalState.value;
          _populateForm(_animal!);
        });
      } else {
        await ref.read(animalProvider(widget.animalId).notifier).getAnimal();
        final updatedState = ref.read(animalProvider(widget.animalId));
        if (updatedState.hasValue && updatedState.value != null) {
          setState(() {
            _animal = updatedState.value;
            _populateForm(_animal!);
          });
        }
      }
    });
  }

  void _populateForm(Animal animal) {
    _nameController.text = animal.name;
    _breedController.text = animal.breed ?? '';
    _ageController.text = animal.age?.toString() ?? '';
    _descriptionController.text = animal.description ?? '';
    _selectedSpecies = animal.species;
    _selectedGender = animal.gender;
  }

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
    final animalState = ref.watch(animalProvider(widget.animalId));
    final auth = ref.watch(authNotifierProvider);
    final isDesktop = context.isDesktop;

    // Check if animal can be edited
    if (_animal != null) {
      final isOwner = auth.user?.id == _animal!.ownerId;
      final canEdit = isOwner &&
          _animal!.reviewStatus == AnimalStatus.pendingExpertReview;

      if (!canEdit) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Edit Animal',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios),
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cannot Edit Animal',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _animal!.reviewStatus == AnimalStatus.expertApproved
                        ? 'This animal has already been approved and cannot be edited. Please create a new animal if you need to make changes.'
                        : 'Only animals pending review can be edited.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: AppTheme.grey600),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    ref.listen(animalProvider(widget.animalId), (previous, next) {
      if (next.hasValue &&
          previous?.isLoading == true &&
          next.isLoading == false &&
          next.value != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Animal updated successfully'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: Text(
          'Edit Animal',
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
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading || animalState.isLoading,
        child: animalState.when(
          data: (animal) {
            if (animal == null) {
              return Center(
                child: Text(
                  'Animal not found',
                  style: GoogleFonts.poppins(),
                ),
              );
            }
            _animal = animal;
            if (_nameController.text.isEmpty) {
              _populateForm(animal);
            }
            return SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 32 : 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(animal),
                    SizedBox(height: 24),
                    _buildBasicInfoSection(),
                    SizedBox(height: 24),
                    _buildDescriptionSection(),
                    SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'Error loading animal: $error',
              style: GoogleFonts.poppins(color: AppTheme.errorColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(Animal animal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This animal is pending expert review. You can edit its details until it\'s reviewed.',
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

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey900,
          ),
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedSpecies,
          decoration: InputDecoration(
            labelText: 'Species',
            hintText: 'Select species',
            prefixIcon: Icon(Icons.category, color: AppTheme.grey500, size: 20),
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
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
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
                style: GoogleFonts.poppins(fontSize: 16, color: AppTheme.grey900),
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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _breedController,
                label: 'Breed',
                hint: 'Enter breed',
                prefixIcon: Icons.category,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _ageController,
                label: 'Age (years)',
                hint: 'Enter age',
                prefixIcon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final age = int.tryParse(value);
                    if (age == null || age < 0) {
                      return 'Please enter a valid age';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: InputDecoration(
            labelText: 'Gender',
            hintText: 'Select gender',
            prefixIcon: Icon(Icons.pets, color: AppTheme.grey500, size: 20),
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
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
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
                style: GoogleFonts.poppins(fontSize: 16, color: AppTheme.grey900),
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
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey900,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Enter description (optional)',
          prefixIcon: Icons.description,
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Update Animal',
        onPressed: _isLoading ? null : _handleSubmit,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = UpdateAnimalRequest(
        name: _nameController.text.trim(),
        species: _selectedSpecies,
        breed: _breedController.text.trim().isEmpty
            ? null
            : _breedController.text.trim(),
        age: _ageController.text.trim().isEmpty
            ? null
            : int.tryParse(_ageController.text.trim()),
        gender: _selectedGender,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      await ref.read(animalProvider(widget.animalId).notifier).updateAnimal(request);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update animal: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

