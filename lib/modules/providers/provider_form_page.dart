import 'package:flutter/material.dart';
import 'provider.dart';
import 'provider_service.dart';

class ProviderFormPage extends StatefulWidget {
  final ProviderModel? initial; // si viene, es edición

  const ProviderFormPage({super.key, this.initial});

  @override
  State<ProviderFormPage> createState() => _ProviderFormPageState();
}

class _ProviderFormPageState extends State<ProviderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _state = 'Activo';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    if (p != null) {
      _nameCtrl.text = p.name;
      _lastNameCtrl.text = p.lastName;
      _emailCtrl.text = p.email;
      _state = p.state ?? 'Activo';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'El correo es obligatorio';
    // validación sencilla
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
    if (!ok) return 'Correo inválido';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final name = _nameCtrl.text.trim();
      final lastName = _lastNameCtrl.text.trim();
      final email = _emailCtrl.text.trim();

      if (widget.initial == null) {
        await ProviderService.add(
          name: name,
          lastName: lastName,
          email: email,
          state: _state,
        );
      } else {
        await ProviderService.edit(
          id: widget.initial!.id,
          name: name,
          lastName: lastName,
          email: email,
          state: _state,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true); // éxito
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar proveedor' : 'Agregar proveedor'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'El nombre es obligatorio'
                      : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastNameCtrl,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'El apellido es obligatorio'
                      : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  keyboardType: TextInputType.emailAddress,
                  validator: _emailValidator,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _state,
                  items: const [
                    DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                    DropdownMenuItem(
                      value: 'Inactivo',
                      child: Text('Inactivo'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _state = v ?? 'Activo'),
                  decoration: const InputDecoration(labelText: 'Estado'),
                ),
                const SizedBox(height: 20),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        child: Text(isEdit ? 'Guardar cambios' : 'Agregar'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
