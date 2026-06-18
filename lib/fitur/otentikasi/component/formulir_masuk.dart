import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class FormulirMasuk extends StatelessWidget {
  final TextEditingController identitasController;
  final TextEditingController passwordController;

  const FormulirMasuk({
    super.key,
    required this.identitasController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FTextField(
          label: const Text('Email / NIM / NIP'),
          hint: 'Masukkan identitas anda',
          control: FTextFieldControl.managed(controller: identitasController),
        ),
        const SizedBox(height: 16),
        FTextField.password(
          label: const Text('Password'),
          hint: 'Masukkan password',
          control: FTextFieldControl.managed(controller: passwordController),
        ),
      ],
    );
  }
}
