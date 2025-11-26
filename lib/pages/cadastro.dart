import 'package:flutter/material.dart';
import 'package:CineLog/pages/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:CineLog/constants.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
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
      const SnackBar(content: Text('Processando cadastro...')),
    );

    try {
      final response = await _fazerCadastro(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );

      if (response['sucesso']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        
        // Voltar pro login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else {
        print("Cadastro falhou: ${response}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['mensagem'] ?? 'Erro ao cadastrar')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }
}

Future<Map<String, dynamic>> _fazerCadastro({
  required String nome,
  required String email,
  required String senha,
}) async {
  final url = Uri.parse('$AUTH_BASE_URL/auth/register');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': nome,
        'email': email,
        'password': senha,
      }),
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
          throw Exception('Timeout na conexão com a API');
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'sucesso': true, 'mensagem': 'Cadastro realizado'};
    } else {
      final dados = jsonDecode(response.body);
      return {'sucesso': false, 'mensagem': dados["error"] ?? 'Erro no servidor'};
    }
  } catch (e) {
    return {'sucesso': false, 'mensagem': 'Erro de conexão: $e'};
  }
}

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
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
                  'Cadastro de Usuário',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Nome
                TextFormField(
                  controller: _nomeController,
                  style: const TextStyle(color: _text),
                  cursorColor: _primary,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    label: 'Username',
                    hint: 'Digite seu username',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // E-mail
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: _text),
                  cursorColor: _primary,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    label: 'E-mail',
                    hint: 'exemplo@exemplo.com',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Campo obrigatório';
                    }
                    final email = value.trim();
                    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                    if (!regex.hasMatch(email)) {
                      return 'E-mail inválido';
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
                    child: const Text('Criar Conta'),
                  ),
                ),

                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já tem uma conta? ',
                      style: TextStyle(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                        );
                      },
                      child: const Text(
                        'Faça login',
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
