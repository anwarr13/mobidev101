import 'package:flutter/material.dart';
import 'signup_screen.dart'; // Import the signup screen
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase authentication
import 'dashboard.dart'; // Import the dashboard screen
import 'firebase_options.dart'; // Import the Firebase options

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          LoginScreen(), // Reminder to self, for quick debugging always go here.
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Password visibility toggle
  bool _isPasswordVisible = false;

  // FirebaseAuth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _validateAndLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Sign in with Firebase Authentication
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // If login is successful, navigate to Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } on FirebaseAuthException catch (e) {
        // Show error message if login fails
        String errorMessage;
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          errorMessage = 'Wrong email or password, Try Again.';
        } else {
          errorMessage = e.message ?? 'Login failed. Please try again.';
        }

        // Show error message in a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Function to toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/login(bg).jpg', // Replace with your background image
              fit: BoxFit.cover,
            ),
          ),
          // Login form
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85, // Adaptive width
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Email TextField
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password TextField
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: GestureDetector(
                            onTap: _togglePasswordVisibility,
                            child: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 12) {
                            return 'Password must be at least 12 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _validateAndLogin,
                          child: const Text('Login'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Signup link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignupScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
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
        ],
      ),
    );
  }
}
