import 'package:flutter/material.dart';
import 'package:frontend_01/services/api_service.dart';

class AllUsersTab extends StatefulWidget {
  const AllUsersTab({super.key});

  @override
  State<AllUsersTab> createState() => _AllUsersTabState();
}

class _AllUsersTabState extends State<AllUsersTab> {
  List<dynamic> users = [];
  bool isLoading = true;
  

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final data = await ApiService.fetchAllUsers();
      setState(() {
        users = data;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Failed to fetch users: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> sendFollowRequest(String targetUserId) async {
    try {
      await ApiService.sendFollowRequest(targetUserId);
      print("✅ Follow request sent to $targetUserId");

      setState(() {
        for (var user in users) {
          if (user['_id'] == targetUserId) {
            user['followRequested'] = true;
            break;
          }
        }
      });
    } catch (e) {
      print("❌ Failed to send follow request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchUsers,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isRequested = user['followRequested'] == true;
                  final isFriend = user['isFriend'] == true;
                  print('USER: ${user['_id']}, isFriend: ${user['isFriend']}, followRequested: ${user['followRequested']}');

                  String buttonText;
                  Color buttonColor;
                  VoidCallback? onPressed;
                  if (isFriend) {
                  buttonText = "Friend";
                  buttonColor = Colors.green;
                  onPressed = null;
                } else if (isRequested) {
                  buttonText = "Requested";
                  buttonColor = Colors.grey;
                  onPressed = null;
                } else {
                  buttonText = "Follow";
                  buttonColor = Colors.blue;
                  onPressed = () => sendFollowRequest(user['_id']);
                }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      backgroundImage: user['profileImage'] != null &&
                              user['profileImage'].toString().isNotEmpty
                          ? NetworkImage(user['profileImage'])
                          : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                    ),
                    title: Text(
                      user['name'] ?? 'Unnamed User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user['phoneNumber'] ?? 'No phone number'),
                    trailing: ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),

                  );
                },
              ),
            ),
    );
  }
}
