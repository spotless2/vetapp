import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'client_page.dart';
import 'inventory_page.dart';
import 'registry_page.dart';
import 'scheduling_page.dart';
import 'calendar_page.dart';
import 'import_page.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';

class MainPage extends StatefulWidget {
  final Map<String, dynamic> user;

  MainPage({required this.user});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
    late Map<String, dynamic> userDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final userId = widget.user['id'].toString();

    final response = await http.get(Uri.parse('http://localhost:3000/users/$userId'));

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody != null) {
        setState(() {
          userDetails = responseBody;
          isLoading = false;
        });
      } else {
        // Handle unexpected response structure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected response structure')),
        );
      }
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user details')),
      );
    }
  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Vet App',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile section on the left
                Container(
                  width: 200, // Adjust the width to your preference
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.blue.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Welcome, ${userDetails['username']}!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildProfileSection(),
                    ],
                  ),
                ),
                // Circular buttons on the right
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // Main circular background
                        Container(
                          width: 400,
                          height: 400,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Colors.white.withOpacity(0.6), Colors.blueAccent],
                              center: Alignment.center,
                              radius: 0.8,
                            ),
                          ),
                        ),
                        // Circular buttons
                        _buildCircularButton(context, 'Clients', ClientPage(user: userDetails), top: 40, left: 100),
                        _buildCircularButton(context, 'Import', ImportPage(), top: 40, right: 100),
                        _buildCircularButton(context, 'Calendar', CalendarPage(), left: 20),
                        _buildCircularButton(context, 'Inventory', InventoryPage(), right: 20),
                        _buildCircularButton(context, 'Scheduling', SchedulingPage(), bottom: 40, left: 100),
                        _buildCircularButton(context, 'Registry', RegistryPage(), bottom: 40, right: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
  );
}

  // Function to build a circular button at a specified position
  Widget _buildCircularButton(
    BuildContext context,
    String text,
    Widget page, {
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: HoverButton(
        text: text,
        page: page,
      ),
    );
  }
  Widget _buildProfileSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center, // Center the content
    children: [
      GestureDetector(
        onTap: () {
          // Expand profile section (if needed)
        },
        child: CircleAvatar(
          radius: 50, // Slightly larger for better emphasis
          backgroundImage: NetworkImage('http://localhost:3000${userDetails['photo']}'),
        ),
      ),
      SizedBox(height: 15), // More spacing after the profile picture
      Text(
        userDetails['username'], // Display the username
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
      SizedBox(height: 25), // Add some spacing before the buttons
      // 'Edit Profile' Button
      ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditProfilePage(userDetails: userDetails)),
          );
        },
        icon: Icon(Icons.edit, size: 18), // Add an icon for better design
        label: Text('Edit Profile'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // More padding for bigger button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          backgroundColor: Colors.blue.shade600, // Custom color
        ),
      ),
      SizedBox(height: 15), // Spacing between buttons
      // 'Sign Out' Button
      ElevatedButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
        icon: Icon(Icons.logout, size: 18), // Add an icon for sign out
        label: Text('Sign Out'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.redAccent, // Different color to indicate sign out
        ),
      ),
    ],
  );
}

}



class HoverButton extends StatefulWidget {
  final String text;
  final Widget page;

  HoverButton({required this.text, required this.page});

  @override
  _HoverButtonState createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => _onHover(true),
      onExit: (event) => _onHover(false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: _isHovered ? 85 : 70,
        height: _isHovered ? 85 : 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isHovered ? Colors.white : Colors.blue.shade400,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => widget.page),
            );
          },
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(0),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          child: Center(
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isHovered ? Colors.blue : Colors.white,
                fontSize: 10, // Reduced the font size slightly
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }
}
