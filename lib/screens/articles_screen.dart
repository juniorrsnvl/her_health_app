import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/design_a.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _articles = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await AuthService.getArticles();
      if (!mounted) return;
      setState(() {
        _articles = data.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DA.ground,
      body: SafeArea(
        child: RefreshIndicator(
          color: DA.rose,
          onRefresh: _load,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DA.backButton(context),
          const SizedBox(height: 16),
          Text('Health articles', style: DA.heading(30)),
          const SizedBox(height: 6),
          Text('Written by your practice.', style: DA.body(15, color: DA.muted)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: DA.rose));
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _header(),
          const SizedBox(height: 40),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: DA.body(15, color: DA.rejectedInk),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _header(),
        if (_articles.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: DA.card(),
            child: Text(
              "No articles yet.\nYour practice will share health tips here.",
              textAlign: TextAlign.center,
              style: DA.body(16, color: DA.muted),
            ),
          ),
        ..._articles.map((article) {
          final title = (article['title'] as String?) ?? '';
          final category = article['category'] as String?;
          final body = (article['body'] as String?) ?? '';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: DA.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: DA.border, width: 1.5),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleDetailScreen(article: article),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category != null && category.isNotEmpty) ...[
                        _CategoryChip(category),
                        const SizedBox(height: 10),
                      ],
                      Text(title, style: DA.heading(18)),
                      const SizedBox(height: 6),
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: DA.body(15, color: DA.muted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: DA.blush,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: DA.body(12, color: DA.rejectedInk, weight: FontWeight.w700),
      ),
    );
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final title = (article['title'] as String?) ?? '';
    final category = article['category'] as String?;
    final body = (article['body'] as String?) ?? '';
    final created = DateTime.tryParse((article['created_at'] as String?) ?? '');

    return Scaffold(
      backgroundColor: DA.ground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DA.backButton(context),
                  const SizedBox(height: 20),
                  if (category != null && category.isNotEmpty) ...[
                    _CategoryChip(category),
                    const SizedBox(height: 12),
                  ],
                  Text(title, style: DA.heading(28)),
                  if (created != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Published ${created.day.toString().padLeft(2, '0')}/'
                      '${created.month.toString().padLeft(2, '0')}/${created.year}',
                      style: DA.body(14, color: DA.quiet),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(body, style: DA.body(17, height: 1.7)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
