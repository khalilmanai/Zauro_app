import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared_widgets/custom_text_field.dart';
import '../../../../shared_widgets/custom_button.dart';
import '../controllers/auth_controller.dart';
import '../../../../shared_widgets/loading_widget.dart';
import '../../../../shared_widgets/error_widget.dart';

class LoginPage extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(controller: emailController, hintText: 'Email'),
            const SizedBox(height: 16),
            CustomTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true),
            const SizedBox(height: 16),
            if (authState is AuthLoading)
              LoadingWidget()
            else if (authState is AuthError)
              ErrorWidgetCustom(message: (authState as AuthError).message)
            else
              CustomButton(
                text: 'Login',
                onPressed: () {
                  // AuthController.login expects positional (email, password)
                  ref.read(authControllerProvider.notifier).login(
                        emailController.text,
                        passwordController.text,
                      );
                },
              ),
          ],
        ),
      ),
    );
  }
}
