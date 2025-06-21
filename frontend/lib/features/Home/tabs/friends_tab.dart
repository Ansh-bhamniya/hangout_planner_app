import 'package:flutter/material.dart';
import 'package:frontend_01/services/api_service.dart';

class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  List<dynamic> friends = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    try {
      final data = await ApiService.fetchFriends(); // 👉 implement this in ApiService
      setState(() {
        friends = data;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Failed to load friends: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : friends.isEmpty
              ? const Center(child: Text("No friends yet."))
              : ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    return ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        size: 28,
                        color: Colors.blue,
                      ),
                    ),
                      title: Text(
                        friend['name'] ?? 'Unnamed User',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    subtitle: 
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [                        
                        if (friend['bio'] != null && friend['bio'].toString().isNotEmpty)
                        Text(friend['bio'], style: TextStyle(fontSize: 12, color: Colors.black)),
                      ],
                    ),
                    );
                  },
                ),
    );
  }
}
