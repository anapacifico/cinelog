import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:to_do_project/models/new_movie_request.dart'; // Importe seu novo model

class AddMoviePage extends StatefulWidget {
  const AddMoviePage({super.key});

  @override
  State<AddMoviePage> createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  // Chave global para validar o formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para cada campo de texto
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _duracaoController = TextEditingController();
  final _generosController = TextEditingController();
  final _capaUrlController = TextEditingController();

  // Variáveis de estado
  DateTime? _selectedDate;
  String _previewUrl = '';

  // FocusNode para saber quando o usuário sai do campo da URL
  final _capaUrlFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Adiciona o listener para atualizar o preview
    _capaUrlFocusNode.addListener(_updateImagePreview);
  }

  @override
  void dispose() {
    // Limpa os controladores e o focus node
    _tituloController.dispose();
    _descricaoController.dispose();
    _duracaoController.dispose();
    _generosController.dispose();
    _capaUrlController.dispose();
    _capaUrlFocusNode.removeListener(_updateImagePreview);
    _capaUrlFocusNode.dispose();
    super.dispose();
  }

  /// Atualiza a URL do preview quando o usuário perde o foco do campo
  void _updateImagePreview() {
    if (!_capaUrlFocusNode.hasFocus) {
      setState(() {
        _previewUrl = _capaUrlController.text;
      });
    }
  }

  /// Exibe o seletor de data
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

  /// Valida e submete o formulário
  void _submitForm() {
    // Verifica se o formulário é válido
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // 1. Processa os campos
        final titulo = _tituloController.text;
        final descricao = _descricaoController.text;
        final duracaoMinutos = int.parse(_duracaoController.text);
        final capaUrl = _capaUrlController.text;
        final idUser = 'usuario_exemplo_id';

        // 2. Converte a string de gêneros (ex: "1, 2, 3") em uma lista de int
        final generosId = _generosController.text
            .split(',')
            .map((id) => int.parse(id.trim()))
            .toList();

        // 3. Cria o objeto de requisição
        final newMovie = NewMovieRequest(
          titulo: titulo,
          descricao: descricao,
          dataLancamento: _selectedDate!,
          duracaoMinutos: duracaoMinutos,
          generosId: generosId,
          capaUrl: capaUrl,
          idUser: idUser, // Substitua por um ID real conforme necessário
        );

        // 4. Converte para JSON (como você pediu)
        final jsonRequest = newMovie.toJson();

        // TODO: Enviar 'jsonRequest' para sua API

        // Exibe o JSON no console por enquanto
        print('JSON a ser enviado: $jsonRequest');

        // Mostra um feedback de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Filme salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Fecha a página
        Navigator.of(context).pop();
        
      } catch (e) {
        // Mostra um feedback de erro (ex: se a duração ou gênerosId for mal formatado)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao processar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Novo Filme'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Título ---
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

            // --- Descrição ---
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

            // --- Duração em Minutos ---
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
                if (int.tryParse(value) == null) {
                  return 'Insira um número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Data de Lançamento ---
            TextFormField(
              // Exibe a data formatada
              controller: TextEditingController(
                text: _selectedDate == null
                    ? ''
                    : _selectedDate!.toIso8601String().split('T').first,
              ),
              readOnly: true, // Impede o usuário de digitar
              decoration: InputDecoration(
                labelText: 'Data de Lançamento',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _pickDate(context),
                ),
              ),
              onTap: () => _pickDate(context),
              validator: (value) {
                if (_selectedDate == null) {
                  return 'Por favor, selecione uma data';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Gêneros ID ---
            TextFormField(
              controller: _generosController,
              decoration: const InputDecoration(
                labelText: 'IDs dos Gêneros (separados por vírgula)',
                hintText: 'Ex: 1, 5, 12',
                border: OutlineInputBorder(),
              ),
              // TODO: Idealmente, substitua isso por um MultiSelect
              // ou uma lista de Checkboxes/Chips.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Insira pelo menos um ID de gênero';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- URL da Capa ---
            TextFormField(
              controller: _capaUrlController,
              focusNode: _capaUrlFocusNode, // Liga o focus node
              decoration: const InputDecoration(
                labelText: 'URL da Capa',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a URL da capa';
                }
                
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- PRÉ-VISUALIZAÇÃO DA IMAGEM ---
            _buildImagePreview(),
            
            const SizedBox(height: 24),

            // --- Botão Salvar ---
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                // Você pode usar a cor primária do seu app aqui
                // backgroundColor: Color.fromARGB(255, 216, 21, 7),
              ),
              child: const Text('Salvar Filme', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget que constrói a pré-visualização da imagem
  Widget _buildImagePreview() {
    if (_previewUrl.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported_outlined,
                  size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text('Preview da imagem aparecerá aqui',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    // Tenta carregar a imagem da URL
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        _previewUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        // Mostra um indicador de carregamento
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        // Mostra um ícone de erro se a URL for inválida
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            alignment: Alignment.center,
            color: Colors.grey.shade200,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 40, color: Colors.red),
                SizedBox(height: 8),
                Text('Não foi possível carregar a imagem',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red)),
              ],
            ),
          );
        },
      ),
    );
  }
}