class ValidatorLogin {
  static String? Function(String?) validatorPassword = (String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu contraseña';
    }
    return null;
  };
  static String? Function(String?) validatorEmail = (String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu correo electrónico';
    }
    return null;
  };
}
