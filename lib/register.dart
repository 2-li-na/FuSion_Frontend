import 'dart:convert'; 
import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http; 
import 'appBar.dart'; 

class RegisterPage extends StatefulWidget {
  final String backendBaseUrl;

  const RegisterPage({Key? key, required this.backendBaseUrl}) : super(key: key);

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _selectedDepartment = 'Select Your Department';
  String _selectedGender = 'Männlich';

  Future<void> registerUser(BuildContext context) async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String email = _emailController.text;
    final String department = _selectedDepartment;
    final String gender = _selectedGender;

    try {
      final response = await http.post(
        Uri.parse('${widget.backendBaseUrl}/users/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
          'email': email,
          'department': department,
          'gender': gender,
        }),
      );

      if (!mounted) return; 

      if (response.statusCode == 201) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${data['message']}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed: Please try again later.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          // Back button at the top
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Align(
              alignment: Alignment.topLeft,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.green,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.green, width: 2.0),
                  minimumSize: Size(screenWidth * 0.25, screenHeight * 0.05),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Zurück', style: TextStyle(fontSize: screenWidth * 0.035)),
              ),
            ),
          ),
          // Form container below the button
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.green, width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Jetzt Registrieren!!!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.055,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Benutzername',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte Benutzername eingeben';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Passwort',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte Passwort eingeben';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Passwort bestätigen',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte Passwort bestätigen';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwörter stimmen nicht überein';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email-Adresse',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte Email-Adresse eingeben';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Bitte gültige Email-Adresse eingeben';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDepartment,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Fachbereich',
                        ),
                        isExpanded: true, 
                        items: [
                          'Select Your Department',
                          'Angewandte Informatik',
                          'Elektrotechnik und Informationstechnik',
                          'Gesundheitswissenschaften',
                          'Lebensmitteltechnologie',
                          'Oecotrophologie',
                          'Sozial- und Kulturwissenschaften',
                          'Sozialwesen',
                          'Wirtschaft',
                          'Verwaltung'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(fontSize: screenWidth * 0.035),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedDepartment = newValue!;
                          });
                        },
                        validator: (value) {
                          if (value == 'Select Your Department') {
                            return 'Bitte Fachbereich auswählen';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Geschlecht:',
                          style: TextStyle(
                            fontSize: screenWidth * 0.038,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Männlich', style: TextStyle(fontSize: screenWidth * 0.035)),
                                  value: 'Männlich',
                                  groupValue: _selectedGender,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGender = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Weiblich', style: TextStyle(fontSize: screenWidth * 0.035)),
                                  value: 'Weiblich',
                                  groupValue: _selectedGender,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGender = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Divers', style: TextStyle(fontSize: screenWidth * 0.035)),
                            value: 'Divers',
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.green,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.green, width: 2.0),
                          minimumSize: Size(screenWidth * 0.4, screenHeight * 0.055),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            registerUser(context);
                          }
                        },
                        child: Text(
                          'Registrieren',
                          style: TextStyle(color: Colors.green, fontSize: screenWidth * 0.04),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green[100],
    );
  }
}