import 'package:flutter/material.dart';
import 'package:frontend_01/services/api_service.dart';

class ThreeDots extends StatefulWidget {
  const ThreeDots({super.key});

  @override
  State<ThreeDots> createState() => _ThreeDotsState();
}

class _ThreeDotsState extends State<ThreeDots> {
  String? name;
  String? phoneNumber;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }
// this is the updated one
  Future<void> loadUserData() async {
    try {
      final response = await ApiService.getCurrentUserDetails(); // returns: { success: true, data: {...} }
      // print('khatola : $response');

      final userData = response['data'];
      setState(() {
        name = userData['name'];
        phoneNumber = userData['phoneNumber'];
        isLoading = false;
      });
    } catch (e) {
      print("❌ Failed to fetch user details: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Name: ${name ?? 'N/A'}", style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  Text("Phone: ${phoneNumber ?? 'N/A'}", style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
    );
  }
}
