import 'package:flutter/material.dart';
import 'package:frontend_01/services/api_service.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpController = TextEditingController();

  void verify(String phone) async {
    final res = await ApiService.verifyOtp(phone, otpController.text);
    if (res['success'] == 'true') {
      await ApiService.saveToken(res['data']['token']);
      Navigator.pushReplacementNamed(context, '/landing');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text("Enter OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text("Enter OTP sent to $phone"),
          TextField(controller: otpController, decoration: const InputDecoration(labelText: 'OTP')),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: () => verify(phone), child: const Text("Verify"))
        ]),
      ),
    );
  }
}
