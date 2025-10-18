import 'package:flutter/material.dart';
import 'product.dart';
import 'product_service.dart';

class ProductFormPage extends StatefulWidget {
  final Product? initial; // si viene, editamos

  const ProductFormPage({super.key, this.initial});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _nameCtrl.text = widget.initial!.name;
      _priceCtrl.text = widget.initial!.price.toStringAsFixed(0);
      _imageCtrl.text = widget.initial!.image;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final name = _nameCtrl.text.trim();
      final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
      final image = _imageCtrl.text.trim().isEmpty
          ? 'https://via.placeholder.com/300x200.png?text=Producto'
          : _imageCtrl.text.trim();

      if (widget.initial == null) {
        // Crear
        await ProductService.add(name: name, price: price, image: image);
      } else {
        // Editar
        await ProductService.edit(
          id: widget.initial!.id,
          name: name,
          price: price,
          image: image,
          state: widget.initial!.state ?? 'Activo',
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true); // devolvemos éxito
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
        title: Text(isEdit ? 'Editar producto' : 'Agregar producto'),
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
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'El nombre es obligatorio'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Precio (solo números)',
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'El precio es obligatorio';
                    final d = double.tryParse(v.trim());
                    if (d == null) return 'Formato inválido';
                    if (d <= 0) return 'Debe ser mayor a 0';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL de imagen (opcional)',
                    hintText: 'https://…',
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
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
