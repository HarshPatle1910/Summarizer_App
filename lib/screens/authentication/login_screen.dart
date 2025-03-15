import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_summariser/bloc/authentications/auth_bloc.dart';
import 'package:smart_summariser/bloc/authentications/auth_event.dart';
import 'package:smart_summariser/bloc/authentications/auth_state.dart';
import 'package:smart_summariser/screens/authentication/signup_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(50),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is Authenticated) {
                  // Navigate to Home Screen
                  Navigator.pushReplacementNamed(context, '/home');
                } else if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 42, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 80),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: TextFormField(
                        controller: emailController,
                        style: TextStyle(
                          color: Color.fromRGBO(255, 193, 34, 1),
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter E-Mail",
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(255, 193, 34, 1),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        style: TextStyle(
                          color: Color.fromRGBO(255, 193, 34, 1),
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(255, 193, 34, 1),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(223, 109, 20, 1),
                          foregroundColor: Color.fromRGBO(248, 245, 233, 1),
                        ),
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                LoginRequested(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                ),
                              );
                        },
                        child: Text('Login'),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "------- or Login with --------",
                      style: TextStyle(fontSize: 10),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        // Add Google Sign-In Here
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(
                              width: 20,
                              height: 20,
                              image:
                                  AssetImage("assets/images/google_logo.png"),
                            ),
                            SizedBox(width: 10),
                            Text('GOOGLE'),
                          ],
                        ),
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?",
                            style: TextStyle(fontSize: 12)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage()),
                            );
                          },
                          child: Container(
                            child: Text(
                              " Sign Up",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(223, 109, 20, 1),
                              ),
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
      ),
    );
  }
}
