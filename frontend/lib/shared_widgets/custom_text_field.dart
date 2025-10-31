import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? label;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.label,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.fillColor,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine device type
    final isDesktop = screenWidth >= 1200;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    // Responsive font sizes
    final fontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : 14.0);
    final labelFontSize = isDesktop ? 14.0 : (isTablet ? 13.0 : 12.0);
    final iconSize = isDesktop ? 24.0 : (isTablet ? 22.0 : 20.0);

    // Responsive border radius
    final borderRadius = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);

    // Responsive padding
    final horizontalPadding = isDesktop ? 20.0 : (isTablet ? 18.0 : 16.0);
    final verticalPadding = isDesktop ? 18.0 : (isTablet ? 16.0 : 14.0);
    final defaultContentPadding = contentPadding ??
        EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        );

    // Responsive spacing
    final labelSpacing = isDesktop ? 12.0 : (isTablet ? 10.0 : 8.0);

    // Get theme colors
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outline;
    final focusedBorderColor = theme.colorScheme.primary;
    final errorColor = theme.colorScheme.error;
    final hintColor = theme.colorScheme.onSurfaceVariant;
    final textColor = theme.colorScheme.onSurface;
    final backgroundColor = fillColor ?? theme.colorScheme.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.poppins(
              fontSize: labelFontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: labelSpacing),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: enabled ? textColor : hintColor,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: hintColor.withOpacity(0.6),
            ),
            filled: true,
            fillColor: backgroundColor,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: iconSize,
                    color: hintColor,
                  )
                : null,
            suffixIcon: suffixIcon,
            contentPadding: defaultContentPadding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: borderColor,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: borderColor,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: focusedBorderColor,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: errorColor,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: errorColor,
                width: 2.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: borderColor.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            errorStyle: GoogleFonts.poppins(
              fontSize: labelFontSize,
              fontWeight: FontWeight.w500,
              color: errorColor,
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }
}
