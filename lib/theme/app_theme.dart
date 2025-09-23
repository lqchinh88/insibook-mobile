import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.brandPrimary,
      secondary: AppColors.brandSecondary,
      tertiary: AppColors.brandAccent,
      surface: AppColors.lightSurface,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onTertiary: AppColors.white,
      onSurface: AppColors.lightTextPrimary,
      onError: AppColors.white,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.grey300,
      shadow: AppColors.lightShadow,
      scrim: AppColors.lightShadow,
      inverseSurface: AppColors.grey800,
      onInverseSurface: AppColors.white,
      inversePrimary: AppColors.brandLight,
      surfaceTint: AppColors.brandPrimary,
    ),
    fontFamily: AppTextStyles.fontFamily,
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCard,
    dividerColor: AppColors.lightDivider,
    focusColor: AppColors.brandPrimary.withValues(alpha: 0.12),
    hoverColor: AppColors.brandPrimary.withValues(alpha: 0.08),
    highlightColor: AppColors.brandPrimary.withValues(alpha: 0.12),
    splashColor: AppColors.brandPrimary.withValues(alpha: 0.16),
    unselectedWidgetColor: AppColors.grey400,
    disabledColor: AppColors.grey300,
    secondaryHeaderColor: AppColors.grey50,
    hintColor: AppColors.grey400,
                brightness: Brightness.light,
    primaryColor: AppColors.brandPrimary,
    primaryColorLight: AppColors.brandLight,
    primaryColorDark: AppColors.brandDark,
    canvasColor: AppColors.lightBackground,
    shadowColor: AppColors.lightShadow,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: AppColors.brandPrimary,
      shadowColor: AppColors.lightShadow,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
      ),
      toolbarTextStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightCard,
      elevation: 2,
      shadowColor: AppColors.lightShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: AppColors.white,
        elevation: 2,
        shadowColor: AppColors.lightShadow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: AppTextStyles.labelMedium,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.brandPrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: AppTextStyles.labelMedium,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.brandPrimary,
        backgroundColor: AppColors.transparent,
        side: const BorderSide(color: AppColors.brandPrimary, width: 1),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: AppTextStyles.labelMedium,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.grey300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.grey300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.brandPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.grey300.withValues(alpha: 0.5)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: AppTextStyles.bodyMedium.withColor(AppColors.grey400),
      labelStyle: AppTextStyles.labelMedium.withColor(AppColors.grey600),
      errorStyle: AppTextStyles.bodySmall.withColor(AppColors.error),
      helperStyle: AppTextStyles.bodySmall.withColor(AppColors.grey500),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    ),
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.headlineLarge,
      displayMedium: AppTextStyles.headlineMedium,
      displaySmall: AppTextStyles.headlineSmall,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
      space: 1,
      indent: 0,
      endIndent: 0,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.grey300;
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.brandPrimary;
        }
        return AppColors.grey300;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.grey200;
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.brandPrimary.withValues(alpha: 0.5);
        }
        return AppColors.grey200;
      }),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.grey300;
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.brandPrimary;
        }
        return AppColors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.white),
      overlayColor: WidgetStateProperty.all(AppColors.brandPrimary.withValues(alpha: 0.12)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      side: const BorderSide(
        color: AppColors.grey400,
        width: 2,
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.grey300;
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.brandPrimary;
        }
        return AppColors.transparent;
      }),
      overlayColor: WidgetStateProperty.all(AppColors.brandPrimary.withValues(alpha: 0.12)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.brandPrimary,
      inactiveTrackColor: AppColors.grey300,
      thumbColor: AppColors.brandPrimary,
      overlayColor: AppColors.brandPrimary.withValues(alpha: 0.12),
      valueIndicatorColor: AppColors.brandPrimary,
      valueIndicatorTextStyle: AppTextStyles.labelSmall.withColor(AppColors.white),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      trackShape: const RoundedRectSliderTrackShape(),
      valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
      showValueIndicator: ShowValueIndicator.onlyForDiscrete,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.brandPrimary,
      linearTrackColor: AppColors.grey200,
      circularTrackColor: AppColors.grey200,
      refreshBackgroundColor: AppColors.lightSurface,
      linearMinHeight: 4,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.brandPrimary,
      unselectedLabelColor: AppColors.grey500,
      labelStyle: AppTextStyles.labelMedium,
      unselectedLabelStyle: AppTextStyles.labelMedium,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.brandPrimary, width: 2),
      ),
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: AppColors.lightBorder,
      overlayColor: WidgetStatePropertyAll(AppColors.grey100),
      splashFactory: InkRipple.splashFactory,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.lightSurface,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.grey100,
      deleteIconColor: AppColors.grey500,
      disabledColor: AppColors.grey200,
      selectedColor: AppColors.brandPrimary.withValues(alpha: 0.12),
      secondarySelectedColor: AppColors.brandPrimary.withValues(alpha: 0.08),
      shadowColor: AppColors.transparent,
      selectedShadowColor: AppColors.transparent,
      checkmarkColor: AppColors.brandPrimary,
      labelStyle: AppTextStyles.bodySmall.withColor(AppColors.grey700),
      secondaryLabelStyle: AppTextStyles.bodySmall.withColor(AppColors.grey500),
      brightness: Brightness.light,
      elevation: 0,
      pressElevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      side: BorderSide.none,
    ),
    badgeTheme: BadgeThemeData(
      backgroundColor: AppColors.error,
      textColor: AppColors.white,
      smallSize: 8,
      largeSize: 16,
      textStyle: AppTextStyles.labelSmall,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      alignment: AlignmentDirectional.topEnd,
      offset: const Offset(-4, 4),
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(AppColors.grey50),
      surfaceTintColor: WidgetStateProperty.all(AppColors.transparent),
      overlayColor: WidgetStateProperty.all(AppColors.black.withValues(alpha: 0.05)),
      shadowColor: WidgetStateProperty.all(AppColors.transparent),
      elevation: WidgetStateProperty.all(0),
      side: WidgetStateProperty.all(BorderSide(color: AppColors.grey300)),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      textStyle: WidgetStateProperty.all(AppTextStyles.bodyMedium),
      hintStyle: WidgetStateProperty.all(AppTextStyles.bodyMedium.withColor(AppColors.grey400)),
      constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
    ),
    searchViewTheme: SearchViewThemeData(
            surfaceTintColor: AppColors.transparent,
      elevation: 0,
      side: BorderSide.none,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      headerTextStyle: AppTextStyles.titleMedium,
      headerHintStyle: AppTextStyles.titleMedium.withColor(AppColors.grey400),
      dividerColor: AppColors.lightBorder,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.brandPrimary,
      secondary: AppColors.brandSecondary,
      tertiary: AppColors.brandAccent,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onTertiary: AppColors.white,
      onSurface: AppColors.darkTextPrimary,
      onError: AppColors.white,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.grey700,
      shadow: AppColors.darkShadow,
      scrim: AppColors.darkShadow,
      inverseSurface: AppColors.grey200,
      onInverseSurface: AppColors.black,
      inversePrimary: AppColors.brandDark,
      surfaceTint: AppColors.brandPrimary,
    ),
    fontFamily: AppTextStyles.fontFamily,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    dividerColor: AppColors.darkDivider,
    focusColor: AppColors.brandPrimary.withValues(alpha: 0.12),
    hoverColor: AppColors.brandPrimary.withValues(alpha: 0.08),
    highlightColor: AppColors.brandPrimary.withValues(alpha: 0.12),
    splashColor: AppColors.brandPrimary.withValues(alpha: 0.16),
    unselectedWidgetColor: AppColors.grey500,
    disabledColor: AppColors.grey700,
    secondaryHeaderColor: AppColors.grey900,
    hintColor: AppColors.grey500,
    brightness: Brightness.dark,
    primaryColor: AppColors.brandPrimary,
    primaryColorLight: AppColors.brandLight,
    primaryColorDark: AppColors.brandDark,
    canvasColor: AppColors.darkBackground,
    shadowColor: AppColors.darkShadow,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: AppColors.brandPrimary,
      shadowColor: AppColors.darkShadow,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
      toolbarTextStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 2,
      shadowColor: AppColors.darkShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: AppColors.white,
        elevation: 2,
        shadowColor: AppColors.darkShadow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: AppTextStyles.labelMedium,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.brandPrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: AppTextStyles.labelMedium,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.brandPrimary,
        backgroundColor: AppColors.transparent,
        side: const BorderSide(color: AppColors.brandPrimary, width: 1),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: AppTextStyles.labelMedium,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.grey700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.grey700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.brandPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.grey700.withValues(alpha: 0.5)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: AppTextStyles.bodyMedium.withColor(AppColors.grey500),
      labelStyle: AppTextStyles.labelMedium.withColor(AppColors.grey400),
      errorStyle: AppTextStyles.bodySmall.withColor(AppColors.error),
      helperStyle: AppTextStyles.bodySmall.withColor(AppColors.grey400),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    ),
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.headlineLarge,
      displayMedium: AppTextStyles.headlineMedium,
      displaySmall: AppTextStyles.headlineSmall,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
      space: 1,
      indent: 0,
      endIndent: 0,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.grey600;
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.brandPrimary;
        }
        return AppColors.grey600;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.grey700;
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.brandPrimary.withValues(alpha: 0.5);
        }
        return AppColors.grey700;
      }),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.grey600;
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.brandPrimary;
        }
        return AppColors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.white),
      overlayColor: WidgetStateProperty.all(AppColors.brandPrimary.withValues(alpha: 0.12)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      side: const BorderSide(
        color: AppColors.grey500,
        width: 2,
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.grey600;
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.brandPrimary;
        }
        return AppColors.transparent;
      }),
      overlayColor: WidgetStateProperty.all(AppColors.brandPrimary.withValues(alpha: 0.12)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.brandPrimary,
      inactiveTrackColor: AppColors.grey700,
      thumbColor: AppColors.brandPrimary,
      overlayColor: AppColors.brandPrimary.withValues(alpha: 0.12),
      valueIndicatorColor: AppColors.brandPrimary,
      valueIndicatorTextStyle: AppTextStyles.labelSmall.withColor(AppColors.white),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      trackShape: const RoundedRectSliderTrackShape(),
      valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
      showValueIndicator: ShowValueIndicator.onlyForDiscrete,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.brandPrimary,
      linearTrackColor: AppColors.grey700,
      circularTrackColor: AppColors.grey700,
      refreshBackgroundColor: AppColors.darkSurface,
      linearMinHeight: 4,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.brandPrimary,
      unselectedLabelColor: AppColors.grey400,
      labelStyle: AppTextStyles.labelMedium,
      unselectedLabelStyle: AppTextStyles.labelMedium,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.brandPrimary, width: 2),
      ),
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: AppColors.darkBorder,
      overlayColor: WidgetStatePropertyAll(AppColors.grey800),
      splashFactory: InkRipple.splashFactory,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.darkSurface,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.grey800,
      deleteIconColor: AppColors.grey400,
      disabledColor: AppColors.grey700,
      selectedColor: AppColors.brandPrimary.withValues(alpha: 0.12),
      secondarySelectedColor: AppColors.brandPrimary.withValues(alpha: 0.08),
      shadowColor: AppColors.transparent,
      selectedShadowColor: AppColors.transparent,
      checkmarkColor: AppColors.brandPrimary,
      labelStyle: AppTextStyles.bodySmall.withColor(AppColors.grey300),
      secondaryLabelStyle: AppTextStyles.bodySmall.withColor(AppColors.grey500),
      brightness: Brightness.dark,
      elevation: 0,
      pressElevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      side: BorderSide.none,
    ),
    badgeTheme: BadgeThemeData(
      backgroundColor: AppColors.error,
      textColor: AppColors.white,
      smallSize: 8,
      largeSize: 16,
      textStyle: AppTextStyles.labelSmall,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      alignment: AlignmentDirectional.topEnd,
      offset: const Offset(-4, 4),
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(AppColors.grey800),
      surfaceTintColor: WidgetStateProperty.all(AppColors.transparent),
      overlayColor: WidgetStateProperty.all(AppColors.white.withValues(alpha: 0.05)),
      shadowColor: WidgetStateProperty.all(AppColors.transparent),
      elevation: WidgetStateProperty.all(0),
      side: WidgetStateProperty.all(BorderSide(color: AppColors.grey700)),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      textStyle: WidgetStateProperty.all(AppTextStyles.bodyMedium),
      hintStyle: WidgetStateProperty.all(AppTextStyles.bodyMedium.withColor(AppColors.grey500)),
      constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
    ),
    searchViewTheme: SearchViewThemeData(
      backgroundColor: AppColors.darkBackground,
      surfaceTintColor: AppColors.transparent,
      elevation: 0,
      side: BorderSide.none,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      headerTextStyle: AppTextStyles.titleMedium,
      headerHintStyle: AppTextStyles.titleMedium.withColor(AppColors.grey500),
      dividerColor: AppColors.darkBorder,
    ),
  );
}