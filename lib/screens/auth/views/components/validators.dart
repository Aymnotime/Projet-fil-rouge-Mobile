import 'package:form_field_validator/form_field_validator.dart';

// Validation stricte pour inscription et changement de mot de passe
final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Mot de passe requis'),
  MinLengthValidator(12, errorText: 'Le mot de passe doit contenir au moins 12 caractères'),
  PatternValidator(r'(?=.*?[#?!@$%^&*-])',
      errorText: 'Le mot de passe doit contenir au moins un caractère spécial')
]);

final emailValidator = MultiValidator([
  RequiredValidator(errorText: 'Email requis'),
  EmailValidator(errorText: "Entrez une adresse mail valide"),
]);

const pasNotMatchErrorText = "Les mots de passe ne correspondent pas";
