import 'package:flutter/material.dart';
import 'package:locationalarm/data/data_providers/auth_api_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isObscure = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final AuthApiProvider authApiProvider = AuthApiProvider();

  Future<void> login() async {
    final String email = emailController.text;
    final String password = passwordController.text;

    Map<String, dynamic>? response =
        await authApiProvider.login(email, password);

    if (response != null) {
      String token = response['token'];
      Navigator.pushNamed(context, "/home");
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 0), // Adjust the height to center the content
                Text(
                  'Location Alarm',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 100),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email address',
                    labelStyle: TextStyle(
                      color: Colors.grey, // Set the label text color to grey
                      fontWeight: FontWeight.w500,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey, // Set the underline color to grey
                        width: 0.5, // Set the underline width to 0.5
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors
                            .black, // Set the underline color to black when focused
                        width:
                            0.5, // Set the underline width to 0.5 when focused
                      ),
                    ),
                  ),
                ),

                TextField(
                  controller: passwordController,
                  obscureText: isObscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight:
                          FontWeight.w500, // Set the label text color to grey
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey, // Set the underline color to grey
                        width: 0.5, // Set the underline width to 0.5
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors
                            .black, // Set the underline color to black when focused
                        width:
                            0.5, // Set the underline width to 0.5 when focused
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isObscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isObscure = !isObscure;
                        });
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Add your reset password functionality here
                    },
                    child: Text(
                      'Reset Password',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 60), // Full-width button
                    backgroundColor: Colors.black, // Button color
                  ),
                  child: Text('Sign in',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Don't have an account ?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signUp');
                      },
                      child: Text(
                        'Sign up',
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        child: Divider(
                      thickness: 0.5,
                      color: Colors.grey,
                    )),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Text('or',
                          style: TextStyle(color: Colors.grey, fontSize: 18)),
                    ),
                    Expanded(
                        child: Divider(
                      thickness: 0.5,
                      color: Colors.grey,
                    )),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add your Google sign-in functionality here
                  },
                  icon: Image.asset(
                    'assets/images/Google.png', // Ensure you have the correct path to your image
                    height: 24,
                    width: 24,
                  ),
                  label: Text(
                    'Continue with Google',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 60), // Full-width button
                    backgroundColor: Colors.grey[200], // Button color
                    side: BorderSide(color: Colors.black), // Border color
                  ),
                ),
                SizedBox(
                    height: 100), // Adjust the height to center the content
              ],
            ),
          ),
        ),
      ),
    );
  }
}
