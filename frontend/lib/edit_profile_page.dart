import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  final Map<String, dynamic> userDetails;

  EditProfilePage({required this.userDetails});

    @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController(text: userDetails['username']);
    final TextEditingController emailController = TextEditingController(text: userDetails['email']);
    final TextEditingController firstNameController = TextEditingController(text: userDetails['firstName']);
    final TextEditingController middleNameController = TextEditingController(text: userDetails['middleName']);
    final TextEditingController lastNameController = TextEditingController(text: userDetails['lastName']);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editare Profil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.teal.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSection(
                      'Informații Cont',
                      Icons.account_circle,
                      [
                        _buildTextField(usernameController, 'Nume Utilizator', Icons.person),
                        SizedBox(height: 16),
                        _buildTextField(emailController, 'Email', Icons.email),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildSection(
                      'Informații Personale',
                      Icons.person_outline,
                      [
                        _buildTextField(firstNameController, 'Prenume', Icons.person_outline),
                        SizedBox(height: 16),
                        _buildTextField(middleNameController, 'Al Doilea Prenume (Opțional)', Icons.person_outline),
                        SizedBox(height: 16),
                        _buildTextField(lastNameController, 'Nume', Icons.person_outline),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  // Handle save
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Salvează',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal.shade700),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.teal.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.teal.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vă rugăm să introduceți $labelText';
        }
        return null;
      },
    );
  }
}