import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'globalVariable.dart';
import 'main.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  String userId = '';
  String empName = '';
  String dob = '';
  String doj = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  final Color _hintColor = const Color(0xFF6C757D);

  bool _obscureNewPassword = true;

  Future<void> _selectDate(BuildContext context, bool isDob) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.blue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDob) {
          dob = "${picked.year}-${picked.month}-${picked.day}";
        } else {
          doj = "${picked.year}-${picked.month}-${picked.day}";
        }
      });
    }
  }

  Future<void> sendReqReg(String username, String hashedPassword,
      String deviceId, String IdcardNo, dob, doj) async {
    String url = "$ipAddress/api/Registerinsert";
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? getToken = await prefs.getString("DeviceIdToken");
    // deviceId = getToken == null ? "" : getToken;
    print(deviceId);

    try {
      var bytes = utf8.encode(password); // data being hashed
      var md5Hash = md5.convert(bytes).toString();
      final response = await http.post(Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "USERNAME": username,
            "PASSWORD": md5Hash,
            "IDCARDNO": IdcardNo,
            "DEVICEID": deviceId,
            "DOB": dob,
            "DOJ": doj,
            "TYPE": deviceType
          }));
      print(deviceId.toString());
      final Map<String, dynamic> data = json.decode(response.body);
      if (data["status"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"]),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.teal[700],
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"]),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } catch (e) {
      _showErrorDialog("Connection Error", "Please ReOpen this Page");
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text(
          "Employee Registration",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.pink.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent, // Important for gradient to show
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadowColor: Colors.blue.withOpacity(0.2),
              child: Container(
                width: MediaQuery.of(context).size.width > 500 ? 500 : null,
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_add_alt_1,
                            size: 32,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      _buildTextField(
                        label: 'Employee Id',
                        icon: Icons.person_outline,
                        onSaved: (value) => userId = value!,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your User ID' : null,
                      ),
                      SizedBox(height: 12),
                      _buildTextField(
                        label: 'Employee Name',
                        icon: Icons.badge_outlined,
                        onSaved: (value) => empName = value!,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your name' : null,
                      ),
                      SizedBox(height: 12),
                      _buildDateField(
                        label: 'Date of Birth',
                        icon: Icons.calendar_today,
                        date: dob,
                        onTap: () => _selectDate(context, true),
                      ),
                      SizedBox(height: 12),
                      _buildDateField(
                        label: 'Date of Joining',
                        icon: Icons.calendar_today,
                        date: doj,
                        onTap: () => _selectDate(context, false),
                      ),
                      SizedBox(height: 12),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: _obscureNewPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                        onSaved: (value) => password = value!,
                        validator: (value) => value!.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),
                      SizedBox(height: 12),
                      _buildTextField(
                        label: 'Confirm Password',
                        icon: Icons.lock_outline,
                        obscureText: _obscureNewPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                        onSaved: (value) => confirmPassword = value!,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please confirm password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          shadowColor: Colors.blue.withOpacity(0.3),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            sendReqReg(
                                empName, password, deviceId!, userId, dob, doj);
                          }
                        },
                        child: Text(
                          'REGISTER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'OR',
                              style: GoogleFonts.poppins(
                                color: _hintColor,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?"),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(color: Color(0xFFDE3163)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextEditingController? controller,
    bool obscureText = false,
    Widget? suffixIcon,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blue[800]),
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[400]!, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.blue[50]!.withOpacity(0.3),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      style: TextStyle(color: Colors.blue[900]),
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required String date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue[800]),
          prefixIcon: Icon(icon, color: Colors.blue[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[400]!, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.blue[50]!.withOpacity(0.3),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date.isEmpty ? 'Select $label' : date,
              style: TextStyle(
                color: date.isEmpty ? Colors.grey[600] : Colors.blue[900],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.blue[600]),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
