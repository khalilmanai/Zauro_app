import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? maxWidth;
  final bool centerContent;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.maxWidth,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Apply responsive constraints
    if (maxWidth != null || ResponsiveUtils.isDesktop(context)) {
      content = ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 1200,
        ),
        child: content,
      );
    }

    // Apply responsive padding
    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    } else {
      content = Padding(
        padding: ResponsiveUtils.responsivePadding(context),
        child: content,
      );
    }

    // Apply responsive margin
    if (margin != null) {
      content = Container(
        margin: margin,
        child: content,
      );
    }

    // Center content for larger screens
    if (centerContent && ResponsiveUtils.isDesktop(context)) {
      content = Center(child: content);
    }

    return content;
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? maxColumns;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final EdgeInsets? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.maxColumns,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      crossAxisCount: ResponsiveUtils.getGridColumns(
        context,
        maxColumns: maxColumns ?? 3,
      ),
      crossAxisSpacing: crossAxisSpacing ??
          ResponsiveUtils.responsive(
            context,
            mobile: 12.0,
            tablet: 16.0,
            desktop: 20.0,
          ),
      mainAxisSpacing: mainAxisSpacing ??
          ResponsiveUtils.responsive(
            context,
            mobile: 12.0,
            tablet: 16.0,
            desktop: 20.0,
          ),
      childAspectRatio: childAspectRatio ??
          ResponsiveUtils.responsive(
            context,
            mobile: 1.2,
            tablet: 1.1,
            desktop: 1.0,
          ),
      children: children,
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool wrapOnMobile;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.wrapOnMobile = true,
  });

  @override
  Widget build(BuildContext context) {
    if (wrapOnMobile && ResponsiveUtils.isMobile(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children
            .map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: child,
                ))
            .toList(),
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? ResponsiveUtils.responsiveMargin(context),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: elevation ?? ResponsiveUtils.getCardElevation(context),
          ),
        ],
      ),
      child: Padding(
        padding: padding ??
            ResponsiveUtils.responsive(
              context,
              mobile: const EdgeInsets.all(16),
              tablet: const EdgeInsets.all(20),
              desktop: const EdgeInsets.all(24),
            ),
        child: child,
      ),
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? scaleFactor;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle? finalStyle = style;

    if (finalStyle != null && scaleFactor != null) {
      final fontSize = finalStyle.fontSize ?? 14.0;
      finalStyle = finalStyle.copyWith(
        fontSize: ResponsiveUtils.responsiveFontSize(
          context,
          mobile: fontSize,
          tablet: fontSize * (scaleFactor! * 1.1),
          desktop: fontSize * (scaleFactor! * 1.2),
        ),
      );
    }

    return Text(
      text,
      style: finalStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// Extension for easier responsive spacing
extension ResponsiveSpacing on BuildContext {
  Widget get responsiveVerticalSpacing => SizedBox(
        height: responsive(
          mobile: 16.0,
          tablet: 20.0,
          desktop: 24.0,
        ),
      );

  Widget get responsiveHorizontalSpacing => SizedBox(
        width: responsive(
          mobile: 16.0,
          tablet: 20.0,
          desktop: 24.0,
        ),
      );

  EdgeInsets get responsiveCardPadding => EdgeInsets.all(
        responsive(
          mobile: 16.0,
          tablet: 20.0,
          desktop: 24.0,
        ),
      );

  EdgeInsets get responsiveScreenPadding => EdgeInsets.all(
        responsive(
          mobile: 16.0,
          tablet: 24.0,
          desktop: 32.0,
        ),
      );
}
