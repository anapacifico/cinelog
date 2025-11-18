// lib/pages/login.dart
import 'package:flutter/material.dart';
import 'package:to_do_project/pages/cadastro.dart';
import 'package:to_do_project/pages/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  final _loginController = TextEditingController();
  final _senhaController = TextEditingController();

  static const _primary = Color.fromARGB(255, 216, 21, 7);
  static const _fill = Color(0xFF2C2929);
  static const _label = Colors.white70;
  static const _text = Colors.white;

  InputDecoration _decoration({
    required String label,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: _label),
      hintStyle: const TextStyle(color: _label),
      filled: true,
      fillColor: _fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: _label.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      suffixIcon: suffixIcon,
    );
  }

  void _enviarFormulario() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      
      // Mostrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processando login...')),
      );

      try {
        final response = await _fazerLogin(
          login: _loginController.text.trim(),
          senha: _senhaController.text,
        );

        if (response['sucesso']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login realizado com sucesso!')),
          );
          
          // Ir pra HomePage (Cinelog)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['mensagem'] ?? 'Erro ao fazer login')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _fazerLogin({
    required String login,
    required String senha,
  }) async {
    //final url = Uri.parse('http://10.0.2.2:8080/auth/login');
    final url = Uri.parse('http://localhost:8080/auth/login');
    print("=== INICIANDO LOGIN ===");
    print("URL de login: $url");
    print("Dados: login=$login");
    
    try {
      print("Enviando requisição POST...");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login': login,
          'password': senha,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print("TIMEOUT: A requisição demorou mais de 10 segundos!");
          throw Exception('Timeout na conexão com a API');
        },
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dados = jsonDecode(response.body);
        print("Login realizado com sucesso!");
        return {'sucesso': true, 'mensagem': 'Login realizado'};
      } else {
        print("Erro: Status ${response.statusCode}");
        final dados = jsonDecode(response.body);
        return {'sucesso': false, 'mensagem': dados['mensagem'] ?? 'Erro no servidor'};
      }
    } catch (e) {
      print("ERRO NA REQUISIÇÃO: $e");
      return {'sucesso': false, 'mensagem': 'Erro de conexão: $e'};
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // E-mail
                TextFormField(
                  controller: _loginController,
                  style: const TextStyle(color: _text),
                  cursorColor: _primary,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    label: 'Login',
                    hint: 'Login',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Senha
                TextFormField(
                  controller: _senhaController,
                  style: const TextStyle(color: _text),
                  cursorColor: _primary,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  decoration: _decoration(
                    label: 'Senha',
                    hint: 'Mínimo 6 caracteres',
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword ? 'Mostrar' : 'Ocultar',
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Campo obrigatório';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter no mínimo 6 caracteres';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _enviarFormulario(),
                ),

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _enviarFormulario,
                    child: const Text('Login'),
                  ),
                ),

                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ainda não tem uma conta? ',
                      style: TextStyle(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Cadastro(),
                          ),
                        );
                      },
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(
                          color: _primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
