// lib/modules/home/home_page.dart
import 'package:flutter/material.dart';

import 'package:app_examen/modules/products/product_list_page.dart';
import 'package:app_examen/modules/categories/category_list_page.dart';
import 'package:app_examen/modules/providers/provider_list_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_examen/modules/products/product_form_page.dart';
import 'package:app_examen/modules/categories/category_form_page.dart';
import 'package:app_examen/modules/providers/provider_form_page.dart';
import 'package:app_examen/modules/login/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab; // controlador propio, determinístico
  int _bump = 0; // fuerza refetch en las listas al volver del form

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _openAddForCurrentTab() async {
    bool? saved;
    if (_tab.index == 0) {
      saved = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => const ProductFormPage()));
    } else if (_tab.index == 1) {
      saved = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => const CategoryFormPage()));
    } else {
      saved = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => const ProviderFormPage()));
    }

    if (saved == true && mounted) {
      setState(() => _bump++); // las listas harán _fetch() en initState
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Guardado correctamente.')));
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fab = AnimatedBuilder(
      animation: _tab,
      builder: (context, _) {
        final idx = _tab.index;
        final label = idx == 0
            ? 'Agregar producto'
            : idx == 1
            ? 'Agregar categoría'
            : 'Agregar proveedor';
        return FloatingActionButton.extended(
          onPressed: _openAddForCurrentTab,
          icon: const Icon(Icons.add),
          label: Text(label),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('APP - EXAMEN'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Productos', icon: Icon(Icons.shopping_bag_outlined)),
            Tab(text: 'Categorías', icon: Icon(Icons.category_outlined)),
            Tab(text: 'Proveedores', icon: Icon(Icons.local_shipping_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          ProductListPage(embedded: true, key: ValueKey('products-$_bump')),
          CategoryListPage(embedded: true, key: ValueKey('categories-$_bump')),
          ProviderListPage(embedded: true, key: ValueKey('providers-$_bump')),
        ],
      ),
      floatingActionButton: fab,
    );
  }
}
