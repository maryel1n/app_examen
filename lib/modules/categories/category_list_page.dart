// lib/modules/categories/category_list_page.dart
import 'package:flutter/material.dart';
import 'category.dart';
import 'category_service.dart';
import 'category_form_page.dart';

class CategoryListPage extends StatefulWidget {
  final bool embedded;
  const CategoryListPage({super.key, this.embedded = false});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  bool _loading = true;
  String? _error;
  List<Category> _items = const [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await CategoryService.list();
      if (!mounted) return;
      setState(() => _items = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmDelete(Category c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text('¿Seguro quieres eliminar "${c.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (ok == true) {
      try {
        await CategoryService.delete(c.id);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Categoría eliminada.')));
        _fetch();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Ocurrió un problema al cargar las categorías.',
                      style: t.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_error!, style: t.bodySmall),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _fetch,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _fetch,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final c = _items[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          c.name,
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: (c.state ?? '').isNotEmpty
                            ? Text(c.state!)
                            : null,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final saved = await Navigator.of(context)
                                  .push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          CategoryFormPage(initial: c),
                                    ),
                                  );
                              if (!context.mounted) return;
                              if (saved == true) _fetch();
                            } else if (value == 'del') {
                              _confirmDelete(c);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Editar')),
                            PopupMenuItem(
                              value: 'del',
                              child: Text('Eliminar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const CategoryFormPage()),
          );
          if (result == true) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Categoría guardada.')),
            );
            _fetch();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }
}
