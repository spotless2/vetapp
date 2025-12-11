import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config/api_config.dart';

class ClientPage extends StatefulWidget {
  final Map<String, dynamic> user;

  ClientPage({required this.user});

  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_rounded, size: 26),
            const SizedBox(width: 10),
            const Text(
              'Gestionare Clienți',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selectați o Opțiune',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00796B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gestionați clienții cabinetului dumneavoastră',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            _buildModernClientCard(
              context,
              'Client Nou',
              'Înregistrare client nou în sistem',
              Icons.person_add_rounded,
              const Color(0xFF00796B),
              0,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewClientScreen(user: widget.user),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildModernClientCard(
              context,
              'Client Existent',
              'Căutare și gestionare clienți existenți',
              Icons.search_rounded,
              const Color(0xFF1976D2),
              1,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ExistingClientScreen(user: widget.user),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernClientCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    int index,
    VoidCallback onTap,
  ) {
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0, isHovered ? -4 : 0, 0),
        child: Card(
          elevation: isHovered ? 12 : 4,
          shadowColor: color.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      size: 36,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: color,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NewClientScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  NewClientScreen({required this.user});

  @override
  _NewClientScreenState createState() => _NewClientScreenState();
}

class _NewClientScreenState extends State<NewClientScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _personalIdController = TextEditingController();
  final TextEditingController _identityCardController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedCountryCode = '+40';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add_rounded, size: 26),
            const SizedBox(width: 10),
            const Text(
              'Înregistrare Client Nou',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00796B),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Date Client',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00796B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Completați informațiile clientului',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Informații Personale',
                Icons.person_rounded,
                [
                  _buildTextField('Prenume', Icons.person_outline_rounded,
                      controller: _firstNameController),
                  _buildTextField('Nume', Icons.person_outline_rounded,
                      controller: _lastNameController),
                  _buildPhoneField(),
                  _buildTextField('Email', Icons.email_rounded,
                      controller: _emailController),
                ],
              ),
              const SizedBox(height: 20),
              _buildSection(
                'Documente',
                Icons.document_scanner_rounded,
                [
                  _buildTextField('CNP', Icons.credit_card_rounded,
                      isOptional: true, controller: _personalIdController),
                  _buildTextField('Serie/Număr CI', Icons.badge_rounded,
                      isOptional: true, controller: _identityCardController),
                ],
              ),
              const SizedBox(height: 20),
              _buildSection(
                'Detalii Adiționale',
                Icons.info_rounded,
                [
                  _buildTextField('Adresă', Icons.home_rounded,
                      isOptional: true, controller: _addressController),
                  _buildDateField(
                      context, 'Data Nașterii', Icons.calendar_today_rounded,
                      isOptional: true, controller: _birthDateController),
                  _buildTextField('Note', Icons.note_rounded,
                      maxLines: 3,
                      isOptional: true,
                      controller: _notesController),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final client = await _saveClient();
                    if (client != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClientProfileScreen(
                              client: client, user: widget.user),
                        ),
                      );
                    }
                  }
                },
                icon:
                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                label: const Text(
                  'Înregistrare Client',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildTextField(
    String labelText,
    IconData icon, {
    int maxLines = 1,
    bool isOptional = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText + (isOptional ? ' (Opțional)' : ''),
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
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Vă rugăm să introduceți $labelText';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: DropdownButtonFormField<String>(
              value: _selectedCountryCode,
              decoration: InputDecoration(
                labelText: 'Prefix',
                prefixIcon: Icon(Icons.phone, color: Colors.teal.shade600),
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
              items: ['+40', '+44', '+1', '+33'].map((code) {
                return DropdownMenuItem(
                  value: code,
                  child: Text(code),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountryCode = value;
                });
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Număr Telefon',
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
                  return 'Vă rugăm să introduceți numărul de telefon';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String labelText,
    IconData icon, {
    bool isOptional = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: labelText + (isOptional ? ' (Opțional)' : ''),
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
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Colors.teal.shade400,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (pickedDate != null) {
            controller?.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _saveClient() async {
    final Map<String, String> clientData = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'phone': '$_selectedCountryCode${_phoneController.text}',
      'personalId': _personalIdController.text,
      'identityCard': _identityCardController.text,
      'address': _addressController.text,
      'notes': _notesController.text,
      'createdBy': widget.user['id'].toString(),
      'cabinetId': widget.user['cabinetId'].toString(),
    };

    if (_birthDateController.text.isNotEmpty) {
      clientData['birthDate'] = _birthDateController.text;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/clients'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(clientData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la salvarea clientului'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eroare de conexiune'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }
}

class ExistingClientScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  ExistingClientScreen({required this.user});

  @override
  _ExistingClientScreenState createState() => _ExistingClientScreenState();
}

class _ExistingClientScreenState extends State<ExistingClientScreen> {
  List<dynamic> clients = [];
  List<dynamic> filteredClients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    setState(() => isLoading = true);
    final cabinetId = widget.user['cabinetId'];

    try {
      final response =
          await http.get(Uri.parse('${ApiConfig.baseUrl}/clients/$cabinetId'));

      if (response.statusCode == 200) {
        setState(() {
          clients = jsonDecode(response.body);
          filteredClients = clients;
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nu s-au putut încărca clienții'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eroare de conexiune'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isLoading = false);
    }
  }

  void _filterClients(String query) {
    setState(() {
      filteredClients = clients.where((client) {
        final name = client['firstName'] + ' ' + client['lastName'];
        return name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 26),
            const SizedBox(width: 10),
            const Text(
              'Căutare Client',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Căutați Clienți',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Căutare după Nume',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Color(0xFF1976D2)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF1976D2), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  onChanged: _filterClients,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF1976D2)),
                    ),
                  )
                : filteredClients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nu s-au găsit clienți',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredClients.length,
                        itemBuilder: (context, index) {
                          final client = filteredClients[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF1976D2).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Color(0xFF1976D2),
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                '${client['firstName']} ${client['lastName']}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF424242),
                                ),
                              ),
                              subtitle: client['email'] != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        client['email'],
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                  : null,
                              trailing: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF1976D2).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFF1976D2),
                                  size: 16,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClientProfileScreen(
                                      client: client,
                                      user: widget.user,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class ClientProfileScreen extends StatefulWidget {
  Map<String, dynamic> client;
  final Map<String, dynamic> user;

  ClientProfileScreen({required this.client, required this.user});

  @override
  _ClientProfileScreenState createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> pets = [];
  List<dynamic> visits = [];
  bool showDeleted = false;
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    await Future.wait([
      _fetchPets(),
      _fetchVisits(),
    ]);
    setState(() => isLoading = false);
  }

  Future<void> _fetchPets() async {
    try {
      final response = await http.get(Uri.parse(
          '${ApiConfig.baseUrl}/pets/client/${widget.client['id']}'));

      if (response.statusCode == 200) {
        setState(() => pets = jsonDecode(response.body));
      } else {
        _showError('Nu s-au putut încărca animalele');
      }
    } catch (e) {
      _showError('Eroare de conexiune');
    }
  }

  Future<void> _fetchVisits() async {
    try {
      final response = await http.get(Uri.parse(
          '${ApiConfig.baseUrl}/visits/client/${widget.client['id']}?includeDeleted=$showDeleted'));

      if (response.statusCode == 200) {
        setState(() => visits = jsonDecode(response.body));
      } else {
        _showError('Nu s-au putut încărca vizitele');
      }
    } catch (e) {
      _showError('Eroare de conexiune');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Profil Client',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Animale', icon: Icon(Icons.pets_rounded, size: 22)),
            Tab(
                text: 'Vizite',
                icon: Icon(Icons.medical_services_rounded, size: 22)),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(const Color(0xFF00796B)),
              ),
            )
          : Column(
              children: [
                _buildClientDetailsCard(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPetsTab(),
                      _buildVisitsTab(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildClientDetailsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF00796B), const Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detalii Client',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                    onPressed: _navigateToEditClientScreen,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.person_rounded, 'Nume',
                  '${widget.client['firstName']} ${widget.client['lastName']}'),
              const SizedBox(height: 12),
              _buildDetailRow(
                  Icons.email_rounded, 'Email', widget.client['email']),
              const SizedBox(height: 12),
              _buildDetailRow(
                  Icons.phone_rounded, 'Telefon', widget.client['phone']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPetsTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        for (var pet in pets) _buildPetCard(pet),
      ],
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00796B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.pets_rounded,
                color: Color(0xFF00796B),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Specie: ${pet['species']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    'Rasă: ${pet['breed']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    'Culoare: ${pet['color']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon:
                      const Icon(Icons.edit_rounded, color: Color(0xFF00796B)),
                  onPressed: () => _editPet(pet),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B).withOpacity(0.1),
                  ),
                ),
                const SizedBox(height: 4),
                IconButton(
                  icon: const Icon(Icons.delete_rounded,
                      color: Color(0xFFD32F2F)),
                  onPressed: () => _deletePet(pet),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F).withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitsTab() {
    return Column(
      children: [
        _buildVisitsHeader(),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              for (var visit in visits) _buildVisitCard(visit),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisitsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00796B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  showDeleted
                      ? Icons.delete_rounded
                      : Icons.check_circle_rounded,
                  color: const Color(0xFF00796B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                showDeleted ? 'Fișe șterse' : 'Fișe active',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424242),
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            icon: Icon(
              showDeleted
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              size: 18,
            ),
            label: Text(
              showDeleted ? 'Arată active' : 'Arată șterse',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00796B),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              setState(() {
                showDeleted = !showDeleted;
                _fetchVisits();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVisitCard(Map<String, dynamic> visit) {
    final DateTime visitDate = DateTime.parse(visit['createdAt']);
    final String formattedDate =
        "${visitDate.day}/${visitDate.month}/${visitDate.year}";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00796B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Color(0xFF00796B),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit['animal']['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF424242),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      visit['visitReason'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildVisitActions(visit),
            ],
          ),
        ),
        onTap: () => _viewVisitDetails(visit),
      ),
    );
  }

  Widget _buildVisitActions(Map<String, dynamic> visit) {
    if (showDeleted) {
      return IconButton(
        icon: const Icon(Icons.restore_rounded, color: Color(0xFF689F38)),
        onPressed: () => _restoreVisit(visit),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFF689F38).withOpacity(0.1),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_rounded, color: Color(0xFF00796B)),
          onPressed: () => _editVisit(visit),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF00796B).withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.receipt_rounded, color: Color(0xFF1976D2)),
          onPressed: () => _generateInvoice(visit),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.delete_rounded, color: Color(0xFFD32F2F)),
          onPressed: () => _deleteVisit(visit),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F).withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        if (_tabController.index == 0) {
          _addNewPet();
        } else {
          _addNewVisit();
        }
      },
      backgroundColor: const Color(0xFF00796B),
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label:
          Text(_tabController.index == 0 ? 'Adaugă Animal' : 'Adaugă Vizită'),
    );
  }

  // Navigation methods
  void _navigateToEditClientScreen() async {
    final updatedClient = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditClientScreen(
          user: widget.user,
          client: widget.client,
        ),
      ),
    );

    if (updatedClient != null) {
      setState(() => widget.client = updatedClient);
    }
  }

  // Action methods (implement these based on your needs)
  void _addNewPet() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalInfoScreen(client: widget.client),
      ),
    );
    if (result == true) _fetchPets();
  }

  void _editPet(Map<String, dynamic> pet) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalInfoScreen(
          client: widget.client,
          pet: pet,
        ),
      ),
    );
    if (result == true) _fetchPets();
  }

  void _deletePet(Map<String, dynamic> pet) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmare Ștergere'),
          content: Text('Sunteți sigur că doriți să ștergeți acest animal?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Anulează'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Șterge'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        final response = await http.delete(
          Uri.parse('${ApiConfig.baseUrl}/pets/${pet['id']}'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Animalul a fost șters cu succes')),
          );
          _fetchPets();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Eroare la ștergerea animalului'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare de conexiune'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addNewVisit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisitInfoScreen(
          client: widget.client,
          user: widget.user,
        ),
      ),
    );
    if (result == true) _fetchVisits();
  }

  void _editVisit(Map<String, dynamic> visit) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisitInfoScreen(
          client: widget.client,
          visit: visit,
          user: widget.user,
        ),
      ),
    );
    if (result == true) {
      _fetchVisits();
    }
  }

  void _deleteVisit(Map<String, dynamic> visit) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmare Ștergere'),
          content: Text(
            showDeleted
                ? 'Sunteți sigur că doriți să ștergeți PERMANENT această vizită?'
                : 'Sunteți sigur că doriți să mutați această vizită la "Fișe șterse"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Anulează'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Șterge'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        final String apiUrl = showDeleted
            ? '${ApiConfig.baseUrl}/visits/final/${visit['id']}'
            : '${ApiConfig.baseUrl}/visits/soft/${visit['id']}';

        final response = await http.delete(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vizita a fost ștearsă cu succes')),
          );
          _fetchVisits();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Eroare la ștergerea vizitei'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare de conexiune'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _restoreVisit(Map<String, dynamic> visit) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/visits/${visit['id']}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          ...visit,
          'isDeleted': false,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vizita a fost restaurată cu succes')),
        );
        _fetchVisits();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la restaurarea vizitei'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eroare de conexiune'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewVisitDetails(Map<String, dynamic> visit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisitDetailScreen(visit: visit),
      ),
    );
  }

  void _generateInvoice(Map<String, dynamic> visit) {
    // Implement invoice generation
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class VisitDetailScreen extends StatelessWidget {
  final Map<String, dynamic> visit;

  VisitDetailScreen({required this.visit});

  @override
  Widget build(BuildContext context) {
    final DateTime visitDate = DateTime.parse(visit['createdAt']);
    final String formattedDate =
        "${visitDate.day}/${visitDate.month}/${visitDate.year}";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Detalii Vizită',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSection(
              'Informații Vizită',
              Icons.medical_services,
              [
                _buildDetailRow('Vizita nr.:', '${visit['id']}'),
                _buildDetailRow('Data:', formattedDate),
                _buildDetailRow('Motiv Vizită:', visit['visitReason']),
                _buildDetailRow('Observații:', visit['observations']),
                _buildDetailRow('Diagnostic:', visit['diagnosis']),
                _buildDetailRow('Recomandări:', visit['recommendations']),
              ],
            ),
            SizedBox(height: 16),
            _buildSection(
              'Informații Animal',
              Icons.pets,
              [
                _buildDetailRow('Nume:', visit['animal']['name']),
                _buildDetailRow('Specie:', visit['animal']['species']),
              ],
            ),
            SizedBox(height: 16),
            _buildSection(
              'Tratament',
              Icons.medication,
              [
                _buildDetailRow('Nume:', visit['treatment']['name']),
                _buildDetailRow('Cantitate:',
                    '${visit['treatmentQuantity']} ${visit['treatment']['unit']}'),
                _buildDetailRow('Preț:', '${visit['treatment']['price']} RON'),
              ],
            ),
            SizedBox(height: 16),
            _buildSection(
              'Manopere',
              Icons.build,
              [
                ...visit['procedures'].map<Widget>((procedure) {
                  return _buildDetailRow(
                    procedure['name'],
                    '${procedure['price']} RON',
                  );
                }).toList(),
              ],
            ),
            SizedBox(height: 16),
            _buildSection(
              'Informații Client',
              Icons.person,
              [
                _buildDetailRow('Nume:',
                    '${visit['client']['firstName']} ${visit['client']['lastName']}'),
                _buildDetailRow('Email:', visit['client']['email']),
                _buildDetailRow('Telefon:', visit['client']['phone']),
              ],
            ),
            SizedBox(height: 16),
            _buildSection(
              'Informații Administrative',
              Icons.admin_panel_settings,
              [
                _buildDetailRow('Creat de:', visit['createdBy']),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle generate invoice
                },
                icon: const Icon(Icons.receipt_rounded, size: 22),
                label: const Text(
                  'Generare Factură',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF424242),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimalInfoScreen extends StatefulWidget {
  final Map<String, dynamic> client;
  final Map<String, dynamic>? pet;

  AnimalInfoScreen({required this.client, this.pet});
  @override
  _AnimalInfoScreenState createState() => _AnimalInfoScreenState();
}

class _AnimalInfoScreenState extends State<AnimalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Define TextEditingController for each field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _distinctiveSignsController =
      TextEditingController();
  final TextEditingController _animalCardController = TextEditingController();
  final TextEditingController _insuranceNumberController =
      TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _microchipCodeController =
      TextEditingController();
  final TextEditingController _passportSeriesController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _healthPlanController = TextEditingController();
  final TextEditingController _patientAlertsController =
      TextEditingController();
  final TextEditingController _internalNotesController =
      TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      _initializeFields(widget.pet!);
    }
  }

  bool _isApproximate = false;
  String? _selectedSpecies;
  String? _selectedBreed;

  void _initializeFields(Map<String, dynamic> pet) {
    _nameController.text = pet['name'] ?? '';
    _colorController.text = pet['color'] ?? '';
    _photoController.text = pet['photo'] ?? '';
    _allergiesController.text = pet['allergies'] ?? '';
    _distinctiveSignsController.text = pet['distinctiveMarks'] ?? '';
    _animalCardController.text = pet['animalCardNumber'] ?? '';
    _insuranceNumberController.text = pet['insuranceNumber'] ?? '';
    _bloodGroupController.text = pet['bloodGroup'] ?? '';
    _microchipCodeController.text = pet['microchipCode'] ?? '';
    _passportSeriesController.text = pet['passportSeries'] ?? '';
    _descriptionController.text = pet['description'] ?? '';
    _healthPlanController.text = pet['healthPlan'] ?? '';
    _patientAlertsController.text = pet['patientAlerts'] ?? '';
    _internalNotesController.text = pet['internalNotes'] ?? '';
    _selectedSpecies = pet['species'];
    _selectedBreed = pet['breed'];
    _selectedGender = pet['gender'];
    _selectedReproductiveStatus = pet['reproductiveStatus'];

    if (pet['birthDate'] != null) {
      DateTime birthDate = DateTime.parse(pet['birthDate']);
      _birthDateController.text = "${birthDate.toLocal()}"
          .split(' ')[0]; // Format the date as yyyy-MM-dd
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Informații Animal',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSection(
                'Informații de Bază',
                Icons.pets,
                [
                  _buildTextField('Nume', Icons.pets,
                      controller: _nameController),
                  _buildDropdownField('Specie', ['Caine', 'Pisica', 'Altceva'],
                      _selectedSpecies, (value) {
                    setState(() => _selectedSpecies = value);
                  }),
                  _buildDropdownField(
                      'Rasă', ['Rasa 1', 'Rasa 2', 'Rasa 3'], _selectedBreed,
                      (value) {
                    setState(() => _selectedBreed = value);
                  }),
                  _buildDropdownField(
                      'Gen', ['Mascul', 'Femelă'], _selectedGender, (value) {
                    setState(() => _selectedGender = value);
                  }),
                  _buildDateField(context),
                  _buildTextField('Culoare', Icons.color_lens,
                      controller: _colorController),
                ],
              ),
              SizedBox(height: 16),
              _buildSection(
                'Detalii Medicale',
                Icons.medical_services,
                [
                  _buildDropdownField(
                      'Status Reproductiv',
                      ['Necastrat', 'Castrat'],
                      _selectedReproductiveStatus, (value) {
                    setState(() => _selectedReproductiveStatus = value);
                  }),
                  _buildTextField('Alergii', Icons.warning,
                      isOptional: true, controller: _allergiesController),
                  _buildTextField('Grupa Sanguină', Icons.bloodtype,
                      isOptional: true, controller: _bloodGroupController),
                  _buildTextField('Plan de Sănătate', Icons.health_and_safety,
                      isOptional: true, controller: _healthPlanController),
                  _buildTextField(
                      'Alerte Pacient', Icons.notification_important,
                      isOptional: true, controller: _patientAlertsController),
                ],
              ),
              SizedBox(height: 16),
              _buildSection(
                'Documente',
                Icons.document_scanner,
                [
                  _buildTextField('Carnet Animal', Icons.book,
                      isOptional: true, controller: _animalCardController),
                  _buildTextField('Număr Asigurare', Icons.security,
                      isOptional: true, controller: _insuranceNumberController),
                  _buildTextField('Cod Microcip', Icons.qr_code,
                      isOptional: true, controller: _microchipCodeController),
                  _buildTextField('Serie Pașaport', Icons.book,
                      isOptional: true, controller: _passportSeriesController),
                ],
              ),
              SizedBox(height: 16),
              _buildSection(
                'Informații Adiționale',
                Icons.more_horiz,
                [
                  _buildTextField('Poză', Icons.photo,
                      isOptional: true, controller: _photoController),
                  _buildTextField('Semne Distinctive', Icons.pets,
                      isOptional: true,
                      controller: _distinctiveSignsController),
                  _buildTextField('Descriere', Icons.description,
                      controller: _descriptionController),
                  _buildTextField('Note Interne', Icons.notes,
                      maxLines: 3,
                      isOptional: true,
                      controller: _internalNotesController),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _savePet();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 18),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Salvează',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
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

  Future<void> _savePet() async {
    final url = widget.pet != null
        ? '${ApiConfig.baseUrl}/pets/${widget.pet!['id']}'
        : '${ApiConfig.baseUrl}/pets';

    final requestBody = <String, dynamic>{
      'clientId': widget.client['id'], // Add the clientId
      'name': _nameController.text,
      'species': _selectedSpecies,
      'breed': _selectedBreed,
      'gender': _selectedGender,
      'birthDate': _birthDateController.text,
      'color': _colorController.text,
      'reproductiveStatus': _selectedReproductiveStatus,
      'photo': _photoController.text,
      'allergies': _allergiesController.text,
      'distinctiveMarks': _distinctiveSignsController.text,
      'animalCardNumber': _animalCardController.text,
      'insuranceNumber': _insuranceNumberController.text,
      'bloodGroup': _bloodGroupController.text,
      'microchipCode': _microchipCodeController.text,
      'passportSeries': _passportSeriesController.text,
      'description': _descriptionController.text,
      'healthPlan': _healthPlanController.text,
      'patientAlerts': _patientAlertsController.text,
      'internalNotes': _internalNotesController.text,
    };
    final response = await http.Request(
      widget.pet != null ? 'PUT' : 'POST',
      Uri.parse(url),
    )
      ..headers.addAll(<String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      })
      ..body = jsonEncode(requestBody);

    final streamedResponse = await response.send();
    final responseBody = await http.Response.fromStream(streamedResponse);

    if (responseBody.statusCode == 201 || responseBody.statusCode == 200) {
      // Pet saved successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Animalul a fost salvat cu succes')),
      );
      Navigator.pop(context, true);
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la salvarea animalului')),
      );
    }
  }

  String? _selectedGender;
  String? _selectedReproductiveStatus;

  Widget _buildTextField(String labelText, IconData icon,
      {int maxLines = 1,
      bool isOptional = false,
      required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText + (isOptional ? ' (Opțional)' : ''),
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
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Vă rugăm să introduceți $labelText';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(String labelText, List<String> items,
      String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: labelText,
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
        value: selectedValue,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vă rugăm să selectați $labelText';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _birthDateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Data Nașterii',
          prefixIcon: Icon(Icons.calendar_today, color: Colors.teal.shade600),
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
        onTap: () => _selectDate(context),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vă rugăm să selectați data nașterii';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _birthDateController.text = "${picked.toLocal()}"
            .split(' ')[0]; // Format the date as yyyy-MM-dd
      });
    }
  }
}

class VisitInfoScreen extends StatefulWidget {
  final Map<String, dynamic> client;
  final Map<String, dynamic>? visit;
  final Map<String, dynamic>? user;

  VisitInfoScreen({required this.client, this.visit, this.user});

  @override
  _VisitInfoScreenState createState() => _VisitInfoScreenState();
}

class _VisitInfoScreenState extends State<VisitInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Variables for dropdowns
  List<Map<String, dynamic>> animals = [];
  final List<Map<String, dynamic>> treatments = [
    {'id': 1, 'name': 'Treatment 1', 'unit': 'mg', 'price': 10.0},
    {'id': 2, 'name': 'Treatment 2', 'unit': 'ml', 'price': 20.0},
    {'id': 3, 'name': 'Treatment 3', 'unit': 'g', 'price': 30.0},
  ];
  final List<Map<String, dynamic>> procedures = [
    {'id': 1, 'name': 'Procedure 1', 'price': 100.0},
    {'id': 2, 'name': 'Procedure 2', 'price': 200.0},
    {'id': 3, 'name': 'Procedure 3', 'price': 300.0},
  ];

  // Dummy variable to control the visibility of the "Animal" dropdown
  final bool showAnimalDropdown = true;

  Map<String, dynamic>? _selectedAnimal;
  Map<String, dynamic>? _selectedTreatment;
  List<Map<String, dynamic>> _selectedProcedures = [];
  final TextEditingController _treatmentQuantityController =
      TextEditingController();
  final TextEditingController _visitReasonController = TextEditingController();
  final TextEditingController _observationsController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _recommendationsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAnimals();
    if (widget.visit != null) {
      _initializeFields(widget.visit!);
    }
  }

  Future<void> _fetchAnimals() async {
    final clientId =
        widget.client['id']; // Assuming client ID is available in widget.client
    final url = '${ApiConfig.baseUrl}/pets/client/$clientId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          animals = data
              .map((animal) => {
                    'id': animal['id'],
                    'name': animal['name'],
                    'species': animal['species'],
                  })
              .toList();
        });
      } else {
        // Handle error
        print('Failed to load animals');
      }
    } catch (e) {
      // Handle error
      print('Error: $e');
    }
  }

  void _initializeFields(Map<String, dynamic> visit) {
    _visitReasonController.text = visit['visitReason'] ?? '';
    _observationsController.text = visit['observations'] ?? '';
    _diagnosisController.text = visit['diagnosis'] ?? '';
    _recommendationsController.text = visit['recommendations'] ?? '';

    // Handle animal data
    final animalData = visit['animal'];
    if (animalData is String) {
      final animalJson = json.decode(animalData);
      // Find matching animal or create new map with same structure
      _selectedAnimal = animals.firstWhere(
        (animal) => animal['id'] == animalJson['id'],
        orElse: () => Map<String, dynamic>.from(animalJson),
      );
    } else if (animalData is Map) {
      _selectedAnimal = animals.firstWhere(
        (animal) => animal['id'] == animalData['id'],
        orElse: () =>
            Map<String, dynamic>.from(animalData as Map<String, dynamic>),
      );
    }

    // Handle treatment data
    final treatmentData = visit['treatment'];
    if (treatmentData is String) {
      // If it's a JSON string, parse it
      final treatmentJson = json.decode(treatmentData);
      _selectedTreatment = treatments.firstWhere(
        (treatment) => treatment['id'] == treatmentJson['id'],
        orElse: () => treatmentJson, // Use the data from JSON if no match found
      );
    } else {
      // If it's already a Map
      _selectedTreatment = treatments.firstWhere(
        (treatment) => treatment['id'] == treatmentData['id'],
        orElse: () => treatmentData, // Use the data as is if no match found
      );
    }

    _treatmentQuantityController.text =
        visit['treatmentQuantity']?.toString() ?? '';

    // Handle procedures
    final proceduresData = visit['procedures'];
    if (proceduresData is String) {
      // If it's a JSON string, parse it
      _selectedProcedures =
          List<Map<String, dynamic>>.from(json.decode(proceduresData));
    } else {
      // If it's already a List
      _selectedProcedures =
          List<Map<String, dynamic>>.from(proceduresData ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Informații Vizită',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSection(
                'Detalii Vizită',
                Icons.medical_services,
                [
                  _buildTextField('Motiv Vizită', Icons.medical_services,
                      controller: _visitReasonController),
                  _buildTextField('Observații', Icons.note,
                      maxLines: 3, controller: _observationsController),
                  _buildTextField('Diagnostic', Icons.assignment,
                      controller: _diagnosisController),
                  _buildTextField('Recomandări', Icons.recommend,
                      maxLines: 3, controller: _recommendationsController),
                ],
              ),
              SizedBox(height: 16),
              _buildSection(
                'Animal și Tratament',
                Icons.pets,
                [
                  if (showAnimalDropdown) _buildAnimalDropdownField(),
                  _buildTreatmentDropdownField(),
                ],
              ),
              SizedBox(height: 16),
              _buildSection(
                'Manopere',
                Icons.build,
                [
                  _buildMultiSelectDropdownField('Manopere', procedures,
                      (value) {
                    setState(() {
                      if (_selectedProcedures.contains(value)) {
                        _selectedProcedures.remove(value);
                      } else {
                        if (value != null) {
                          _selectedProcedures.add(value);
                        }
                      }
                    });
                  }),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _saveVisit();
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Salvează',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
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

  Future<void> _saveVisit() async {
    final url = widget.visit != null
        ? '${ApiConfig.baseUrl}/visits/${widget.visit!['id']}'
        : '${ApiConfig.baseUrl}/visits';

    final requestBody = <String, dynamic>{
      'visitReason': _visitReasonController.text,
      'observations': _observationsController.text,
      'diagnosis': _diagnosisController.text,
      'recommendations': _recommendationsController.text,
      'animal': _selectedAnimal,
      'treatment': _selectedTreatment,
      'treatmentQuantity': _treatmentQuantityController.text,
      'procedures': _selectedProcedures,
      'client': widget.client,
      'clientId': widget.client['id'],
      if (widget.visit == null)
        'createdBy': (widget.user?['firstName'] ?? '') +
            ' ' +
            (widget.user?['lastName'] ?? ''),
      if (widget.visit != null)
        'updatedBy': (widget.user?['firstName'] ?? '') +
            ' ' +
            (widget.user?['lastName'] ?? ''),
    };

    final response = await http.Request(
      widget.visit != null ? 'PUT' : 'POST',
      Uri.parse(url),
    )
      ..headers.addAll(<String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      })
      ..body = jsonEncode(requestBody);

    final streamedResponse = await response.send();
    final responseBody = await http.Response.fromStream(streamedResponse);

    if (responseBody.statusCode == 201 || responseBody.statusCode == 200) {
      // Visit saved successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vizita a fost salvata cu succes')),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la adaugarea vizitei')),
      );
    }
  }

  Widget _buildTextField(String labelText, IconData icon,
      {int maxLines = 1, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
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
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vă rugăm să introduceți $labelText';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAnimalDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: 'Animal',
          prefixIcon: Icon(Icons.pets, color: Colors.teal.shade600),
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
        value: _selectedAnimal?['id'],
        items: animals.map((animal) {
          return DropdownMenuItem<int>(
            value: animal['id'],
            child: Text(animal['name'] ?? ''),
          );
        }).toList(),
        onChanged: (selectedId) {
          if (selectedId != null) {
            setState(() {
              final selectedAnimal =
                  animals.firstWhere((animal) => animal['id'] == selectedId);
              _selectedAnimal = {
                'id': selectedAnimal['id'],
                'name': selectedAnimal['name'],
                'species': selectedAnimal['species'],
              };
            });
          }
        },
        validator: (value) {
          if (value == null) {
            return 'Vă rugăm să selectați un animal';
          }
          return null;
        },
        isExpanded: true,
      ),
    );
  }

  Widget _buildTreatmentDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<Map<String, dynamic>>(
              decoration: InputDecoration(
                labelText: 'Tratament',
                prefixIcon:
                    Icon(Icons.medical_services, color: Colors.teal.shade600),
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
              items: treatments.map((treatment) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: treatment,
                  child: Text(treatment['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTreatment = value;
                });
              },
              value: _selectedTreatment,
              validator: (value) {
                if (value == null) {
                  return 'Vă rugăm să selectați Tratament';
                }
                return null;
              },
            ),
          ),
          SizedBox(width: 10),
          if (_selectedTreatment != null)
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _treatmentQuantityController,
                decoration: InputDecoration(
                  labelText: 'Cantitate',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.teal.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: Colors.teal.shade400, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vă rugăm să introduceți Cantitate';
                  }
                  return null;
                },
              ),
            ),
          if (_selectedTreatment != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                _selectedTreatment?['unit'] ?? '',
                style: TextStyle(
                  color: Colors.teal.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectDropdownField(
      String labelText,
      List<Map<String, dynamic>> items,
      ValueChanged<Map<String, dynamic>?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(Icons.check_box, color: Colors.teal.shade600),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () async {
                final List<Map<String, dynamic>>? results =
                    await showDialog<List<Map<String, dynamic>>>(
                  context: context,
                  builder: (BuildContext context) {
                    return MultiSelectDialog(
                      items: items,
                      initiallySelectedItems: _selectedProcedures,
                    );
                  },
                );
                if (results != null) {
                  setState(() {
                    _selectedProcedures = results;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Selectează Manopere',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedProcedures.map((procedure) {
                  return Chip(
                    label: Text(
                      procedure['name'],
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.teal.shade400,
                    deleteIconColor: Colors.white,
                    onDeleted: () {
                      setState(() {
                        _selectedProcedures.remove(procedure);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MultiSelectDialog extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> initiallySelectedItems;

  MultiSelectDialog(
      {required this.items, required this.initiallySelectedItems});

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  List<Map<String, dynamic>> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initiallySelectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selectează Manopere',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: ListBody(
                  children: widget.items.map((item) {
                    final isSelected = _selectedItems.contains(item);
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.teal.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Colors.teal.shade300
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: CheckboxListTile(
                        value: isSelected,
                        title: Text(
                          item['name'],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.teal.shade700
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        secondary: Text(
                          '${item['price']} RON',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Colors.teal.shade600,
                        checkColor: Colors.white,
                        onChanged: (bool? selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedItems.add(item);
                            } else {
                              _selectedItems.remove(item);
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Anulează',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedItems),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Salvează',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditClientScreen extends StatelessWidget {
  final Map<String, dynamic> client;
  final Map<String, dynamic> user;
  final _formKey = GlobalKey<FormState>();

  EditClientScreen({required this.client, required this.user}) {
    // Initialize the controllers with client details
    _firstNameController.text = client['firstName'] ?? '';
    _lastNameController.text = client['lastName'] ?? '';
    _emailController.text = client['email'] ?? '';
    _phoneController.text = client['phone'] ?? '';
    _personalIdController.text = client['personalId'] ?? '';
    _identityCardController.text = client['identityCard'] ?? '';
    _addressController.text = client['address'] ?? '';
    _birthDateController.text = client['birthDate'] ?? '';
    _notesController.text = client['notes'] ?? '';
  }

  // Define TextEditingController for each field
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _personalIdController = TextEditingController();
  final TextEditingController _identityCardController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Editare Client',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSection(
                'Informații Personale',
                Icons.person,
                [
                  _buildTextField('Prenume', Icons.person_outline,
                      controller: _firstNameController),
                  _buildTextField('Nume', Icons.person_outline,
                      controller: _lastNameController),
                  _buildTextField('Email', Icons.email,
                      controller: _emailController),
                  _buildPhoneField(),
                ],
              ),
              SizedBox(height: 16),
              _buildSection(
                'Documente',
                Icons.document_scanner,
                [
                  _buildTextField('CNP', Icons.credit_card,
                      isOptional: true, controller: _personalIdController),
                  _buildTextField('Serie/Număr CI', Icons.badge,
                      isOptional: true, controller: _identityCardController),
                ],
              ),
              SizedBox(height: 16),
              _buildSection(
                'Detalii Adiționale',
                Icons.more_horiz,
                [
                  _buildTextField('Adresă', Icons.home,
                      isOptional: true, controller: _addressController),
                  _buildDateField(
                      context, 'Data Nașterii', Icons.calendar_today,
                      isOptional: true, controller: _birthDateController),
                  _buildTextField('Note', Icons.note,
                      maxLines: 3,
                      isOptional: true,
                      controller: _notesController),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final updatedClient = await _updateClient();
                      if (updatedClient != null) {
                        Navigator.pop(context, updatedClient);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 18),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Salvează',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildTextField(String label, IconData icon,
      {bool isOptional = false,
      int maxLines = 1,
      required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label + (isOptional ? ' (Opțional)' : ''),
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
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Vă rugăm să introduceți $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField('Telefon', Icons.phone,
        controller: _phoneController);
  }

  Widget _buildDateField(BuildContext context, String label, IconData icon,
      {bool isOptional = false, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label + (isOptional ? ' (Opțional)' : ''),
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
        onTap: () async {
          FocusScope.of(context).requestFocus(new FocusNode());
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Colors.teal.shade400,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            controller.text = DateFormat('yyyy-MM-dd').format(picked);
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _updateClient() async {
    final updatedBy = user['id'];
    final Map<String, String> clientData = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'personalId': _personalIdController.text,
      'identityCard': _identityCardController.text,
      'address': _addressController.text,
      'notes': _notesController.text,
      'updatedBy': updatedBy.toString(),
    };

    if (_birthDateController.text.isNotEmpty &&
        _birthDateController.text != 'Invalid date') {
      clientData['birthDate'] = _birthDateController.text;
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/clients/$updatedBy'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(clientData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Handle error
      ScaffoldMessenger.of(_formKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Failed to save client')),
      );
      return null;
    }
  }
}
