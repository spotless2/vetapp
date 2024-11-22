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

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  List<dynamic> cabinets = [];
  String? selectedCabinetId;
  File? _image;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    fetchCabinets();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _animation,
              child: Column(
                children: [
                  Icon(
                    Icons.pets,
                    size: 80,
                    color: Colors.teal.shade700,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Creare Cont',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Înregistrează-te pentru a începe',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  SizedBox(height: 40),
                  _buildTextField(usernameController, 'Nume Utilizator'),
                  SizedBox(height: 16),
                  _buildTextField(passwordController, 'Parolă', obscureText: true),
                  SizedBox(height: 16),
                  _buildTextField(emailController, 'Email'),
                  SizedBox(height: 16),
                  _buildTextField(firstNameController, 'Prenume'),
                  SizedBox(height: 16),
                  _buildTextField(middleNameController, 'Al Doilea Prenume (Opțional)'),
                  SizedBox(height: 16),
                  _buildTextField(lastNameController, 'Nume'),
                  SizedBox(height: 16),
                  _buildDropdownField(),
                  SizedBox(height: 16),
                  _buildPhotoField(),
                  SizedBox(height: 40),
                  MouseRegion(
                    onEnter: (_) => setState(() => _isHovered = true),
                    onExit: (_) => setState(() => _isHovered = false),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      child: ElevatedButton(
                        onPressed: register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isHovered 
                              ? Colors.white 
                              : Colors.teal.shade600,
                          padding: EdgeInsets.symmetric(
                            horizontal: _isHovered ? 60 : 50,
                            vertical: 15
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: _isHovered ? 8 : 4,
                        ),
                        child: Text(
                          'Înregistrare',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isHovered 
                                ? Colors.teal.shade600 
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      'Ai deja cont? Autentifică-te',
                      style: TextStyle(
                        color: Colors.teal.shade800,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildTextField(TextEditingController controller, String labelText, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.teal.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: obscureText,
      style: TextStyle(fontSize: 16),
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
        labelStyle: TextStyle(color: Colors.teal.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPhotoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fotografie',
          style: TextStyle(
            fontSize: 16,
            color: Colors.teal.shade700,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickImage,
            icon: Icon(Icons.photo_camera, color: Colors.teal.shade600),
            label: Text(
              _image == null ? 'Încarcă Fotografie' : 'Schimbă Fotografie',
              style: TextStyle(color: Colors.teal.shade600),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              side: BorderSide(color: Colors.teal.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
            ),
          ),
        ),
        if (_image != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_image!, height: 100, width: 100, fit: BoxFit.cover),
            ),
          ),
      ],
    );
  }
}