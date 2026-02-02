import 'package:flutter/material.dart';

extension AppColorScheme on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

extension AppTextTheme on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  TextStyle get titleLarge => Theme.of(this).textTheme.titleLarge!.copyWith(
        color: Theme.of(this).colorScheme.onSurface,
      );

  TextStyle get titleMedium => Theme.of(this).textTheme.titleMedium!.copyWith(
        color: Theme.of(this).colorScheme.onSurface,
      );

  TextStyle get bodyLarge => Theme.of(this).textTheme.bodyLarge!.copyWith(
        color: Theme.of(this).colorScheme.onSurface,
      );

  TextStyle get bodyMedium => Theme.of(this).textTheme.bodyMedium!.copyWith(
        color: Theme.of(this).colorScheme.onSurface,
      );

  TextStyle get bodySmall => Theme.of(this).textTheme.bodySmall!.copyWith(
        color: Theme.of(this).colorScheme.onSurface,
      );

  TextStyle get headlineMedium =>
      Theme.of(this).textTheme.headlineMedium!.copyWith(
            color: Theme.of(this).colorScheme.onSurface,
          );

  TextStyle get headlineSmall =>
      Theme.of(this).textTheme.headlineSmall!.copyWith(
            color: Theme.of(this).colorScheme.onSurface,
          );
}
