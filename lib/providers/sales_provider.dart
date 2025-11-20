import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/product.dart';
import '../models/sale_record.dart';
import '../services/supabase_service.dart';

class SalesProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  final List<Product> _products = [];
  final List<SaleRecord> _sales = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => List.unmodifiable(_products);
  List<SaleRecord> get sales => List.unmodifiable(_sales);
  bool get isLoading => _isLoading;
  String? get error => _error;

  StreamSubscription<List<Product>>? _productsSubscription;
  StreamSubscription<List<SaleRecord>>? _salesSubscription;

  SalesProvider() {
    _initializeSubscriptions();
    // Load initial data
    loadData();
  }

  void _initializeSubscriptions() {
    // Subscribe to real-time updates for products
    _productsSubscription = _supabaseService.watchProducts().listen(
      (products) {
        _products.clear();
        _products.addAll(products);
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );

    // Subscribe to real-time updates for sales
    _salesSubscription = _supabaseService.watchSales().listen(
      (sales) {
        _sales.clear();
        _sales.addAll(sales);
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final productsData = await _supabaseService.getProducts();
      final salesData = await _supabaseService.getSales();

      _products.clear();
      _products.addAll(productsData);

      _sales.clear();
      _sales.addAll(salesData);

      _error = null;
    } catch (e) {
      _error = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      _error = null;
      final createdProduct = await _supabaseService.createProduct(product);
      // The subscription will automatically update the list
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add product: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduct(Product product, {bool shouldLogAction = true}) async {
    try {
      _error = null;
      await _supabaseService.updateProduct(product, shouldLogAction: shouldLogAction);
      // The subscription will automatically update the list
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update product: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      _error = null;
      await _supabaseService.deleteProduct(productId);
      // The subscription will automatically update the list
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete product: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addSale(SaleRecord sale) async {
    try {
      _error = null;
      await _supabaseService.createSale(sale);
      // The subscription will automatically update the list
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add sale: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSale(String saleId) async {
    try {
      _error = null;
      await _supabaseService.deleteSale(saleId);
      // The subscription will automatically update the list
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete sale: $e';
      notifyListeners();
      rethrow;
    }
  }

  double getTotalSales() {
    return _sales.fold(0.0, (sum, sale) => sum + sale.total);
  }

  double getCoffeeSales() {
    return _sales
        .where((sale) => sale.coffeeAmount != null)
        .fold(0.0, (sum, sale) => sum + sale.total);
  }

  double getDonationSales() {
    return _sales
        .where((sale) => sale.donationAmount != null)
        .fold(0.0, (sum, sale) => sum + sale.total);
  }

  double getProductSales() {
    return _sales
        .where((sale) => sale.product != null)
        .fold(0.0, (sum, sale) => sum + sale.total);
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    _salesSubscription?.cancel();
    super.dispose();
  }
}

