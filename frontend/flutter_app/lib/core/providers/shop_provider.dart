import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/shop.dart';
import 'api_client_provider.dart';

class ShopRepository {
  final Dio _dio;

  ShopRepository(this._dio);

  Future<List<Shop>> fetchMyShops() async {
    final response = await _dio.get('/shops');
    final data = response.data as List;
    return data.map((s) => Shop.fromJson(s as Map<String, dynamic>)).toList();
  }

  Future<List<Shop>> fetchCustomerShops() async {
    final response = await _dio.get('/shops/my-shops');
    final data = response.data as List;
    return data.map((s) => Shop.fromJson(s as Map<String, dynamic>)).toList();
  }

  Future<Shop> createShop({
    required String name,
    required String businessType,
    String? phone,
    String? email,
    String? address,
  }) async {
    final response = await _dio.post(
      '/shops',
      data: {
        'name': name,
        'businessType': businessType,
        'phone': phone,
        'email': email,
        'address': address,
      },
    );
    return Shop.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Shop> updateShop(
    String shopId, {
    required String name,
    required String businessType,
    String? phone,
    String? email,
    String? address,
  }) async {
    final response = await _dio.put(
      '/shops/$shopId',
      data: {
        'name': name,
        'businessType': businessType,
        'phone': phone,
        'email': email,
        'address': address,
      },
    );
    return Shop.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> joinShop(String inviteCode) async {
    await _dio.post(
      '/shops/join',
      data: {'inviteCode': inviteCode},
    );
  }
}

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository(ref.watch(dioProvider));
});

class ShopsListNotifier extends StateNotifier<AsyncValue<List<Shop>>> {
  final ShopRepository _repo;

  ShopsListNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> loadShops({bool isCustomer = false}) async {
    try {
      state = const AsyncValue.loading();
      final list = isCustomer 
          ? await _repo.fetchCustomerShops()
          : await _repo.fetchMyShops();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createNewShop({
    required String name,
    required String businessType,
    String? phone,
    String? email,
    String? address,
  }) async {
    try {
      final newShop = await _repo.createShop(
        name: name,
        businessType: businessType,
        phone: phone,
        email: email,
        address: address,
      );
      state.whenData((list) {
        state = AsyncValue.data([...list, newShop]);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateShopDetails(
    String shopId, {
    required String name,
    required String businessType,
    String? phone,
    String? email,
    String? address,
    required WidgetRef ref,
  }) async {
    try {
      final updated = await _repo.updateShop(
        shopId,
        name: name,
        businessType: businessType,
        phone: phone,
        email: email,
        address: address,
      );
      state.whenData((list) {
        state = AsyncValue.data(list.map((s) => s.id == shopId ? updated : s).toList());
      });

      final selected = ref.read(selectedShopProvider);
      if (selected != null && selected.id == shopId) {
        ref.read(selectedShopProvider.notifier).selectShop(updated);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final shopsListProvider = StateNotifierProvider<ShopsListNotifier, AsyncValue<List<Shop>>>((ref) {
  return ShopsListNotifier(ref.watch(shopRepositoryProvider));
});

class SelectedShopNotifier extends StateNotifier<Shop?> {
  SelectedShopNotifier() : super(null);

  void selectShop(Shop shop) {
    state = shop;
  }

  void clear() {
    state = null;
  }
}

final selectedShopProvider = StateNotifierProvider<SelectedShopNotifier, Shop?>((ref) {
  return SelectedShopNotifier();
});
