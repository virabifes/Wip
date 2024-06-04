import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TextFieldInput Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TextFieldInput Demo'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFieldInput(
                  textEditingController: TextEditingController(),
                  hintText: 'Enter your username',
                  textInputType: TextInputType.text, onSubmitted: (_) {  },
                ),
                const SizedBox(height: 20),
                TextFieldInput(
                  textEditingController: TextEditingController(),
                  hintText: 'Enter your password',
                  textInputType: TextInputType.text,
                  isPass: true, onSubmitted: (_) {  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;
  
  const TextFieldInput({
    super.key,
    required this.textEditingController,
    this.isPass = false,
    required this.hintText,
    required this.textInputType, required Null Function(dynamic _) onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(
          color: Colors.grey[600], // Changed hint text color to grey
        ),
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: Colors.purpleAccent), // Highlight focused border color
        ),
        enabledBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: Colors.grey[400]!), // Set border color when enabled
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: textInputType,
      obscureText: isPass,
      style: GoogleFonts.inter(color: Colors.purple), // Changed text color to purple
    );
  }
}

