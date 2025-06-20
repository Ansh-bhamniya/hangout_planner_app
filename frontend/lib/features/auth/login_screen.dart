import 'package:flutter/material.dart';
import 'package:frontend_01/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    final res = await ApiService.login(phoneController.text, passwordController.text);
    if (res['success'] == 'true') {
      Navigator.pushNamed(context, '/otp', arguments: phoneController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login"),
      automaticallyImplyLeading: false,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
          TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: login, child: const Text("Login")),
          TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text("No account? Register"))
        ]),
      ),
    );
  }
}
