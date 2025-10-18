import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_examen/shared/services/api_client.dart';

import 'provider.dart';
import 'provider_service.dart';
import 'provider_form_page.dart';

class ProviderListPage extends StatefulWidget {
  final bool embedded; // para Tabs si lo usas embebido
  const ProviderListPage({super.key, this.embedded = false});

  @override
  State<ProviderListPage> createState() => _ProviderListPageState();
}

class _ProviderListPageState extends State<ProviderListPage> {
  bool _loading = true;
  String? _error;
  List<Provider> _items = const [];

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
      final data = await ProviderService.list();
      if (!mounted) return;
      setState(() => _items = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmDelete(Provider p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar proveedor'),
        content: Text('¿Seguro quieres eliminar "${p.name} ${p.lastName}"?'),
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
        await ProviderService.delete(p.id);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Proveedor eliminado.')));
        _fetch();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }

  String _pretty(dynamic v) {
    try {
      return const JsonEncoder.withIndent('  ').convert(v);
    } catch (_) {
      return v.toString();
    }
  }

  Future<void> _showRawResponse() async {
    try {
      final data = await ApiClient.getJson('ejemplos/provider_list_rest/');
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

  Future<void> _openForm({Provider? initial}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProviderFormPage(initial: initial)),
    );
    if (saved == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Proveedor guardado.')));
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
                    'Ocurrió un problema al cargar proveedores.',
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
                  final fullName = '${p.name} ${p.lastName}'.trim();
                  return Card(
                    child: InkWell(
                      onTap: () async => _openForm(initial: p),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              child: const Icon(Icons.local_shipping),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fullName.isEmpty
                                        ? '(Sin nombre)'
                                        : fullName,
                                    style: t.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if ((p.mail ?? '').isNotEmpty)
                                    Text(p.mail!, style: t.bodyMedium),
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
                                  await _openForm(initial: p);
                                } else if (value == 'del') {
                                  await _confirmDelete(p);
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
    final t = Theme.of(context).textTheme;

    if (widget.embedded) return _buildBody(t);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedores'),
        actions: [
          IconButton(
            tooltip: 'Ver JSON',
            icon: const Icon(Icons.bug_report),
            onPressed: _showRawResponse,
          ),
        ],
      ),
      body: _buildBody(t),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }
}
