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
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(usernameController, 'Username'),
              SizedBox(height: 10),
              _buildTextField(emailController, 'Email'),
              SizedBox(height: 10),
              _buildTextField(firstNameController, 'First Name'),
              SizedBox(height: 10),
              _buildTextField(middleNameController, 'Middle Name (Optional)'),
              SizedBox(height: 10),
              _buildTextField(lastNameController, 'Last Name'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle profile update logic
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}