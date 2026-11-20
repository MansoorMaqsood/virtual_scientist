import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virtual_scientist/ui/auth/login_screen.dart';
import 'package:virtual_scientist/utils/utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool loading = false;

  // ✅ ADDED THIS
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? selectedRole;
  String? selectedClass;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signUp() {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');

    if (!emailRegex.hasMatch(email)) {
      Utils().toastMessage("Please enter a valid email address");
      return;
    }

    final passwordRegex = RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$');

    if (!passwordRegex.hasMatch(password)) {
      Utils().toastMessage(
          "Password must contain:\n"
          "• Minimum 8 characters\n"
          "• 1 uppercase letter\n"
          "• 1 lowercase letter\n"
          "• 1 number\n"
          "• 1 special character (!@#\$&*~)");
      return;
    }

    setState(() {
      loading = true;
    });

    _auth
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((value) {
      setState(() {
        loading = false;
      });
      Utils().toastMessage('Signup successful');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }).catchError((error) {
      setState(() {
        loading = false;
      });
      Utils().toastMessage(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF121212)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.person_add_alt_1,
                      color: Color(0xFF10B981),
                      size: 70,
                    ),
                    const SizedBox(height: 15),

                    const Text(
                      "Create Account",
                      style: TextStyle(
                        color: Color(0xFFF9FAFB),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Sign up to start your journey",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: nameController,
                              hint: 'Name',
                              icon: Icons.person,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter Name';
                                }
                                if (!RegExp(r'^[a-zA-Z ]+$')
                                    .hasMatch(value.trim())) {
                                  return 'Name must contain only letters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            _buildTextField(
                              controller: emailController,
                              hint: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter Email';
                                }
                                if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Enter valid Email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // ✅ UPDATED PASSWORD FIELD
                            TextFormField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Color(0xFFF9FAFB)),
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle:
                                    const TextStyle(color: Colors.grey),
                                prefixIcon: const Icon(Icons.lock_outline,
                                    color: Color(0xFF10B981)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: const Color(0xFF10B981),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword =
                                          !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor:
                                    const Color(0xFF1E1E1E),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter Password';
                                }

                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }

                                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                  return 'Must contain at least 1 uppercase letter';
                                }

                                if (!RegExp(r'[a-z]').hasMatch(value)) {
                                  return 'Must contain at least 1 lowercase letter';
                                }

                                if (!RegExp(r'[0-9]').hasMatch(value)) {
                                  return 'Must contain at least 1 number';
                                }

                                if (!RegExp(r'[!@#\$&*~]')
                                    .hasMatch(value)) {
                                  return 'Must contain at least 1 special character';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            _buildDropdown(
                              hint: 'Select Role',
                              icon: Icons.group,
                              items: ['Student', 'Teacher'],
                              value: selectedRole,
                              onChanged: (val) => setState(() {
                                selectedRole = val;
                              }),
                              validator: (value) =>
                                  value == null ? 'Select Role' : null,
                            ),
                            const SizedBox(height: 20),

                            _buildDropdown(
                              hint: 'Select Class Level',
                              icon: Icons.school,
                              items: ['Matric', 'Intermediate'],
                              value: selectedClass,
                              onChanged: (val) => setState(() {
                                selectedClass = val;
                              }),
                              validator: (value) =>
                                  value == null
                                      ? 'Select Class Level'
                                      : null,
                            ),
                            const SizedBox(height: 30),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF10B981),
                                  foregroundColor:
                                      const Color(0xFFF9FAFB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  elevation: 6,
                                ),
                                onPressed: () {
                                  FocusScope.of(context)
                                      .unfocus();
                                  if (_formKey.currentState!
                                      .validate()) {
                                    signUp();
                                  }
                                },
                                child: loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(
                              color: Color(0xFFF9FAFB)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const LoginScreen()),
                            );
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFFF9FAFB)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Color(0xFF10B981)),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String hint,
    required IconData icon,
    required List<String> items,
    String? value,
    required Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF10B981)),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: const Color(0xFF2C2C2C),
      style: const TextStyle(color: Color(0xFFF9FAFB)),
      iconEnabledColor: const Color(0xFF10B981),
      hint: Text(hint, style: const TextStyle(color: Colors.grey)),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}