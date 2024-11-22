import 'package:flutter/material.dart';

class AdminPanelPage extends StatefulWidget {
  @override
  _AdminPanelPageState createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final TextEditingController _animalNameController = TextEditingController();
  final TextEditingController _speciesNameController = TextEditingController();
  final TextEditingController _breedNameController = TextEditingController();
  final TextEditingController _manoperaNameController = TextEditingController();
  final TextEditingController _manoperaPriceController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSpecies;

  // Dummy data
  List<Map<String, dynamic>> animals = [
    {'id': 1, 'name': 'Dog', 'category': 'Animal'},
    {'id': 2, 'name': 'Cat', 'category': 'Animal'},
  ];
  List<Map<String, dynamic>> species = [
    {'id': 1, 'name': 'Golden Retriever', 'animal': 'Dog'},
    {'id': 2, 'name': 'Persian', 'animal': 'Cat'},
  ];
  List<Map<String, dynamic>> manopere = [
    {'id': 1, 'name': 'Vaccination', 'price': 50.0},
    {'id': 2, 'name': 'Neutering', 'price': 100.0},
  ];

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Panou Administrator',
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildExpansionPanel('Animale', Icons.pets, animals, _showAnimalDialog),
            _buildExpansionPanel('Specii', Icons.category, species, _showSpeciesDialog),
            _buildExpansionPanel('Manopere', Icons.build, manopere, _showManoperaDialog),
          ],
        ),
      ),
    ),
  );
}

Widget _buildExpansionPanel(String title, IconData icon, List<Map<String, dynamic>> items, Function(Map<String, dynamic>?) onEdit) {
  return Card(
    margin: EdgeInsets.symmetric(vertical: 10),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, size: 40, color: Colors.teal.shade700),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade800,
          ),
        ),
        children: [
          _buildItemList(items, onEdit),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => onEdit(null),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Adaugă $title',
                style: TextStyle(
                  fontSize: 16,
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

Widget _buildItemList(List<Map<String, dynamic>> items, Function(Map<String, dynamic>?) onEdit) {
  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            item['name'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.containsKey('category'))
                Text(
                  'Categorie: ${item['category']}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              if (item.containsKey('animal'))
                Text(
                  'Animal: ${item['animal']}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              if (item.containsKey('price'))
                Text(
                  'Preț: ${item['price']} RON',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit, color: Colors.teal.shade600),
            onPressed: () => onEdit(item),
          ),
        ),
      );
    },
  );
}

void _showAnimalDialog(Map<String, dynamic>? animal) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        animal == null ? 'Adaugă Animal' : 'Editează Animal',
        style: TextStyle(
          color: Colors.teal.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _animalNameController,
            decoration: _buildInputDecoration('Nume Animal'),
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: _buildInputDecoration('Selectează Categorie'),
            value: _selectedCategory,
            items: [
              _buildDropdownItem('Animal'),
              _buildDropdownItem('Bird'),
              _buildDropdownItem('Fish'),
              _buildDropdownItem('Reptile'),
              _buildDropdownItem('Amphibian'),
              _buildDropdownItem('Insect'),
            ],
            onChanged: (value) => setState(() => _selectedCategory = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Anulează',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (animal == null) {
              setState(() {
                animals.add({
                  'id': animals.length + 1,
                  'name': _animalNameController.text,
                  'category': _selectedCategory,
                });
              });
            } else {
              setState(() {
                animal['name'] = _animalNameController.text;
                animal['category'] = _selectedCategory;
              });
            }
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade600,
          ),
          child: Text(animal == null ? 'Adaugă' : 'Salvează'),
        ),
      ],
    ),
  );
}

void _showSpeciesDialog(Map<String, dynamic>? specie) {
    if (specie != null) {
      _speciesNameController.text = specie['name'];
      _selectedSpecies = specie['animal'];
    } else {
      _speciesNameController.clear();
      _selectedSpecies = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            specie == null ? 'Adaugă Specie' : 'Editează Specie',
            style: TextStyle(
              color: Colors.teal.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _speciesNameController,
                decoration: _buildInputDecoration('Nume Specie'),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: _buildInputDecoration('Selectează Animal'),
                value: _selectedSpecies,
                items: animals.map((animal) {
                  return DropdownMenuItem<String>(
                    value: animal['name'],
                    child: Text(animal['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecies = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Anulează',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (specie == null) {
                  setState(() {
                    species.add({
                      'id': species.length + 1,
                      'name': _speciesNameController.text,
                      'animal': _selectedSpecies,
                    });
                  });
                } else {
                  setState(() {
                    specie['name'] = _speciesNameController.text;
                    specie['animal'] = _selectedSpecies;
                  });
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                specie == null ? 'Adaugă' : 'Salvează',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
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
  );
}

DropdownMenuItem<String> _buildDropdownItem(String value) {
  return DropdownMenuItem<String>(
    value: value,
    child: Text(value),
  );
}

void _showManoperaDialog(Map<String, dynamic>? manopera) {
  if (manopera != null) {
    _manoperaNameController.text = manopera['name'];
    _manoperaPriceController.text = manopera['price'].toString();
  } else {
    _manoperaNameController.clear();
    _manoperaPriceController.clear();
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          manopera == null ? 'Adaugă Manoperă' : 'Editează Manoperă',
          style: TextStyle(
            color: Colors.teal.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _manoperaNameController,
              decoration: _buildInputDecoration('Nume Manoperă'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _manoperaPriceController,
              decoration: _buildInputDecoration('Preț Manoperă')
                .copyWith(suffixText: 'RON'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Anulează',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (manopera == null) {
                setState(() {
                  manopere.add({
                    'id': manopere.length + 1,
                    'name': _manoperaNameController.text,
                    'price': double.parse(_manoperaPriceController.text),
                  });
                });
              } else {
                setState(() {
                  manopera['name'] = _manoperaNameController.text;
                  manopera['price'] = double.parse(_manoperaPriceController.text);
                });
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              manopera == null ? 'Adaugă' : 'Salvează',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}
}