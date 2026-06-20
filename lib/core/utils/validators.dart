import 'package:social_media/core/utils/string_constants.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.emailRequired;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.emailInvalid;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    if (value.length < 6) {
      return AppStrings.passwordMinLength;
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.usernameRequired;
    }
    if (value.trim().length < 3) {
      return AppStrings.usernameMinLength;
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value.trim())) {
      return AppStrings.usernameInvalid;
    }
    return null;
  }

  static String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.displayNameRequired;
    }
    if (value.trim().length < 2) {
      return AppStrings.displayNameMinLength;
    }
    return null;
  }

  static String? validateBio(String? value) {
    if (value != null && value.trim().length > 150) {
      return AppStrings.bioMaxLength;
    }
    return null;
  }

  static String? validatePostContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.postContentRequired;
    }
    if (value.trim().length > 500) {
      return AppStrings.postContentMaxLength;
    }
    return null;
  }
}

