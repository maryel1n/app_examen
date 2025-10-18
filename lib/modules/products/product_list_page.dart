import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_examen/shared/services/api_client.dart';
import 'package:app_examen/modules/categories/category_list_page.dart';
import 'package:app_examen/modules/providers/provider_list_page.dart';
import 'product.dart';
import 'product_service.dart';
import 'product_form_page.dart';

class ProductListPage extends StatefulWidget {
  final bool embedded; // para Tabs
  const ProductListPage({super.key, this.embedded = false});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  bool _loading = true;
  String? _error;
  List<Product> _items = const [];

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
      final data = await ProductService.list();
      if (!mounted) return;
      setState(() => _items = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmDelete(Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Seguro quieres eliminar "${p.name}"?'),
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
    if (ok == true) {
      try {
        await ProductService.delete(p.id);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Producto eliminado.')));
        _fetch();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }

  String _price(double v) => '\$${v.toStringAsFixed(0)}';

  String _pretty(dynamic v) {
    try {
      return const JsonEncoder.withIndent('  ').convert(v);
    } catch (_) {
      return v.toString();
    }
  }

  Future<void> _showRawResponse() async {
    try {
      final data = await ApiClient.getJson('ejemplos/product_list_rest/');
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Respuesta cruda de la API'),
          content: SingleChildScrollView(child: Text(_pretty(data))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al obtener JSON: $e')));
    }
  }

  Future<void> _openEdit(Product p) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProductFormPage(initial: p)),
    );
    if (saved == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Producto guardado.')));
      _fetch();
    }
  }

  Widget _buildBody(TextTheme t) {
    return SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ocurrió un problema al cargar los productos.',
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
                  final p = _items[index];
                  return Card(
                    child: InkWell(
                      onTap: () async {
                        debugPrint('CARD_TAP_EDIT id=${p.id}');
                        await _openEdit(p);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                p.image,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 64,
                                  height: 64,
                                  color: const Color(0xFFE5E7EB),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: t.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(_price(p.price), style: t.bodyMedium),
                                  if ((p.state ?? '').isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        p.state!,
                                        style: t.bodySmall?.copyWith(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  debugPrint('MENU_EDIT id=${p.id}');
                                  await _openEdit(p);
                                } else if (value == 'del') {
                                  _confirmDelete(p);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Editar'),
                                ),
                                PopupMenuItem(
                                  value: 'del',
                                  child: Text('Eliminar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BUILD ProductListPage v2');
    final t = Theme.of(context).textTheme;

    if (widget.embedded) return _buildBody(t);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos ✅'),
        actions: [
          IconButton(
            tooltip: 'Ver JSON',
            icon: const Icon(Icons.bug_report),
            onPressed: _showRawResponse,
          ),
          IconButton(
            tooltip: 'Categorías',
            icon: const Icon(Icons.category_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CategoryListPage()),
              );
            },
          ),
          IconButton(
            tooltip: 'Proveedores',
            icon: const Icon(Icons.local_shipping_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProviderListPage()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(t),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const ProductFormPage()),
          );
          if (result == true) {
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Producto guardado.')));
            _fetch();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }
}
