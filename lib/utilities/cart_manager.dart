import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final ValueNotifier<int> cartCount = ValueNotifier<int>(0);
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  double get totalPrice =>
      _cartItems.fold(0.0, (s, i) => s + i.product.price * i.quantity);

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart');
      if (cartData != null) {
        final decoded = jsonDecode(cartData) as List;
        _cartItems = decoded
            .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        _cartItems = [];
      }
      _updateNotifier();
    } catch (e) {
      // ignore or log
      _cartItems = [];
      _updateNotifier();
    }
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final index = _cartItems.indexWhere((c) => c.product.id == product.id);
    if (index >= 0) {
      _cartItems[index].quantity += quantity;
    } else {
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
    await _saveCart();
    _updateNotifier();
  }

  Future<void> changeQuantity(Product product, int newQuantity) async {
    final index = _cartItems.indexWhere((c) => c.product.id == product.id);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = newQuantity;
      }
      await _saveCart();
      _updateNotifier();
    }
  }

  Future<void> removeFromCart(Product product) async {
    _cartItems.removeWhere((c) => c.product.id == product.id);
    await _saveCart();
    _updateNotifier();
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    await _saveCart();
    _updateNotifier();
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_cartItems.map((c) => c.toJson()).toList());
    await prefs.setString('cart', encoded);
  }

  void _updateNotifier() {
    cartCount.value = _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }
}
