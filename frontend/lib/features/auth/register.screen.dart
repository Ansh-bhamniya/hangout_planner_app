import 'package:flutter/material.dart';
import 'package:frontend_01/services/api_service.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  String selectedImage = "https://via.placeholder.com/150";

  void register() async {
    final res = await ApiService.register({
      "name": nameController.text,
      "bio": bioController.text,
      "phoneNumber": phoneController.text,
      "password": passwordController.text,
      "profileImage": selectedImage,
    });

    if (res['success'] == 'true') {
      Navigator.pushNamed(context, '/login', arguments: phoneController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: bioController, decoration: const InputDecoration(labelText: 'Bio')),
          TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
          TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: register, child: const Text("Register")),
          TextButton(onPressed: () => Navigator.pushNamed(context, '/login'), child: const Text("Already have an account? Login"))
        ]),
      ),
    );
  }
}
