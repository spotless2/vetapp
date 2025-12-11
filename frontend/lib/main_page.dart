import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'admin_panel_page.dart';
import 'client_page.dart';
import 'inventory_page.dart';
import 'registry_page.dart';
import 'scheduling_page.dart';
import 'calendar_page.dart';
import 'config/api_config.dart';
import 'import_page.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';

class MainPage extends StatefulWidget {
  final Map<String, dynamic> user;

  MainPage({required this.user});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
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
    final response =
        await http.get(Uri.parse('${ApiConfig.baseUrl}/users/$userId'));

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
        SnackBar(
            content: Text('Nu s-au putut încărca detaliile utilizatorului')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Vet App Dashboard',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: const Color(0xFF00796B),
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(const Color(0xFF00796B)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Se încarcă...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSidebar(),
                    Expanded(child: _buildMainContent()),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      _buildMainContent(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00796B),
                  const Color(0xFF26A69A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                      backgroundImage: NetworkImage(
                        '${ApiConfig.baseUrl}${userDetails['photo']}'),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bine ai venit!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${userDetails['firstName'] ?? ''} ${userDetails['lastName'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    userDetails['Cabinet']?['name'] ?? 'Fără cabinet',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.95),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildProfileSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00796B),
            const Color(0xFF26A69A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
              backgroundImage:
                NetworkImage('${ApiConfig.baseUrl}${userDetails['photo']}'),
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            '${userDetails['firstName'] ?? ''} ${userDetails['lastName'] ?? ''}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userDetails['Cabinet']?['name'] ?? 'Fără cabinet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meniu Principal',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00796B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selectați o opțiune pentru a continua',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              _buildModernNavCard('Clienți', Icons.people_rounded,
                  const Color(0xFF00796B), ClientPage(user: userDetails)),
              _buildModernNavCard('Import', Icons.upload_file_rounded,
                  const Color(0xFF1976D2), ImportPage()),
              _buildModernNavCard('Calendar', Icons.calendar_today_rounded,
                  const Color(0xFF7B1FA2), CalendarPage(user: userDetails)),
              _buildModernNavCard('Inventar', Icons.inventory_2_rounded,
                  const Color(0xFFE64A19), InventoryPage(user: userDetails)),
              _buildModernNavCard('Programări', Icons.schedule_rounded,
                  const Color(0xFF0097A7), SchedulingPage(user: userDetails)),
              _buildModernNavCard('Registru', Icons.menu_book_rounded,
                  const Color(0xFF689F38), RegistryPage()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernNavCard(
      String text, IconData icon, Color color, Widget page) {
    final isHovered = _hoveredStates[text] == true;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredStates[text] = true),
      onExit: (_) => setState(() => _hoveredStates[text] = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0, isHovered ? -8 : 0, 0),
        child: Card(
          elevation: isHovered ? 12 : 4,
          shadowColor: color.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
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
        _buildMenuButton(
          icon: Icons.edit_rounded,
          label: 'Editează Profilul',
          color: const Color(0xFF00796B),
          onPressed: () async {
            final updatedUser = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      EditProfilePage(userDetails: userDetails)),
            );
            
            // Refresh user details if profile was updated
            if (updatedUser != null) {
              await _fetchUserDetails();
            }
          },
        ),
        const SizedBox(height: 12),
        if (true) ...[
          _buildMenuButton(
            icon: Icons.admin_panel_settings_rounded,
            label: 'Panou Administrator',
            color: const Color(0xFFD32F2F),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminPanelPage()),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
        _buildMenuButton(
          icon: Icons.logout_rounded,
          label: 'Deconectare',
          color: const Color(0xFFE64A19),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
