import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  List<dynamic> cabinets = [];
  String? selectedCabinetId;
  File? _image;

  @override
  void initState() {
    super.initState();
    fetchCabinets();
  }

  Future<void> fetchCabinets() async {
    final response = await http.get(Uri.parse('http://localhost:3000/cabinets'));

    if (response.statusCode == 200) {
      setState(() {
        cabinets = jsonDecode(response.body);
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cabinets')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> register() async {
    final request = http.MultipartRequest('POST', Uri.parse('http://localhost:3000/auth/register'));

    request.fields['username'] = usernameController.text;
    request.fields['password'] = passwordController.text;
    request.fields['email'] = emailController.text;
    request.fields['firstName'] = firstNameController.text;
    request.fields['middleName'] = middleNameController.text;
    request.fields['lastName'] = lastNameController.text;
    request.fields['cabinetId'] = selectedCabinetId ?? '';

    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _image!.path));
    }

    final response = await request.send();

    if (response.statusCode == 201) {
      // Handle successful registration
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      // Handle registration failure
      final responseBody = await response.stream.bytesToString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $responseBody')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(usernameController, 'Username'),
                SizedBox(height: 10),
                _buildTextField(passwordController, 'Password', obscureText: true),
                SizedBox(height: 10),
                _buildTextField(emailController, 'Email'),
                SizedBox(height: 10),
                _buildTextField(firstNameController, 'First Name'),
                SizedBox(height: 10),
                _buildTextField(middleNameController, 'Middle Name (Optional)'),
                SizedBox(height: 10),
                _buildTextField(lastNameController, 'Last Name'),
                SizedBox(height: 10),
                _buildDropdownField(),
                SizedBox(height: 10),
                _buildPhotoField(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text('Register', style: TextStyle(fontSize: 18)),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    'Already have an account? Login',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool obscureText = false}) {
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
      obscureText: obscureText,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: selectedCabinetId,
      onChanged: (String? newValue) {
        setState(() {
          selectedCabinetId = newValue;
        });
      },
      items: cabinets.map<DropdownMenuItem<String>>((dynamic cabinet) {
        return DropdownMenuItem<String>(
          value: cabinet['id'].toString(),
          child: Text(cabinet['name']),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Cabinet',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildPhotoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickImage,
            icon: Icon(Icons.photo_camera),
            label: Text(_image == null ? 'Upload Photo' : 'Change Photo'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              side: BorderSide(color: Colors.grey[400]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        if (_image != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Image.file(_image!, height: 100, width: 100),
          ),
      ],
    );
  }
}