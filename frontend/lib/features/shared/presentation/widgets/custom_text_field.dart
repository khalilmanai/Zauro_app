import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? initialValue;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onSubmitted;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.initialValue,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.focusNode,
    this.fillColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate responsive sizes based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    double fontSize = 16.0;
    double iconSize = 20.0;
    double borderRadius = 12.0;
    EdgeInsetsGeometry defaultPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16);

    if (screenWidth >= 1200) {
      // Large desktop
      fontSize = 20.0;
      iconSize = 28.0;
      borderRadius = 20.0;
      defaultPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    } else if (screenWidth >= 768) {
      // Tablet
      fontSize = 18.0;
      iconSize = 24.0;
      borderRadius = 16.0;
      defaultPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18);
    } else if (screenWidth >= 600) {
      // Small tablet
      fontSize = 17.0;
      iconSize = 22.0;
      borderRadius = 14.0;
      defaultPadding = const EdgeInsets.symmetric(horizontal: 18, vertical: 17);
    }

    // Ensure the label text doesn't overflow
    Widget labelWidget = const SizedBox.shrink();
    if (label != null) {
      labelWidget = Container(
        width: double.infinity, // Ensure it takes full width
        child: Text(
          label!,
          style: GoogleFonts.poppins(
            fontSize: fontSize * 0.875, // Slightly smaller than input text
            fontWeight: FontWeight.w500,
            color: AppTheme.grey700,
          ),
          overflow: TextOverflow.ellipsis, // Handle overflow
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Prevent infinite height
      children: [
        if (label != null) ...[
          labelWidget,
          SizedBox(height: fontSize * 0.5), // Responsive spacing
        ],
        // Wrap TextFormField in Container to control width and prevent overflow
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 48, // Minimum touch target
          ),
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            obscureText: obscureText,
            enabled: enabled,
            readOnly: readOnly,
            maxLines: maxLines,
            minLines: minLines,
            maxLength: maxLength,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            validator: validator,
            onChanged: onChanged,
            onTap: onTap,
            onFieldSubmitted: onSubmitted,
            inputFormatters: inputFormatters,
            focusNode: focusNode,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              color: AppTheme.grey900,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: fontSize,
                color: AppTheme.grey500,
              ),
              filled: true,
              fillColor: fillColor ?? AppTheme.white,
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: AppTheme.grey500,
                      size: iconSize,
                    )
                  : null,
              suffixIcon: suffixIcon,
              contentPadding: contentPadding ?? defaultPadding,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: AppTheme.grey300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: AppTheme.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: AppTheme.errorColor),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: AppTheme.errorColor,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: AppTheme.grey200),
              ),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }
}

class CustomSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final void Function(String)? onChanged;
  final void Function()? onClear;
  final bool showClearButton;

  const CustomSearchField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onClear,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate responsive sizes
    final screenWidth = MediaQuery.of(context).size.width;
    double fontSize = 16.0;
    double iconSize = 20.0;
    double borderRadius = 12.0;
    EdgeInsetsGeometry defaultPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16);

    if (screenWidth >= 1200) {
      fontSize = 20.0;
      iconSize = 28.0;
      borderRadius = 20.0;
      defaultPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    } else if (screenWidth >= 768) {
      fontSize = 18.0;
      iconSize = 24.0;
      borderRadius = 16.0;
      defaultPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18);
    } else if (screenWidth >= 600) {
      fontSize = 17.0;
      iconSize = 22.0;
      borderRadius = 14.0;
      defaultPadding = const EdgeInsets.symmetric(horizontal: 18, vertical: 17);
    }

    return Container(
      width: double.infinity, // Ensure full width
      constraints: const BoxConstraints(
        minHeight: 48, // Minimum touch target
      ),
      decoration: BoxDecoration(
        color: AppTheme.grey100,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          color: AppTheme.grey900,
        ),
        decoration: InputDecoration(
          hintText: hint ?? 'Search...',
          hintStyle: GoogleFonts.poppins(
            fontSize: fontSize,
            color: AppTheme.grey500,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.grey500,
            size: iconSize,
          ),
          suffixIcon: showClearButton &&
                  controller != null &&
                  controller!.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller!.clear();
                    if (onClear != null) onClear!();
                    if (onChanged != null) onChanged!('');
                  },
                  icon: Icon(
                    Icons.clear,
                    color: AppTheme.grey500,
                    size: iconSize,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: defaultPadding,
        ),
      ),
    );
  }
}

class CustomDropdownField<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;

  const CustomDropdownField({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate responsive sizes
    final screenWidth = MediaQuery.of(context).size.width;
    double fontSize = 16.0;
    double iconSize = 20.0;
    double borderRadius = 12.0;
    EdgeInsetsGeometry defaultPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16);

    if (screenWidth >= 1200) {
      fontSize = 20.0;
      iconSize = 28.0;
      borderRadius = 20.0;
      defaultPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    } else if (screenWidth >= 768) {
      fontSize = 18.0;
      iconSize = 24.0;
      borderRadius = 16.0;
      defaultPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18);
    } else if (screenWidth >= 600) {
      fontSize = 17.0;
      iconSize = 22.0;
      borderRadius = 14.0;
      defaultPadding = const EdgeInsets.symmetric(horizontal: 18, vertical: 17);
    }

    Widget labelWidget = const SizedBox.shrink();
    if (label != null) {
      labelWidget = Container(
        width: double.infinity, // Ensure it takes full width
        child: Text(
          label!,
          style: GoogleFonts.poppins(
            fontSize: fontSize * 0.875,
            fontWeight: FontWeight.w500,
            color: AppTheme.grey700,
          ),
          overflow: TextOverflow.ellipsis, // Handle overflow
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Prevent infinite height
      children: [
        if (label != null) ...[
          labelWidget,
          SizedBox(height: fontSize * 0.5), // Responsive spacing
        ],
        // Wrap DropdownButtonFormField in Container to control width
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 48, // Minimum touch target
          ),
          child: DropdownButtonFormField<T>(
            initialValue: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              color: AppTheme.grey900,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: fontSize,
                color: AppTheme.grey500,
              ),
              filled: true,
              fillColor: AppTheme.white,
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: AppTheme.grey500,
                      size: iconSize,
                    )
                  : null,
              contentPadding: defaultPadding,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: AppTheme.grey300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: AppTheme.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: AppTheme.errorColor),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: AppTheme.errorColor,
                  width: 2,
                ),
              ),
            ),
            dropdownColor: AppTheme.white,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.grey500,
              size: iconSize,
            ),
          ),
        ),
      ],
    );
  }
}
