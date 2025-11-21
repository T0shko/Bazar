// Platform-specific imports
import 'dart:io' if (dart.library.html) 'dart:html';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../models/sale_record.dart';
import 'action_log_service.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  final ActionLogService _actionLogService = ActionLogService();
  
  String? get _currentUserId => _client.auth.currentUser?.id;
  
  static const String _productImagesBucket = 'product-images';

  // Products CRUD operations
  Future<List<Product>> getProducts() async {
    try {
      final response = await _client
          .from('products')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final productData = product.toJson();
      // Remove id if it's a timestamp-based string, let Supabase generate UUID
      // Or keep it if it's already a valid UUID format
      if (!_isValidUUID(productData['id'] as String)) {
        productData.remove('id');
      }
      
      final response = await _client
          .from('products')
          .insert(productData)
          .select()
          .single();
      
      final createdProduct = Product.fromJson(response as Map<String, dynamic>);
      
      // Log action
      if (_currentUserId != null) {
        await _actionLogService.logAction(
          userId: _currentUserId!,
          actionType: 'create_product',
          entityType: 'product',
          entityId: createdProduct.id,
          newData: createdProduct.toJson(),
          description: 'Created product: ${product.name}',
        );
      }
      
      return createdProduct;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }
  
  bool _isValidUUID(String? id) {
    if (id == null) return false;
    // Check if it's a valid UUID format (8-4-4-4-12 hex characters)
    final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
    return uuidRegex.hasMatch(id);
  }

  Future<Product> updateProduct(Product product, {bool shouldLogAction = true}) async {
    try {
      // Get old data for logging (only if we're going to log)
      Map<String, dynamic>? oldData;
      if (shouldLogAction) {
        try {
          final oldResponse = await _client
              .from('products')
              .select()
              .eq('id', product.id)
              .single();
          oldData = oldResponse as Map<String, dynamic>;
        } catch (_) {}
      }
      
      final updatedData = product.toJson();
      updatedData['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _client
          .from('products')
          .update(updatedData)
          .eq('id', product.id)
          .select()
          .single();
      
      final updatedProduct = Product.fromJson(response as Map<String, dynamic>);
      
      // Log action only for manual edits (not for automatic stock updates from sales)
      if (shouldLogAction && _currentUserId != null) {
        await _actionLogService.logAction(
          userId: _currentUserId!,
          actionType: 'update_product',
          entityType: 'product',
          entityId: product.id,
          oldData: oldData,
          newData: updatedProduct.toJson(),
          description: 'Updated product: ${product.name}',
        );
      }
      
      return updatedProduct;
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      // Get old data for logging
      Map<String, dynamic>? oldData;
      String? productName;
      try {
        final oldResponse = await _client
            .from('products')
            .select()
            .eq('id', productId)
            .single();
        oldData = oldResponse as Map<String, dynamic>;
        productName = oldData['name'] as String?;
      } catch (_) {}
      
      await _client.from('products').delete().eq('id', productId);
      
      // Log action
      if (_currentUserId != null) {
        await _actionLogService.logAction(
          userId: _currentUserId!,
          actionType: 'delete_product',
          entityType: 'product',
          entityId: productId,
          oldData: oldData,
          description: 'Deleted product: ${productName ?? productId}',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Sales CRUD operations
  Future<List<SaleRecord>> getSales() async {
    try {
      final response = await _client
          .from('sales')
          .select('*, products(*)')
          .order('date', ascending: false);
      
      return (response as List).map((json) {
        final saleJson = json as Map<String, dynamic>;
        Product? product;
        
        if (saleJson['products'] != null) {
          final productJson = saleJson['products'] as Map<String, dynamic>;
          product = Product.fromJson(productJson);
        }
        
        return SaleRecord.fromJson(saleJson, product: product);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch sales: $e');
    }
  }

  Future<SaleRecord> createSale(SaleRecord sale) async {
    try {
      final saleData = sale.toJson();
      // Remove id if it's a timestamp-based string, let Supabase generate UUID
      if (!_isValidUUID(saleData['id'] as String)) {
        saleData.remove('id');
      }
      
      final response = await _client
          .from('sales')
          .insert(saleData)
          .select('*, products(*)')
          .single();
      
      final saleJson = response as Map<String, dynamic>;
      Product? product;
      
      if (saleJson['products'] != null) {
        final productJson = saleJson['products'] as Map<String, dynamic>;
        product = Product.fromJson(productJson);
      }
      
      final createdSale = SaleRecord.fromJson(saleJson, product: product);
      
      // Log sale creation for analytics
      if (_currentUserId != null) {
        String actionType;
        String saleDescription;
        
        if (sale.product != null) {
          actionType = 'create_sale';
          saleDescription = 'Created sale: ${sale.product!.name} x${sale.quantity}';
        } else if (sale.coffeeAmount != null) {
          actionType = 'create_coffee_sale';
          saleDescription = 'Created coffee sale: ${sale.coffeeAmount} лв.';
        } else if (sale.donationAmount != null) {
          actionType = 'create_donation';
          saleDescription = 'Created donation: ${sale.donationAmount} лв.';
        } else {
          actionType = 'create_sale';
          saleDescription = 'Created sale';
        }
        
        await _actionLogService.logAction(
          userId: _currentUserId!,
          actionType: actionType,
          entityType: 'sale',
          entityId: createdSale.id,
          newData: createdSale.toJson(),
          description: saleDescription,
        );
      }
      
      return createdSale;
    } catch (e) {
      throw Exception('Failed to create sale: $e');
    }
  }

  Future<void> deleteSale(String saleId) async {
    try {
      // Get old data for logging
      Map<String, dynamic>? oldData;
      try {
        final oldResponse = await _client
            .from('sales')
            .select('*, products(*)')
            .eq('id', saleId)
            .single();
        oldData = oldResponse as Map<String, dynamic>;
      } catch (_) {}
      
      await _client.from('sales').delete().eq('id', saleId);
      
      // Log action
      if (_currentUserId != null) {
        // Determine sale type from old data for better logging
        String actionType = 'delete_sale';
        String description = 'Deleted sale: $saleId';
        
        if (oldData != null) {
          final coffeeAmount = oldData['coffee_amount'] as String?;
          final donationAmount = oldData['donation_amount'] as String?;
          final productId = oldData['product_id'] as String?;
          
          if (donationAmount != null) {
            actionType = 'delete_donation';
            description = 'Deleted donation: $donationAmount лв.';
          } else if (coffeeAmount != null) {
            actionType = 'delete_coffee_sale';
            description = 'Deleted coffee sale: $coffeeAmount лв.';
          } else if (productId != null) {
            actionType = 'delete_sale';
            description = 'Deleted product sale: $saleId';
          }
        }
        
        await _actionLogService.logAction(
          userId: _currentUserId!,
          actionType: actionType,
          entityType: 'sale',
          entityId: saleId,
          oldData: oldData,
          description: description,
        );
      }
    } catch (e) {
      throw Exception('Failed to delete sale: $e');
    }
  }

  // Real-time subscriptions
  Stream<List<Product>> watchProducts() {
    return _client
        .from('products')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => (data as List)
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList());
  }

  Stream<List<SaleRecord>> watchSales() {
    return _client
        .from('sales')
        .stream(primaryKey: ['id'])
        .order('date', ascending: false)
        .map((data) {
          return (data as List).map((json) {
            final saleJson = json as Map<String, dynamic>;
            Product? product;
            
            if (saleJson['products'] != null) {
              final productJson = saleJson['products'] as Map<String, dynamic>;
              product = Product.fromJson(productJson);
            }
            
            return SaleRecord.fromJson(saleJson, product: product);
          }).toList();
        });
  }

  // Image upload methods
  Future<String> uploadProductImage(String productId, dynamic imageFile) async {
    try {
      // Check if bucket exists, if not provide helpful error
      try {
        // Try to list files in the bucket (empty list is fine, we just want to check if bucket exists)
        await _client.storage.from(_productImagesBucket).list();
      } catch (e) {
        if (e.toString().contains('not found') || e.toString().contains('Bucket not found')) {
          throw Exception(
            'Storage bucket "$_productImagesBucket" not found. '
            'Please create it in Supabase Dashboard:\n'
            '1. Go to Storage in your Supabase dashboard\n'
            '2. Click "New bucket"\n'
            '3. Name it: $_productImagesBucket\n'
            '4. Check "Public bucket"\n'
            '5. Click "Create bucket"\n'
            'Then run the storage policies SQL from STORAGE_SETUP.md'
          );
        }
        rethrow;
      }

      final fileName = '$productId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$productId/$fileName';

      // Upload the image file
      // On web, imageFile is XFile, on mobile it's File
      if (kIsWeb) {
        // On web, convert XFile to bytes
        final xFile = imageFile as XFile;
        final bytes = await xFile.readAsBytes();
        await _client.storage.from(_productImagesBucket).uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );
      } else {
        // On mobile/desktop, upload File directly
        // File type is dart:io.File on mobile/desktop
        // ignore: avoid_as
        final file = imageFile as File;
        await _client.storage.from(_productImagesBucket).upload(
          filePath,
          file,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );
      }

      // Get the public URL
      final imageUrl = _client.storage.from(_productImagesBucket).getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      if (e.toString().contains('not found') || e.toString().contains('Bucket not found')) {
        rethrow; // Re-throw the helpful error message above
      }
      throw Exception('Failed to upload product image: $e');
    }
  }

  Future<void> deleteProductImage(String imageUrl) async {
    try {
      // Extract the file path from the URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the index of the bucket name
      final bucketIndex = pathSegments.indexOf(_productImagesBucket);
      if (bucketIndex == -1 || bucketIndex == pathSegments.length - 1) {
        throw Exception('Invalid image URL format');
      }
      
      // Get the file path after the bucket name
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      
      await _client.storage.from(_productImagesBucket).remove([filePath]);
    } catch (e) {
      // Log error but don't throw - image deletion is not critical
      print('Failed to delete product image: $e');
    }
  }
}

