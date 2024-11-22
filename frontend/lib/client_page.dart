import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClientPage extends StatelessWidget {
  final Map<String, dynamic> user;

  ClientPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clienti'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCard(
              context,
              'Client Nou',
              'Inregistrare client nou',
              Icons.person_add,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewClientScreen(user: user)),
                );
              },
            ),
            SizedBox(height: 20),
            _buildCard(
              context,
              'Client Existent',
              'Cautare client existent',
              Icons.search,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExistingClientScreen(user: user)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String subtitle,
      IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.blueAccent),
        title: Text(title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward, color: Colors.blueAccent),
        onTap: onTap,
      ),
    );
  }
}

class NewClientScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final _formKey = GlobalKey<FormState>();

  NewClientScreen({required this.user});

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
      appBar: AppBar(
        title: Text('Informatii Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Prenume și Nume', Icons.person,
                  controller: _firstNameController),
              _buildTextField('Nume', Icons.person_outline,
                  controller: _lastNameController),
              _buildTextField('Email', Icons.email,
                  controller: _emailController),
              _buildPhoneField(),
              _buildTextField(
                  'Cod Numeric Personal (Optional)', Icons.credit_card,
                  isOptional: true, controller: _personalIdController),
              _buildTextField(
                  'Seria și Numărul Buletinului (Optional)', Icons.badge,
                  isOptional: true, controller: _identityCardController),
              _buildTextField('Adresă (Optional)', Icons.home,
                  isOptional: true, controller: _addressController),
              _buildDateField(
                  context, 'Data Nașterii (Optional)', Icons.calendar_today,
                  isOptional: true, controller: _birthDateController),
              _buildTextField('Note (Optional)', Icons.note,
                  maxLines: 3, isOptional: true, controller: _notesController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final client = await _saveClient();
                    if (client != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ClientProfileScreen(client: client, user: user),
                        ),
                      );
                    }
                  }
                },
                child: Text('Inregistrare Client'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _saveClient() async {
    final Map<String, String> clientData = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'personalId': _personalIdController.text,
      'identityCard': _identityCardController.text,
      'address': _addressController.text,
      'notes': _notesController.text,
      'createdBy': user['id'].toString(), // Use user ID for createdBy
      'cabinetId': user['cabinetId'].toString(), // Use cabinet ID from user
    };

    if (_birthDateController.text.isNotEmpty &&
        _birthDateController.text != 'Invalid date') {
      clientData['birthDate'] = _birthDateController.text;
    }

    final response = await http.post(
      Uri.parse('http://localhost:3000/clients'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(clientData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      // Handle error
      ScaffoldMessenger.of(_formKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Failed to save client')),
      );
      return null;
    }
  }

  Widget _buildTextField(String labelText, IconData icon,
      {int maxLines = 1,
      bool isOptional = false,
      TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
        ),
        maxLines: maxLines,
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Prefix Țară',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              items: ['+1', '+40', '+44', '+91'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {},
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Număr Telefon',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vă rugăm să introduceți Număr Telefon';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String labelText, IconData icon,
      {bool isOptional = false, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
        ),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            controller?.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          }
        },
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Vă rugăm să introduceți $labelText';
          }
          return null;
        },
      ),
    );
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

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    final cabinetId = widget.user['cabinetId'];
    final response =
        await http.get(Uri.parse('http://localhost:3000/clients/$cabinetId'));

    if (response.statusCode == 200) {
      setState(() {
        clients = jsonDecode(response.body);
        filteredClients = clients;
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load clients')),
      );
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
      appBar: AppBar(
        title: Text('Căutare Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Căutare după Nume',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _filterClients(value);
              },
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredClients.length,
                itemBuilder: (context, index) {
                  final client = filteredClients[index];
                  return ListTile(
                    leading: Icon(Icons.person),
                    title: Text('${client['firstName']} ${client['lastName']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ClientProfileScreen(
                                client: client, user: widget.user)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientProfileScreen extends StatefulWidget {
  final Map<String, dynamic> client;
  final Map<String, dynamic> user;

  ClientProfileScreen({required this.client, required this.user});

  @override
  _ClientProfileScreenState createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  List<dynamic> pets = [];
  List<dynamic> visits = [];
  bool showDeleted = false;

  @override
  void initState() {
    super.initState();
    _fetchPets();
    _fetchVisits();
  }

  Future<void> _fetchPets() async {
    final clientId = widget.client['id'];
    final response = await http
        .get(Uri.parse('http://localhost:3000/pets/client/$clientId'));

    if (response.statusCode == 200) {
      setState(() {
        pets = jsonDecode(response.body);
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load pets')),
      );
    }
  }

  Future<void> _fetchVisits() async {
    final clientId = widget.client['id'];
    final response = await http.get(Uri.parse(
        'http://localhost:3000/visits/client/$clientId?includeDeleted=$showDeleted'));

    if (response.statusCode == 200) {
      setState(() {
        visits = jsonDecode(response.body);
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load visits')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildClientDetailsCard(),
            SizedBox(height: 20),
            _buildSectionHeader(
              context,
              'Animale Înregistrate',
              'Adauga Animal',
              () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AnimalInfoScreen(client: widget.client)),
                );
                if (result == true) {
                  _fetchPets(); // Refresh the list if a new pet was added
                }
              },
            ),
            _buildAnimalList(),
            SizedBox(height: 20),
            _buildSectionHeaderForVisits(
              context,
              'Vizite Client',
              'Fisa Noua',
              () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisitInfoScreen(
                        client: widget.client, user: widget.user),
                  ),
                );
                if (result == true) {
                  _fetchVisits(); // Refresh the list if a new visit was added
                }
              },
              showDeleted ? 'Fise sterse' : 'Fise active',
              () {
                setState(() {
                  showDeleted = !showDeleted;
                  _fetchVisits(); // Fetch visits with the updated query parameter
                });
              },
            ),
            _buildVisitList(),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalii Client',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildDetailRow(Icons.person, 'Nume:',
                '${widget.client['firstName']} ${widget.client['lastName']}'),
            _buildDetailRow(Icons.email, 'Email:', widget.client['email']),
            _buildDetailRow(Icons.phone, 'Telefon:', widget.client['phone']),
            // Add more client details here
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 10),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title,
      String buttonText, VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ElevatedButton(
          onPressed: onPressed,
          child: Text(buttonText),
        ),
      ],
    );
  }

  Widget _buildSectionHeaderForVisits(
      BuildContext context,
      String title,
      String buttonText,
      VoidCallback onPressed,
      String secondButtonText,
      VoidCallback secondOnPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Row(
          children: [
            ElevatedButton(
              onPressed: onPressed,
              child: Text(buttonText),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    showDeleted ? Colors.red : null, // Change color if pressed
              ),
              onPressed: secondOnPressed,
              child: Text(secondButtonText),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimalList() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: pets.map((pet) {
          return ListTile(
            leading: Icon(Icons.pets),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Nume: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      TextSpan(
                        text: pet['name'],
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Specie: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      TextSpan(
                        text: pet['species'],
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Rasă: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      TextSpan(
                        text: pet['breed'],
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Culoare: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      TextSpan(
                        text: pet['color'],
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnimalInfoScreen(
                          client: widget.client,
                          pet: pet,
                        ),
                      ),
                    );
                    if (result == true) {
                      _fetchPets(); // Refresh the list if a pet was edited
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final bool? confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmare Stergere'),
                          content: Text(
                              'Sunteți sigur că doriți să ștergeți acest animal?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: Text('Anulează'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: Text('Șterge'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmDelete == true) {
                      // Call the delete API
                      final response = await http.delete(
                        Uri.parse('http://localhost:3000/pets/${pet['id']}'),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                      );

                      if (response.statusCode == 200) {
                        // Pet deleted successfully
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Animalul a fost șters cu succes')),
                        );
                        _fetchPets(); // Refresh the list after deletion
                      } else {
                        // Handle error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Eroare la ștergerea animalului')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVisitList() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: visits.asMap().entries.map((entry) {
          final int index = entry.key + 1; // Start counting from 1
          final visit = entry.value;
          final DateTime visitDate = DateTime.parse(visit['createdAt']);
          final String formattedDate =
              "${visitDate.day}/${visitDate.month}/${visitDate.year}";
          return ListTile(
            leading: Icon(Icons.medical_services),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Fisa $index - ${visit['animal']['name']} - $formattedDate - ${visit['visitReason']}'),
                Row(
                  children: [
                    if (!showDeleted) ...[
                      IconButton(
                        icon: Icon(Icons.edit),
                        tooltip: 'Editare Vizita',
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VisitInfoScreen(
                                  client: widget.client,
                                  visit: visit,
                                  user: widget.user),
                            ),
                          );
                          if (result == true) {
                            _fetchVisits(); // Refresh the list if a new pet was added
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.receipt),
                        tooltip: 'Generare factura',
                        onPressed: () {
                          // Handle generate invoice
                        },
                      ),
                    ],
                    if (showDeleted)
                      IconButton(
                        icon: Icon(Icons.restore, color: Colors.green),
                        tooltip: 'Restaurare Vizita',
                        onPressed: () async {
                          final response = await http.put(
                            Uri.parse(
                                'http://localhost:3000/visits/${visit['id']}'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode({
                              ...visit,
                              'isDeleted': false,
                            }),
                          );

                          if (response.statusCode == 200) {
                            // Visit restored successfully
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Vizita a fost restaurată cu succes')),
                            );
                            _fetchVisits(); // Refresh the list after restoration
                          } else {
                            // Handle error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Eroare la restaurarea vizitei')),
                            );
                          }
                        },
                      ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Sterge Vizita',
                      onPressed: () async {
                        final bool? confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirmare Stergere'),
                              content: Text(
                                showDeleted
                                    ? 'Sunteți sigur că doriți să ștergeți PERMANENT această vizită?'
                                    : 'Sunteți sigur că doriți să mutați această vizită la "Fise sterse"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: Text('Anulează'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: Text('Șterge'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmDelete == true) {
                          // Call the appropriate delete API based on showDeleted state
                          final String apiUrl = showDeleted
                              ? 'http://localhost:3000/visits/final/${visit['id']}'
                              : 'http://localhost:3000/visits/soft/${visit['id']}';

                          final response = await http.delete(
                            Uri.parse(apiUrl),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                          );

                          if (response.statusCode == 200) {
                            // Visit deleted successfully
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Vizita a fost ștearsă cu succes')),
                            );
                            _fetchVisits(); // Refresh the list after deletion
                          } else {
                            // Handle error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Eroare la ștergerea vizitei')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VisitDetailScreen(visit: visit),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
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
      appBar: AppBar(
        title: Text('Detalii Vizita'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vizita ${visit['id']}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Data: $formattedDate', style: TextStyle(fontSize: 18)),
            Text('Motiv Vizita: ${visit['visitReason']}',
                style: TextStyle(fontSize: 18)),
            Text('Observatii: ${visit['observations']}',
                style: TextStyle(fontSize: 18)),
            Text('Diagnostic: ${visit['diagnosis']}',
                style: TextStyle(fontSize: 18)),
            Text('Recomandari: ${visit['recommendations']}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Animal:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Nume: ${visit['animal']['name']}',
                style: TextStyle(fontSize: 18)),
            Text('Specie: ${visit['animal']['species']}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Tratament:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Nume: ${visit['treatment']['name']}',
                style: TextStyle(fontSize: 18)),
            Text(
                'Cantitate: ${visit['treatmentQuantity']} ${visit['treatment']['unit']}',
                style: TextStyle(fontSize: 18)),
            Text('Pret: ${visit['treatment']['price']}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Manopere:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...visit['procedures'].map<Widget>((procedure) {
              return Text('${procedure['name']} - Pret: ${procedure['price']}',
                  style: TextStyle(fontSize: 18));
            }).toList(),
            SizedBox(height: 20),
            Text('Client:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(
                'Nume: ${visit['client']['firstName']} ${visit['client']['lastName']}',
                style: TextStyle(fontSize: 18)),
            Text('Email: ${visit['client']['email']}',
                style: TextStyle(fontSize: 18)),
            Text('Telefon: ${visit['client']['phone']}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Creat de: ${visit['createdBy']}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle generate invoice
              },
              child: Text('Generare factura'),
            ),
          ],
        ),
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
      appBar: AppBar(
        title: Text('Informatii Animal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Nume', Icons.pets, controller: _nameController),
              _buildDropdownField(
                  'Specie', ['Caine', 'Pisica', 'Altceva'], _selectedSpecies,
                  (value) {
                setState(() {
                  _selectedSpecies = value;
                });
              }),
              _buildDropdownField(
                  'Rasa', ['Rasa 1', 'Rasa 2', 'Rasa 3'], _selectedBreed,
                  (value) {
                setState(() {
                  _selectedBreed = value;
                });
              }),
              _buildDropdownField('Gen', ['Mascul', 'Femelă'], _selectedGender,
                  (value) {
                setState(() {
                  _selectedGender = value;
                });
              }),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _birthDateController,
                  decoration: InputDecoration(
                    labelText: 'Data Nașterii',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vă rugăm să selectați data nașterii';
                    }
                    return null;
                  },
                ),
              ),
              _buildTextField('Culoare', Icons.color_lens,
                  controller: _colorController),
              _buildDropdownField(
                  'Status Reproductiv',
                  ['Necastrat', 'Castrat'],
                  _selectedReproductiveStatus, (value) {
                setState(() {
                  _selectedReproductiveStatus = value;
                });
              }),
              _buildTextField('Poză (Optional)', Icons.photo,
                  isOptional: true, controller: _photoController),
              _buildTextField('Alergii (Optional)', Icons.warning,
                  isOptional: true, controller: _allergiesController),
              _buildTextField('Semne Distinctive (Optional)', Icons.pets,
                  isOptional: true, controller: _distinctiveSignsController),
              _buildTextField(
                  'Seria și Numărul (Carnetul Animalului) (Optional)',
                  Icons.book,
                  isOptional: true,
                  controller: _animalCardController),
              _buildTextField('Număr Asigurare (Optional)', Icons.security,
                  isOptional: true, controller: _insuranceNumberController),
              _buildTextField('Grupa Sanguină (Optional)', Icons.bloodtype,
                  isOptional: true, controller: _bloodGroupController),
              _buildTextField('Cod Microcip (Optional)', Icons.qr_code,
                  isOptional: true, controller: _microchipCodeController),
              _buildTextField('Seria Pașaportului (Optional)', Icons.book,
                  isOptional: true, controller: _passportSeriesController),
              _buildTextField('Descriere', Icons.description,
                  controller: _descriptionController),
              _buildTextField('Alege un Plan de Sănătate (Optional)',
                  Icons.health_and_safety,
                  isOptional: true, controller: _healthPlanController),
              _buildTextField(
                  'Alerte Pacient (Optional)', Icons.notification_important,
                  isOptional: true, controller: _patientAlertsController),
              _buildTextField('Note Interne (Optional)', Icons.notes,
                  maxLines: 3,
                  isOptional: true,
                  controller: _internalNotesController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _savePet();
                  }
                },
                child: Text('Salvează'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePet() async {
    final url = widget.pet != null
        ? 'http://localhost:3000/pets/${widget.pet!['id']}'
        : 'http://localhost:3000/pets';

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
      TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
        ),
        maxLines: maxLines,
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
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

  // Dummy data for dropdowns
  final List<Map<String, dynamic>> animals = [
    {'id': 1, 'name': 'Animal 1', 'species': 'Dog'},
    {'id': 2, 'name': 'Animal 2', 'species': 'Cat'},
    {'id': 3, 'name': 'Animal 3', 'species': 'Bird'},
  ];
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
    if (widget.visit != null) {
      _initializeFields(widget.visit!);
    }
  }

  void _initializeFields(Map<String, dynamic> visit) {
    _visitReasonController.text = visit['visitReason'];
    _observationsController.text = visit['observations'];
    _diagnosisController.text = visit['diagnosis'];
    _recommendationsController.text = visit['recommendations'];
    _selectedAnimal =
        animals.firstWhere((animal) => animal['id'] == visit['animal']['id']);
    _selectedTreatment = treatments
        .firstWhere((treatment) => treatment['id'] == visit['treatment']['id']);
    _treatmentQuantityController.text = visit['treatmentQuantity'];
    _selectedProcedures = List<Map<String, dynamic>>.from(visit['procedures']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informatii Vizita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Motiv Vizita', Icons.medical_services,
                  controller: _visitReasonController),
              _buildTextField('Observatii', Icons.note,
                  maxLines: 3, controller: _observationsController),
              _buildTextField('Diagnostic', Icons.assignment,
                  controller: _diagnosisController),
              _buildTextField('Recomandari', Icons.recommend,
                  maxLines: 3, controller: _recommendationsController),
              if (showAnimalDropdown) _buildAnimalDropdownField(),
              _buildTreatmentDropdownField(),
              _buildMultiSelectDropdownField('Manopere', procedures, (value) {
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _saveVisit();
                    Navigator.pop(context, true);
                  }
                },
                child: Text('Salveaza'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveVisit() async {
    final url = widget.visit != null
        ? 'http://localhost:3000/visits/${widget.visit!['id']}'
        : 'http://localhost:3000/visits';

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
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
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
      child: DropdownButtonFormField<Map<String, dynamic>>(
        decoration: InputDecoration(
          labelText: 'Animal',
          prefixIcon: Icon(Icons.pets),
          border: OutlineInputBorder(),
        ),
        items: animals.map((animal) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: animal,
            child: Text(animal['name']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedAnimal = value;
          });
        },
        value: _selectedAnimal,
        validator: (value) {
          if (value == null) {
            return 'Vă rugăm să selectați Animal';
          }
          return null;
        },
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
                prefixIcon: Icon(Icons.medical_services),
                border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
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
              child: Text(_selectedTreatment?['unit'] ?? ''),
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
          prefixIcon: Icon(Icons.check_box),
          border: OutlineInputBorder(),
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
              child: Text('Selectează Manopere'),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Wrap(
                children: _selectedProcedures.map((procedure) {
                  return Chip(
                    label: Text(procedure['name']),
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
    return AlertDialog(
      title: Text('Selectează Manopere'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items.map((item) {
            return CheckboxListTile(
              value: _selectedItems.contains(item),
              title: Text(item['name']),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool? selected) {
                setState(() {
                  if (selected == true) {
                    _selectedItems.add(item);
                  } else {
                    _selectedItems.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Anulează'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _selectedItems);
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}
