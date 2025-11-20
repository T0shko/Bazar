import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/action_log.dart';

class ActionLogService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> logAction({
    required String userId,
    required String actionType,
    required String entityType,
    String? entityId,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
    required String description,
  }) async {
    try {
      // Get username from user profile
      String? username;
      try {
        final profileResponse = await _client
            .from('user_profiles')
            .select('username')
            .eq('id', userId)
            .single();
        username = profileResponse['username'] as String?;
      } catch (e) {
        // If profile doesn't exist, use email
        try {
          final authUser = _client.auth.currentUser;
          username = authUser?.email?.split('@')[0];
        } catch (_) {}
      }

      await _client.from('action_logs').insert({
        'user_id': userId,
        'username': username,
        'action_type': actionType,
        'entity_type': entityType,
        'entity_id': entityId,
        'old_data': oldData,
        'new_data': newData,
        'description': description,
        'timestamp': DateTime.now().toIso8601String(),
        'is_rolled_back': false,
      });
    } catch (e) {
      // Don't throw - logging shouldn't break the app
      print('Failed to log action: $e');
    }
  }

  Future<List<ActionLog>> getActionLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    String? actionType,
    int? limit,
  }) async {
    try {
      var query = _client.from('action_logs').select();

      if (startDate != null) {
        query = query.gte('timestamp', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('timestamp', endDate.toIso8601String());
      }
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      if (actionType != null) {
        query = query.eq('action_type', actionType);
      }
      
      var orderedQuery = query.order('timestamp', ascending: false);
      
      if (limit != null) {
        orderedQuery = orderedQuery.limit(limit);
      }

      final response = await orderedQuery;
      return (response as List)
          .map((json) => ActionLog.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch action logs: $e');
    }
  }

  Future<Map<String, dynamic>> getActionStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client.from('action_logs').select();
      
      if (startDate != null) {
        query = query.gte('timestamp', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('timestamp', endDate.toIso8601String());
      }

      final logs = await query;
      final logsList = logs as List;

      // Count actions by type
      final actionTypeCounts = <String, int>{};
      final userActionCounts = <String, int>{};
      final dailyCounts = <String, int>{};

      for (var log in logsList) {
        final logMap = log as Map<String, dynamic>;
        final actionType = logMap['action_type'] as String;
        final username = logMap['username'] as String? ?? 'Unknown';
        final timestamp = DateTime.parse(logMap['timestamp'] as String);
        final dateKey = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';

        actionTypeCounts[actionType] = (actionTypeCounts[actionType] ?? 0) + 1;
        userActionCounts[username] = (userActionCounts[username] ?? 0) + 1;
        dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
      }

      return {
        'total_actions': logsList.length,
        'action_type_counts': actionTypeCounts,
        'user_action_counts': userActionCounts,
        'daily_counts': dailyCounts,
      };
    } catch (e) {
      throw Exception('Failed to get action stats: $e');
    }
  }

  Future<void> rollbackAction(String actionLogId) async {
    try {
      // Get the action log
      final logResponse = await _client
          .from('action_logs')
          .select()
          .eq('id', actionLogId)
          .single();

      final log = ActionLog.fromJson(logResponse);

      if (log.isRolledBack) {
        throw Exception('Action has already been rolled back');
      }

      // Perform rollback based on action type
      final entityId = log.entityId;
      final oldData = log.oldData;
      
      if (oldData != null) {
        // Convert Map<String, dynamic> to Map<dynamic, dynamic> for Supabase
        final dataMap = Map<dynamic, dynamic>.from(oldData);
        
        // Remove fields that shouldn't be updated (like created_at, updated_at for inserts)
        switch (log.actionType) {
          case 'delete_product':
            // For restoring deleted products, remove timestamps to let DB set them
            dataMap.remove('created_at');
            dataMap.remove('updated_at');
            break;
          case 'delete_sale':
            // For restoring deleted sales, remove timestamps
            dataMap.remove('created_at');
            dataMap.remove('date');
            break;
          case 'update_product':
            // For updates, keep updated_at to track when it was rolled back
            // dataMap already contains all fields from oldData including stock_quantity
            dataMap['updated_at'] = DateTime.now().toIso8601String();
            break;
        }
        
        switch (log.actionType) {
          case 'create_product':
            if (entityId != null) {
              // Find and delete all sales related to this product
              final relatedSales = await _client
                  .from('sales')
                  .select('id')
                  .eq('product_id', entityId);
              
              if (relatedSales != null && (relatedSales as List).isNotEmpty) {
                final saleIds = (relatedSales as List)
                    .map((sale) => sale['id'] as String)
                    .toList();
                
                // Delete all related sales
                for (final saleId in saleIds) {
                  await _client.from('sales').delete().eq('id', saleId);
                  
                  // Mark related sale action logs as rolled back
                  await _client
                      .from('action_logs')
                      .update({
                        'is_rolled_back': true,
                        'rolled_back_at': DateTime.now().toIso8601String(),
                      })
                      .eq('entity_id', saleId)
                      .eq('entity_type', 'sale');
                }
              }
              
              // Mark all action logs related to this product as rolled back
              await _client
                  .from('action_logs')
                  .update({
                    'is_rolled_back': true,
                    'rolled_back_at': DateTime.now().toIso8601String(),
                  })
                  .eq('entity_id', entityId)
                  .eq('entity_type', 'product');
              
              // Finally, delete the product
              await _client.from('products').delete().eq('id', entityId);
            }
            break;
          case 'update_product':
            if (entityId != null) {
              // Restore all fields from oldData, ensuring stock_quantity is included
              // Remove id if present (shouldn't update the id)
              final updateData = Map<dynamic, dynamic>.from(dataMap);
              updateData.remove('id');
              
              await _client.from('products').update(updateData).eq('id', entityId);
            }
            break;
          case 'delete_product':
            if (entityId != null) {
              // Restore deleted product with original ID
              final insertData = Map<dynamic, dynamic>.from(dataMap);
              // Ensure we use the original ID
              insertData['id'] = entityId;
              await _client.from('products').insert(insertData);
            }
            break;
          case 'create_sale':
          case 'create_coffee_sale':
          case 'create_donation':
            if (entityId != null) {
              // Get the sale data from newData (stored in action log) to restore product stock
              final newData = log.newData;
              String? productId;
              int quantity = 0;
              
              // Try to get sale data from database first, fallback to newData from log
              try {
                final saleResponse = await _client
                    .from('sales')
                    .select('*, products(*)')
                    .eq('id', entityId)
                    .single();
                
                final saleData = saleResponse as Map<String, dynamic>;
                productId = saleData['product_id'] as String?;
                quantity = saleData['quantity'] as int? ?? 0;
                
                // Delete the sale
                await _client.from('sales').delete().eq('id', entityId);
              } catch (e) {
                // Sale might already be deleted, get data from action log's newData
                if (newData != null) {
                  productId = newData['product_id'] as String?;
                  quantity = newData['quantity'] as int? ?? 0;
                }
              }
              
              // Restore product stock quantity only if this was a product sale
              // Donations and coffee sales don't have products, so skip stock restoration
              if (log.actionType == 'create_sale' && productId != null && quantity > 0) {
                try {
                  // Get current product stock
                  final productResponse = await _client
                      .from('products')
                      .select('stock_quantity')
                      .eq('id', productId)
                      .single();
                  
                  final currentStock = (productResponse['stock_quantity'] as int? ?? 0);
                  final newStock = currentStock + quantity;
                  
                  // Update product stock
                  await _client
                      .from('products')
                      .update({
                        'stock_quantity': newStock,
                        'updated_at': DateTime.now().toIso8601String(),
                      })
                      .eq('id', productId);
                } catch (e) {
                  // Product might not exist anymore, ignore
                  print('Could not restore stock for product $productId: $e');
                }
              }
            }
            break;
          case 'delete_sale':
          case 'delete_coffee_sale':
          case 'delete_donation':
            if (entityId != null) {
              // Restore deleted sale with original ID
              // This works for all sale types: product sales, coffee sales, and donations
              final insertData = Map<dynamic, dynamic>.from(dataMap);
              // Ensure we use the original ID
              insertData['id'] = entityId;
              // Remove timestamps to let DB set them
              insertData.remove('created_at');
              insertData.remove('date');
              await _client.from('sales').insert(insertData);
            }
            break;
          default:
            throw Exception('Rollback not supported for action type: ${log.actionType}');
        }
      } else {
        // No old data available, can only delete created items
        switch (log.actionType) {
          case 'create_product':
            if (entityId != null) {
              // Find and delete all sales related to this product
              final relatedSales = await _client
                  .from('sales')
                  .select('id')
                  .eq('product_id', entityId);
              
              if (relatedSales != null && (relatedSales as List).isNotEmpty) {
                final saleIds = (relatedSales as List)
                    .map((sale) => sale['id'] as String)
                    .toList();
                
                // Delete all related sales
                for (final saleId in saleIds) {
                  await _client.from('sales').delete().eq('id', saleId);
                  
                  // Mark related sale action logs as rolled back
                  await _client
                      .from('action_logs')
                      .update({
                        'is_rolled_back': true,
                        'rolled_back_at': DateTime.now().toIso8601String(),
                      })
                      .eq('entity_id', saleId)
                      .eq('entity_type', 'sale');
                }
              }
              
              // Mark all action logs related to this product as rolled back
              await _client
                  .from('action_logs')
                  .update({
                    'is_rolled_back': true,
                    'rolled_back_at': DateTime.now().toIso8601String(),
                  })
                  .eq('entity_id', entityId)
                  .eq('entity_type', 'product');
              
              // Finally, delete the product
              await _client.from('products').delete().eq('id', entityId);
            }
            break;
          case 'create_sale':
          case 'create_coffee_sale':
          case 'create_donation':
            if (entityId != null) {
              // Get the sale data from newData (stored in action log) to restore product stock
              final newData = log.newData;
              String? productId;
              int quantity = 0;
              
              // Try to get sale data from database first, fallback to newData from log
              try {
                final saleResponse = await _client
                    .from('sales')
                    .select('*, products(*)')
                    .eq('id', entityId)
                    .single();
                
                final saleData = saleResponse as Map<String, dynamic>;
                productId = saleData['product_id'] as String?;
                quantity = saleData['quantity'] as int? ?? 0;
                
                // Delete the sale
                await _client.from('sales').delete().eq('id', entityId);
              } catch (e) {
                // Sale might already be deleted, get data from action log's newData
                if (newData != null) {
                  productId = newData['product_id'] as String?;
                  quantity = newData['quantity'] as int? ?? 0;
                }
              }
              
              // Restore product stock quantity only if this was a product sale
              // Donations and coffee sales don't have products, so skip stock restoration
              if (log.actionType == 'create_sale' && productId != null && quantity > 0) {
                try {
                  // Get current product stock
                  final productResponse = await _client
                      .from('products')
                      .select('stock_quantity')
                      .eq('id', productId)
                      .single();
                  
                  final currentStock = (productResponse['stock_quantity'] as int? ?? 0);
                  final newStock = currentStock + quantity;
                  
                  // Update product stock
                  await _client
                      .from('products')
                      .update({
                        'stock_quantity': newStock,
                        'updated_at': DateTime.now().toIso8601String(),
                      })
                      .eq('id', productId);
                } catch (e) {
                  // Product might not exist anymore, ignore
                  print('Could not restore stock for product $productId: $e');
                }
              }
            }
            break;
          default:
            throw Exception('Cannot rollback ${log.actionType}: no old data available');
        }
      }

      // Mark action as rolled back
      await _client
          .from('action_logs')
          .update({
            'is_rolled_back': true,
            'rolled_back_at': DateTime.now().toIso8601String(),
          })
          .eq('id', actionLogId);

      // Log the rollback action
      await logAction(
        userId: log.userId,
        actionType: 'rollback_action',
        entityType: 'action_log',
        entityId: actionLogId,
        description: 'Rolled back: ${log.description}',
      );
    } catch (e) {
      throw Exception('Failed to rollback action: $e');
    }
  }
}

