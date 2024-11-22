import 'package:flutter/material.dart';
import 'register_page.dart';
import 'login_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Map<String, bool> _hoveredStates = {'register': false, 'login': false};

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FadeTransition(
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
                        'Vet App',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Gestionarea Cabinetului Veterinar',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 60),
                MouseRegion(
                  onEnter: (_) => setState(() => _hoveredStates['register'] = true),
                  onExit: (_) => setState(() => _hoveredStates['register'] = false),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hoveredStates['register']! 
                            ? Colors.white 
                            : Colors.teal.shade600,
                        padding: EdgeInsets.symmetric(
                          horizontal: _hoveredStates['register']! ? 60 : 50, 
                          vertical: 15
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: _hoveredStates['register']! ? 8 : 4,
                      ),
                      child: Text(
                        'Înregistrare',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _hoveredStates['register']! 
                              ? Colors.teal.shade600 
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                MouseRegion(
                  onEnter: (_) => setState(() => _hoveredStates['login'] = true),
                  onExit: (_) => setState(() => _hoveredStates['login'] = false),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hoveredStates['login']! 
                            ? Colors.white 
                            : Colors.teal.shade600,
                        padding: EdgeInsets.symmetric(
                          horizontal: _hoveredStates['login']! ? 60 : 50, 
                          vertical: 15
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: _hoveredStates['login']! ? 8 : 4,
                      ),
                      child: Text(
                        'Autentificare',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _hoveredStates['login']! 
                              ? Colors.teal.shade600 
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Gestionarea Animalelor și Vizitelor',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}