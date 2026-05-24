class Validators {
  static String? fieldRequired(String? v) {
    if (v == null || v.isEmpty) {
      return 'field is required';
    }
    return null;
  }

  static String? duration(String? v, int max, [int min = 0]) {
    final message = fieldRequired(v);
    if (message != null) return message;
    final value = int.parse(v!);
    if (value <= min || value > max) {
      return 'duration must be between $min and $max';
    }
    return null;
  }

  static String? days(String? v) {
    final message = fieldRequired(v);
    if (message != null) return message;
    final value = int.parse(v!);
    if (value < 0) {
      return 'days must be greater than 0';
    }
    return null;
  }

  static String? positivity(String? v) {
    final message = fieldRequired(v);
    if (message != null) return message;
    final value = int.parse(v!);
    if (value <= 0) {
      return 'number must be greater than 0';
    }
    return null;
  }

  static String? emailValidator(String? v) {
    RegExp regex = RegExp(
        r"^[-!#$%&'*+/0-9=?A-Z^_a-z{|}~](\.?[-!#$%&'*+/0-9=?A-Z^_a-z{|}~])");
    if (v == null || v.isEmpty) {
      return 'email is required';
    } else if (!regex.hasMatch(v)) {
      return "this email is not a valid email";
    }
    return null;
  }

  static String? passwordValidator(String? v) {
    if (v == null || v.isEmpty) {
      return 'password is required';
    }
    return null;
  }

  static String? firstNameValidator(String? v) {
    if (v == null || v.isEmpty) {
      return 'first name is required';
    }
    return null;
  }

  static String? lastNameValidator(String? v) {
    if (v == null || v.isEmpty) {
      return 'last name is required';
    }
    return null;
  }

  static String? confirmPasswordValidator(String? v) {
    if (v == null || v.isEmpty) {
      return 'confirm password is required';
    }
    return null;
  }

  static String? aboutValidator(String? v) {
    if (v == null || v.isEmpty) {
      return 'about is required';
    }
    return null;
  }
}
