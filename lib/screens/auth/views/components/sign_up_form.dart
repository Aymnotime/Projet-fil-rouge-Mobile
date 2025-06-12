import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../../../../constants.dart';


final emaildValidator = MultiValidator([
  RequiredValidator(errorText: 'Email requis'),
  EmailValidator(errorText: "Enter une adresse mail valide"),
]);

const pasNotMatchErrorText = "Les mots de passe ne correspondent pas";

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    required this.formKey,
    required this.nomController,
    required this.prenomController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nomController;
  final TextEditingController prenomController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: widget.nomController,
            decoration: const InputDecoration(hintText: "Nom"),
            validator: (value) => value == null || value.isEmpty ? "Champ requis" : null,
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: widget.prenomController,
            decoration: const InputDecoration(hintText: "Prénom"),
            validator: (value) => value == null || value.isEmpty ? "Champ requis" : null,
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: widget.emailController,
            validator: emaildValidator.call,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Email address",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Message.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: widget.passwordController,
            validator: passwordValidator.call,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Password",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Lock.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: widget.confirmController,
            validator: (value) {
              if (value == null || value.isEmpty) return "Champ requis";
              if (value != widget.passwordController.text) return pasNotMatchErrorText;
              return null;
            },
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Confirmer le mot de passe",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Lock.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}