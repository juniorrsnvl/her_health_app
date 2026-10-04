import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/design_a.dart';
import 'login_screen.dart';

class ArticlesManageScreen extends StatefulWidget {
  const ArticlesManageScreen({super.key});

  @override
  State<ArticlesManageScreen> createState() => _ArticlesManageScreenState();
}

class _ArticlesManageScreenState extends State<ArticlesManageScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _articles = [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.authorizedGet('/articles');

      if (response.statusCode == 401 || response.statusCode == 403) {
        await _handleSessionExpired();
        return;
      }

      if (response.statusCode != 200) {
        setState(() {
          _errorMessage = 'Failed to load articles (${response.statusCode}).';
          _isLoading = false;
        });
        return;
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      setState(() {
        _articles = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not reach the server.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSessionExpired() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _openEditor([Map<String, dynamic>? article]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleEditorScreen(article: article),
      ),
    );
    if (saved == true) {
      _loadArticles();
    }
  }

  Future<void> _delete(Map<String, dynamic> article) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete article?'),
        content: Text('"${article['title']}" will be removed for all patients.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response =
          await ApiService.authorizedDelete('/articles/${article['id']}');

      if (response.statusCode == 401 || response.statusCode == 403) {
        await _handleSessionExpired();
        return;
      }

      if (!mounted) return;

      if (response.statusCode == 200) {
        _loadArticles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete (${response.statusCode}).')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not reach the server.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DA.ground,
      appBar: DA.adminBar(
        'Health articles',
        actions: [
          ElevatedButton.icon(
            style: DA.primary().copyWith(
              minimumSize: const WidgetStatePropertyAll(Size(150, 44)),
            ),
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('New article'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: DA.rose,
        onRefresh: _loadArticles,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: DA.rose));
    }

    if (_errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 60),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: DA.body(15, color: DA.rejectedInk),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              style: DA.outline().copyWith(
                minimumSize: const WidgetStatePropertyAll(Size(140, 48)),
              ),
              onPressed: _loadArticles,
              child: const Text('Try again'),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      children: [
        DA.page(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Health articles', style: DA.heading(30)),
              const SizedBox(height: 6),
              Text(
                'Everything published here appears in the patient app.',
                style: DA.body(16, color: DA.muted),
              ),
              const SizedBox(height: 20),
              if (_articles.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: DA.card(),
                  child: Text(
                    'No articles yet. Use "New article" to write one.',
                    textAlign: TextAlign.center,
                    style: DA.body(16, color: DA.muted),
                  ),
                ),
              ..._articles.map((a) => _articleRow(a as Map<String, dynamic>)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _articleRow(Map<String, dynamic> article) {
    final title = article['title'] as String? ?? '';
    final category = article['category'] as String?;
    final body = article['body'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: DA.card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (category != null && category.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: DA.blush,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category,
                      style: DA.body(12, color: DA.rejectedInk, weight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(title, style: DA.body(17, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: DA.body(15, color: DA.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined, color: DA.sage),
            onPressed: () => _openEditor(article),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline_rounded, color: DA.rejectedInk),
            onPressed: () => _delete(article),
          ),
        ],
      ),
    );
  }
}

class ArticleEditorScreen extends StatefulWidget {
  final Map<String, dynamic>? article;

  const ArticleEditorScreen({super.key, this.article});

  @override
  State<ArticleEditorScreen> createState() => _ArticleEditorScreenState();
}

class _ArticleEditorScreenState extends State<ArticleEditorScreen> {
  late final TextEditingController titleController;
  late final TextEditingController categoryController;
  late final TextEditingController bodyController;
  bool _isSaving = false;

  bool get _isEditing => widget.article != null;

  @override
  void initState() {
    super.initState();
    titleController =
        TextEditingController(text: widget.article?['title'] as String? ?? '');
    categoryController = TextEditingController(
        text: widget.article?['category'] as String? ?? '');
    bodyController =
        TextEditingController(text: widget.article?['body'] as String? ?? '');
  }

  Future<void> _save() async {
    if (titleController.text.trim().isEmpty ||
        bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title and the article text.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final payload = {
      'title': titleController.text.trim(),
      'category': categoryController.text.trim(),
      'body': bodyController.text.trim(),
    };

    try {
      final response = _isEditing
          ? await ApiService.authorizedPut(
              '/articles/${widget.article!['id']}', payload)
          : await ApiService.authorizedPost('/articles', payload);

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save (${response.statusCode}).')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not reach the server.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DA.ground,
      appBar: DA.adminBar(_isEditing ? 'Edit article' : 'New article'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
        children: [
          DA.page(
            maxWidth: 760,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DA.label('Title'),
                TextField(
                  controller: titleController,
                  style: DA.body(16),
                  decoration: DA.input(),
                ),
                const SizedBox(height: 18),
                DA.label('Category (optional)'),
                TextField(
                  controller: categoryController,
                  style: DA.body(16),
                  decoration: DA.input(hint: 'e.g. Pregnancy, Menstrual Health, Wellness'),
                ),
                const SizedBox(height: 18),
                DA.label('Article text'),
                TextField(
                  controller: bodyController,
                  minLines: 12,
                  maxLines: 30,
                  style: DA.body(16, height: 1.6),
                  decoration: DA.input(),
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: DA.primary().copyWith(
                      minimumSize: const WidgetStatePropertyAll(Size(200, 56)),
                    ),
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? DA.buttonSpinner
                        : Text(_isEditing ? 'Save changes' : 'Publish'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
