import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'admin_panel_page.dart';
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

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  late Map<String, dynamic> userDetails;
  bool isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;
  Map<String, bool> _hoveredStates = {};

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Structură de răspuns neașteptată')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nu s-au putut încărca detaliile utilizatorului')),
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
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade100, Colors.teal.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile section
                  Container(
                    width: 250,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade50, Colors.teal.shade100],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage('http://localhost:3000${userDetails['photo']}'),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Bine ai venit, ${userDetails['username']}!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          userDetails['email'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),
                        _buildProfileSection(),
                      ],
                    ),
                  ),
                  // Navigation buttons
                  Expanded(
                    child: Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          _buildNavButton('Clienți', Icons.people, ClientPage(user: userDetails)),
                          _buildNavButton('Import', Icons.upload_file, ImportPage()),
                          _buildNavButton('Calendar', Icons.calendar_today, CalendarPage()),
                          _buildNavButton('Inventar', Icons.inventory, InventoryPage()),
                          _buildNavButton('Programări', Icons.schedule, SchedulingPage()),
                          _buildNavButton('Registru', Icons.book, RegistryPage()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNavButton(String text, IconData icon, Widget page) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredStates[text] = true),
      onExit: (_) => setState(() => _hoveredStates[text] = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: _hoveredStates[text] == true ? 120 : 110,
        height: _hoveredStates[text] == true ? 120 : 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _hoveredStates[text] == true ? Colors.white : Colors.teal.shade300,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: _hoveredStates[text] == true ? 15 : 10,
              offset: Offset(0, _hoveredStates[text] == true ? 8 : 4),
              spreadRadius: _hoveredStates[text] == true ? 2 : 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: CircleBorder(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: _hoveredStates[text] == true ? 32 : 28,
                  color: _hoveredStates[text] == true ? Colors.teal : Colors.white,
                ),
                SizedBox(height: 8),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _hoveredStates[text] == true ? Colors.teal : Colors.white,
                    fontSize: _hoveredStates[text] == true ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditProfilePage(userDetails: userDetails)),
            );
          },
          icon: Icon(Icons.edit, size: 18, color: Colors.white),
          label: Text(
            'Editează Profilul',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade400,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        if (true) ...[
          SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminPanelPage()),
              );
            },
            icon: Icon(Icons.admin_panel_settings, size: 18, color: Colors.white),
            label: Text(
              'Panou Administrator',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
        SizedBox(height: 15),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          icon: Icon(Icons.logout, size: 18, color: Colors.white),
          label: Text(
            'Deconectare',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}