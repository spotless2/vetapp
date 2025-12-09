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

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  List<dynamic> cabinets = [];
  String? selectedCabinetId;
  String? selectedUserType;
  File? _image;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHovered = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

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
    final response =
        await http.get(Uri.parse('http://localhost:3000/cabinets'));

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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                  child: Text('Vă rugăm să selectați tipul de utilizator')),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (selectedUserType == 'doctor' && selectedCabinetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Vă rugăm să selectați un cabinet')),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('http://localhost:3000/auth/register'));

      request.fields['username'] = usernameController.text.trim();
      request.fields['password'] = passwordController.text;
      request.fields['email'] = emailController.text.trim();
      request.fields['firstName'] = firstNameController.text.trim();
      request.fields['middleName'] = middleNameController.text.trim();
      request.fields['lastName'] = lastNameController.text.trim();
      request.fields['userType'] = selectedUserType!;

      if (selectedUserType == 'doctor' && selectedCabinetId != null) {
        request.fields['cabinetId'] = selectedCabinetId!;
      }

      if (_image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('photo', _image!.path));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                    child: Text(
                        'Înregistrare reușită! Vă rugăm să vă autentificați.')),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        final responseBody = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Înregistrare eșuată: $responseBody')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                  child: Text('Eroare de conexiune. Verificați serverul.')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF004D40),
              const Color(0xFF00796B),
              const Color(0xFF26A69A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _animation,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Logo
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.pets,
                            size: 50,
                            color: const Color(0xFF00796B),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Creare Cont',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: size.width > 600 ? 36 : 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Înregistrează-te pentru a începe',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Form Card
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTextField(usernameController,
                                  'Nume Utilizator', Icons.person_outline,
                                  validator: (v) => v?.trim().isEmpty ?? true
                                      ? 'Câmp obligatoriu'
                                      : null),
                              const SizedBox(height: 16),
                              _buildTextField(passwordController, 'Parolă',
                                  Icons.lock_outline,
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: const Color(0xFF00796B)),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),
                                  validator: (v) => v == null || v.length < 6
                                      ? 'Minim 6 caractere'
                                      : null),
                              const SizedBox(height: 16),
                              _buildTextField(emailController, 'Email',
                                  Icons.email_outlined,
                                  validator: (v) => v?.contains('@') != true
                                      ? 'Email invalid'
                                      : null),
                              const SizedBox(height: 16),
                              _buildTextField(firstNameController, 'Prenume',
                                  Icons.badge_outlined,
                                  validator: (v) => v?.trim().isEmpty ?? true
                                      ? 'Câmp obligatoriu'
                                      : null),
                              const SizedBox(height: 16),
                              _buildTextField(
                                  middleNameController,
                                  'Al Doilea Prenume (Opțional)',
                                  Icons.badge_outlined),
                              const SizedBox(height: 16),
                              _buildTextField(lastNameController, 'Nume',
                                  Icons.badge_outlined,
                                  validator: (v) => v?.trim().isEmpty ?? true
                                      ? 'Câmp obligatoriu'
                                      : null),
                              const SizedBox(height: 16),
                              _buildUserTypeField(),
                              const SizedBox(height: 16),
                              if (selectedUserType == 'doctor') ...[
                                _buildCabinetDropdownField(),
                                const SizedBox(height: 16),
                              ],
                              _buildPhotoField(),
                              const SizedBox(height: 32),
                              MouseRegion(
                                onEnter: (_) =>
                                    setState(() => _isHovered = true),
                                onExit: (_) =>
                                    setState(() => _isHovered = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isHovered
                                          ? const Color(0xFF004D40)
                                          : const Color(0xFF00796B),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 18),
                                      elevation: _isHovered ? 8 : 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'Înregistrare',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Ai deja cont? ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                'Autentifică-te',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText,
    IconData prefixIcon, {
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF00796B)),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00796B), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildUserTypeField() {
    return DropdownButtonFormField<String>(
      value: selectedUserType,
      onChanged: (String? newValue) {
        setState(() {
          selectedUserType = newValue;
          // Clear cabinet selection if user switches to client
          if (newValue == 'client') {
            selectedCabinetId = null;
          }
        });
      },
      items: const [
        DropdownMenuItem<String>(
          value: 'doctor',
          child: Text('Doctor / Lucrător Cabinet Veterinar'),
        ),
        DropdownMenuItem<String>(
          value: 'client',
          child: Text('Client / Proprietar Animal'),
        ),
      ],
      decoration: InputDecoration(
        labelText: 'Tipul utilizatorului *',
        prefixIcon:
            Icon(Icons.person_pin_outlined, color: const Color(0xFF00796B)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00796B), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildCabinetDropdownField() {
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
        labelText: 'Cabinet *',
        prefixIcon: Icon(Icons.business, color: const Color(0xFF00796B)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00796B), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPhotoField() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_image != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_image!,
                  height: 120, width: 120, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: Icon(Icons.photo_camera, color: const Color(0xFF00796B)),
            label: Text(
              _image == null
                  ? 'Încarcă Fotografie (Opțional)'
                  : 'Schimbă Fotografie',
              style: const TextStyle(color: Color(0xFF00796B)),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              side: const BorderSide(color: Color(0xFF00796B), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
