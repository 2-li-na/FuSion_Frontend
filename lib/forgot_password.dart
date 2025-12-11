import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Passwort vergessen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Geben Sie Ihre registrierte E-Mail-Adresse ein, um ein neues Passwort zu erhalten.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email-Adresse',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String email = emailController.text.trim();
                if (email.isNotEmpty) {
                  // Call your backend service to send the password reset email
                  // Example: YourBackendService.sendPasswordResetEmail(email);

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Wenn diese E-Mail existiert, wurde ein Link zum Zurücksetzen des Passworts gesendet."), // Fixed encoding
                  ));
                }
              },
              child: const Text('Passwort zurücksetzen'), // Fixed encoding
            ),
          ],
        ),
      ),
    );
  }
}