// ignore_for_file: use_build_context_synchronously, body_might_complete_normally_catch_error, avoid_print

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:subabase/sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // شروط الباسورد
  bool hasMinLength = false;
  bool hasUpperCase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;

  double get _passwordStrength {
    int score = 0;
    if (hasMinLength) score++;
    if (hasUpperCase) score++;
    if (hasNumber) score++;
    if (hasSpecialChar) score++;
    return score / 4;
  }

  void _checkPassword(String password) {
    setState(() {
      hasMinLength = password.length >= 6;
      hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      hasNumber = password.contains(RegExp(r'[0-9]'));
      hasSpecialChar = password.contains(RegExp(r'[!@#\$&*~]'));
    });
  }

  Widget _buildRule(String text, bool isValid) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.red,
              fontWeight: isValid ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStrengthColor() {
    if (_passwordStrength < 0.25) return Colors.red;
    if (_passwordStrength < 0.5) return Colors.orange;
    if (_passwordStrength < 0.75) return Colors.blue;
    return Colors.green;
  }

  String _getStrengthText() {
    if (_passwordStrength < 0.25) return "ضعيف";
    if (_passwordStrength < 0.5) return "متوسط";
    if (_passwordStrength < 0.75) return "جيد";
    return "قوي";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Sign Up'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                maxLength: 11,
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: egyptianPhoneValidator,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: _checkPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (!hasMinLength ||
                      !hasUpperCase ||
                      !hasNumber ||
                      !hasSpecialChar) {
                    return 'Password does not meet the requirements';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Progress Bar + نص القوة
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _passwordStrength,
                      color: _getStrengthColor(),
                      backgroundColor: Colors.grey[300],
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _getStrengthText(),
                    style: TextStyle(
                      color: _getStrengthColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "شروط كلمة المرور:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      _buildRule('على الأقل 6 حروف', hasMinLength),
                      _buildRule('يحتوي على حرف كبير (A-Z)', hasUpperCase),
                      _buildRule('يحتوي على رقم', hasNumber),
                      _buildRule(
                        'يحتوي على رمز خاص (!@#\$&*~)',
                        hasSpecialChar,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading
                    ? null // تعطيل الزر أثناء التحميل
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
                          await signUpUser(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                            name: _nameController.text.trim(),
                            phone: _phoneController.text.trim(),
                          );
                          setState(() => _isLoading = false);
                        }
                      },
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Sign Up', style: TextStyle(fontSize: 18)),
              ),

              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     padding: const EdgeInsets.symmetric(vertical: 15),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //   ),
              //   onPressed: () async {
              //     if (_formKey.currentState!.validate()) {
              //       signUpUser(
              //         email: _emailController.text.trim(),
              //         password: _passwordController.text.trim(),
              //         name: _nameController.text.trim(),
              //         phone: _phoneController.text.trim(),
              //       );
              //     }
              //   },
              //   child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
              // ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const SignInPage()));
                },
                child: const Text("Already have an account? Log In"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signUpUser({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final supabase = Supabase.instance.client;

    try {
      final existingPhone = await supabase
          .from('users')
          .select('id')
          .eq('phone', phone)
          .maybeSingle();

      if (existingPhone != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('هذا الرقم مستخدم بالفعل')),
        );
        setState(() => _isLoading = false); // لازم نرجع اللودنج لحالته
        return;
      }

      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone},
      );

      final user = res.user;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل التسجيل، حاول مرة أخرى')),
        );
        setState(() => _isLoading = false);
        return;
      }

      await supabase.from('users').insert({
        'id': user.id,
        'name': name,
        'email': email,
        'phone': phone,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إنشاء الحساب بنجاح')));
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const SignInPage()));
    } on AuthException catch (e) {
      log('Auth error: ${e.message}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ: ${e.message}')));
      setState(() => _isLoading = false);
    } catch (e) {
      log('Unexpected error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
      setState(() => _isLoading = false);
    }
  }

  String? egyptianPhoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    value = value.replaceAll(RegExp(r'\s+|-'), '');
    if (!RegExp(r'^(010|011|012|015)[0-9]{8}$').hasMatch(value)) {
      return 'Enter a valid Egyptian phone number';
    }
    return null;
  }
}
