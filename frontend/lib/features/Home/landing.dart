import 'package:flutter/material.dart';
import 'package:frontend_01/features/Home/tabs/all_users_tab.dart';
import 'package:frontend_01/features/Home/tabs/friends_tab.dart';
import 'package:frontend_01/features/Home/tabs/nodes.dart';
import 'package:frontend_01/features/Home/tabs/noification_tab.dart';
import 'package:frontend_01/features/Profile/three_dots.dart';
import 'package:frontend_01/features/auth/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Tab> tabs = const [
      Tab(text: "All users"),
      Tab(text: "Friends"),
      Tab(text: "Notifications"),
      Tab(text: "Nodes"),
    ];

    final List<Widget> tabViews = const [
      AllUsersTab(),
      FriendsTab(),
      NotificationTab(),
      Nodes(),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.blue,
          title: const Text(
            'Hangout App',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white), // Hamburger / 3-dot icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ThreeDots()),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: tabs,
            labelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            indicatorColor: Colors.white,
            indicatorWeight: 4.0,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
        body: TabBarView(children: tabViews),
      ),
    );
  }
}
