class Validations {
  static String validateName(String value) {
    if (value.isEmpty) return 'Le nom d’utilisateur est requis.';
    final RegExp nameExp = new RegExp(r'^[A-za-zğüşöçİĞÜŞÖÇ ]+$');
    if (!nameExp.hasMatch(value))
      return 'Veuillez entrer uniquement des caractères alphabétiques.';
    return null;
  }

  static String validateEmail(String value, [bool isRequried = true]) {
    if (value.isEmpty && isRequried) return 'L\'email est requis.';
    final RegExp nameExp = new RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (!nameExp.hasMatch(value) && isRequried)
      return 'Adresse email non valide';
    return null;
  }

  static String validatePassword(String value) {
    if (value.isEmpty || value.length < 6)
      return 'Veuillez entrer un mot de passe valide.';
    return null;
  }
}
