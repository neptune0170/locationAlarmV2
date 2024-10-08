import 'package:flutter/material.dart';
import 'package:locationalarm/data/data_providers/auth_api_provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    bool isObscurePassword = true;
    bool isObscureConfirmPassword = true;

    // Controllers for the fields
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    TextEditingController fullNameController =
        TextEditingController(); // New controller for Full Name

    final AuthApiProvider authApiProvider = AuthApiProvider();

    Future<void> signup() async {
      print("Here 4--------------------------------");

      final String email = emailController.text;
      final String password = passwordController.text;
      final String fullName =
          fullNameController.text; // Get full name from the controller

      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Passwords do not match')));
        return;
      }

      // Ensure full name is provided
      if (fullName.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Full Name cannot be empty')));
        return;
      }

      bool success = await authApiProvider.signup(
          email, password, fullName); // Pass full name to signup
      print("Signup success: " + success.toString());

      if (success) {
        Map<String, dynamic>? response =
            await authApiProvider.login(email, password);

        if (response != null) {
          String token = response['token'];
          Navigator.pushNamed(context, "/home");
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Login failed')));
        }
        // print('Signup successful');
        // Navigator.pushNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Signup Failed')));
      }
    }

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

                // Full Name TextField
                TextField(
                  controller: fullNameController, // Controller for Full Name
                  decoration: InputDecoration(
                    labelText: 'Full Name', // Label for Full Name
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

                // Email TextField
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

                // Password TextField
                TextField(
                  controller: passwordController,
                  obscureText: isObscurePassword,
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
                        isObscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isObscurePassword = !isObscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                // Confirm Password TextField
                TextField(
                  controller: confirmPasswordController,
                  obscureText: isObscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
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
                        isObscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isObscureConfirmPassword = !isObscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Sign up Button
                ElevatedButton(
                  onPressed: signup,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 60), // Full-width button
                    backgroundColor: Colors.black, // Button color
                  ),
                  child: Text('Sign up',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),

                SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Have an account ?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Sign in'),
                    ),
                  ],
                ),

                // Row(
                //   children: [
                //     Expanded(
                //         child: Divider(thickness: 0.5, color: Colors.grey)),
                //     Padding(
                //       padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                //       child: Text('or',
                //           style: TextStyle(color: Colors.grey, fontSize: 18)),
                //     ),
                //     Expanded(
                //         child: Divider(thickness: 0.5, color: Colors.grey)),
                //   ],
                // ),

                // SizedBox(height: 16),

                // // Google Sign-in Button
                // ElevatedButton.icon(
                //   onPressed: () {
                //     // Add your Google sign-in functionality here
                //   },
                //   icon: Image.asset(
                //     'assets/images/Google.png', // Ensure you have the correct path to your image
                //     height: 24,
                //     width: 24,
                //   ),
                //   label: Text('Continue with Google',
                //       style:
                //           TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                //   style: ElevatedButton.styleFrom(
                //     minimumSize: Size(double.infinity, 60), // Full-width button
                //     backgroundColor: Colors.grey[200], // Button color
                //     side: BorderSide(color: Colors.black), // Border color
                //   ),
                // ),

                // SizedBox(
                //     height: 100), // Adjust the height to center the content
              ],
            ),
          ),
        ),
      ),
    );
  }
}
