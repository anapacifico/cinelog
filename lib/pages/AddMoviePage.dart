import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:http_parser/http_parser.dart';

import 'package:to_do_project/models/genero.dart';
import 'package:to_do_project/services/auth_service.dart';
import 'package:to_do_project/constants.dart'; 

class _AtorForm {
  final nomeController = TextEditingController();
  final personagemController = TextEditingController();

  void dispose() {
    nomeController.dispose();
    personagemController.dispose();
  }
}

class AddMoviePage extends StatefulWidget {
  const AddMoviePage({super.key});

  @override
  State<AddMoviePage> createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _duracaoController = TextEditingController();
  final _diretorController = TextEditingController();
  final List<_AtorForm> _atoresFormList = [];

  DateTime? _selectedDate;
  XFile? _capaFile; 
  XFile? _posterFile;

  List<Genero> _todosOsGeneros = []; 
  Set<int> _generosSelecionadosId = {};
  bool _isLoadingGeneros = true;
  bool _isSubmitting = false;

  
  final _imagePicker = ImagePicker(); 
  final _dio = Dio(BaseOptions(baseUrl: API_BASE_URL));

  @override
  void initState() {
    super.initState();
    _fetchGeneros();
    _addAtorForm();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _duracaoController.dispose();
    _diretorController.dispose();
    for (var atorForm in _atoresFormList) {
      atorForm.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchGeneros() async {
    try {
      final response = await _dio.get('/api/generos/list');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          _todosOsGeneros = data.map((json) => Genero.fromJson(json)).toList();
          _isLoadingGeneros = false;
        });
      }
    } catch (e) {
      print('Erro ao buscar gêneros: $e');
      setState(() {
        _isLoadingGeneros = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar gêneros. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickImage(ImageSource source, {required bool isCapa}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          if (isCapa) {
            _capaFile = pickedFile; 
          } else {
            _posterFile = pickedFile; 
          }
        });
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível carregar a imagem.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addAtorForm() {
    setState(() {
      _atoresFormList.add(_AtorForm());
    });
  }

  void _removeAtorForm(int index) {
    setState(() {
      final form = _atoresFormList.removeAt(index);
      form.dispose();
    });
  }

  void _showImageSourceActionSheet({required bool isCapa}) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                _pickImage(ImageSource.gallery, isCapa: isCapa);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                _pickImage(ImageSource.camera, isCapa: isCapa);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; 
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma data'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_capaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma imagem de capa'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_posterFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma imagem de poster'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_generosSelecionadosId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione pelo menos um gênero'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro: Usuário não autenticado'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final List<Map<String, String>> atoresList = _atoresFormList
          .map((atorForm) => {
                "nome": atorForm.nomeController.text,
                "personagem": atorForm.personagemController.text,
              })
          .where((atorMap) => atorMap["nome"]!.isNotEmpty && atorMap["personagem"]!.isNotEmpty)
          .toList();

      final elencoDto = {
        "diretor": _diretorController.text,
        "atores": atoresList,
      };

      final filmeDto = {
        "titulo": _tituloController.text,
        "descricao": _descricaoController.text,
        "dataLancamento": _selectedDate!.toIso8601String().split('T').first,
        "duracaoMinutos": int.parse(_duracaoController.text),
        "idUser": userId,
        "generosId": _generosSelecionadosId.toList(),
        "elenco": elencoDto,
      };
      
      final filmeJsonString = jsonEncode(filmeDto);

      final Uint8List capaBytes = await _capaFile!.readAsBytes();
      final Uint8List posterBytes = await _posterFile!.readAsBytes();

      final String capaMimeType = _capaFile!.mimeType ?? 'image/jpeg';
      final String posterMimeType = _posterFile!.mimeType ?? 'image/jpeg';
      final String capaFileName = _capaFile!.name;
      final String posterFileName = _posterFile!.name;
      
      final formData = FormData.fromMap({
        'filme': MultipartFile.fromString(
          filmeJsonString,
          contentType: MediaType.parse('application/json'),
        ),
        'capa': MultipartFile.fromBytes(
          capaBytes,
          filename: capaFileName,
          contentType: MediaType.parse(capaMimeType),
        ),
        'poster': MultipartFile.fromBytes(
          posterBytes,
          filename: posterFileName,
          contentType: MediaType.parse(posterMimeType),
        ),
      });

      final response = await _dio.post(
        '/api/filmes',
        data: formData,
        onSendProgress: (sent, total) {
          print('Enviando: ${((sent / total) * 100).toStringAsFixed(0)}%');
        },
      );
      if (response.statusCode == 201) { // 201 Created
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Filme salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }

    } on DioError catch (e) {
      print('Erro Dio: ${e.response?.data}'); 
      String erroMsg = e.message ?? 'Erro desconhecido';
      if (e.response?.data != null) {
        erroMsg = e.response!.data.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $erroMsg'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Erro genérico: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao processar dados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Novo Filme'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um título';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira uma descrição';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _duracaoController,
              decoration: const InputDecoration(
                labelText: 'Duração (em minutos)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a duração';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: TextEditingController(
                text: _selectedDate == null
                    ? ''
                    : _selectedDate!.toIso8601String().split('T').first,
              ),
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Data de Lançamento',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _pickDate(context),
                ),
              ),
              onTap: () => _pickDate(context),
            ),
            const SizedBox(height: 16),

            const Text('Gêneros', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildGenerosSelector(),
            
            const SizedBox(height: 16),

            const Text('Imagens', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildImagePicker(
              title: 'Capa',
              file: _capaFile,
              onPick: () => _showImageSourceActionSheet(isCapa: true),
            ),
            const SizedBox(height: 16),
            _buildImagePicker(
              title: 'Poster',
              file: _posterFile,
              onPick: () => _showImageSourceActionSheet(isCapa: false),
            ),

            _buildElencoForm(),
            
            const SizedBox(height: 24),

            if (_isSubmitting)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Salvar Filme', style: TextStyle(fontSize: 16)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerosSelector() {
    if (_isLoadingGeneros) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_todosOsGeneros.isEmpty) {
      return const Center(child: Text('Nenhum gênero encontrado.'));
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
         border: Border.all(color: Colors.grey.shade400),
         borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: _todosOsGeneros.map((genero) {
          final isSelected = _generosSelecionadosId.contains(genero.id);
          
          return ChoiceChip(
            label: Text(genero.nome),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _generosSelecionadosId.add(genero.id);
                } else {
                  _generosSelecionadosId.remove(genero.id);
                }
              });
            },
            selectedColor: Theme.of(context).primaryColor,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : const Color.fromARGB(255, 197, 24, 24)
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImagePicker({
    required String title,
    required XFile? file,
    required VoidCallback onPick,
  }) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: file != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network( 
                  file.path,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text('Selecionar $title', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
      ),
    );
  }
  Widget _buildElencoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Elenco', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _diretorController,
          decoration: const InputDecoration(
            labelText: 'Diretor',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira o diretor';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        const Text('Atores', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _atoresFormList.length,
          itemBuilder: (context, index) {
            final atorForm = _atoresFormList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: const Color(0xFF2C2929),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: atorForm.nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome do Ator',
                          border: UnderlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: atorForm.personagemController,
                        decoration: const InputDecoration(
                          labelText: 'Personagem',
                          border: UnderlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
                      ),
                    ),
                    if (_atoresFormList.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                        onPressed: () => _removeAtorForm(index),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
            );
          },
        ),
        
        TextButton.icon(
          onPressed: _addAtorForm,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Adicionar Ator'),
        ),
      ],
    );
  }
}