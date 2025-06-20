import 'package:flutter/material.dart';
import 'package:frontend_01/features/Home/tabs/all_users_tab.dart';
import 'package:frontend_01/features/Home/tabs/friends_tab.dart';
import 'package:frontend_01/features/Home/tabs/noification_tab.dart';
import 'package:frontend_01/features/auth/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static AppBar buildAppBarV4(BuildContext context){
    return AppBar(
      bottom: TabBar(
        tabs: [
          Tab(text: "All users"),
          Tab(text: "My Friends"),
          Tab(text: "Notifications"),
        ],
        labelStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        indicatorColor: Colors.white,
        indicatorWeight: 4.0,
        indicatorPadding: EdgeInsets.symmetric(horizontal: 8.0),
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      toolbarHeight: 80,
      title: Text(
        'Hangout App',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.blue,
      automaticallyImplyLeading: false,
      leading: null,
      actions: [
        IconButton(
          icon: Icon(Icons.logout_rounded,
          color: Colors.white,
          ), 
          onPressed: () { 
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => LoginScreen()));
          },
        ),
        
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        appBar: buildAppBarV4(context),
        body: TabBarView(
          children: [
            AllUsersTab(),
            FriendsTab(),
            NotificationTab(),
          ]),
      ));
  }
}
