import 'package:dio/dio.dart';
import '../../../core/models/credit_session.dart';
import '../../../core/models/credit_item.dart';

class CreditItemRepository {
  final Dio _dio;

  CreditItemRepository(this._dio);

  Future<CreditSession> createSession(
      String customerId, CreateCreditSessionDto dto) async {
    final response =
        await _dio.post('/credits', queryParameters: {'membershipId': customerId}, data: dto.toJson());
    return CreditSession.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> cancelSession(String sessionId) async {
    await _dio.delete('/credits/$sessionId');
  }

  Future<CreditItem> addItemToSession(
      String sessionId, CreateCreditItemDto itemDto) async {
    final response =
        await _dio.post('/credits/$sessionId/items', data: itemDto.toJson());
    return CreditItem.fromJson(response.data as Map<String, dynamic>);
  }

  // ASSUMPTION — verify against your backend router before trusting this:
  // 1. Route is PATCH /credits/:id. If the backend only exposes POST /credits
  //    (create) and DELETE /credits/:id (cancel), this route doesn't exist
  //    yet and needs to be added server-side first — this call will 404/405.
  // 2. Payload keys ('deadline', 'ethiopianDeadline') match what
  //    CreateCreditSessionDto.toJson() sends for the same fields on create.
  //    If the backend DTO for update uses different key names (e.g. 'dueDate'
  //    instead of 'deadline'), this silently sends a payload the backend
  //    either ignores or 400s on. Check CreateCreditSessionDto.toJson() and
  //    the backend's session update schema side-by-side, don't assume.
  Future<CreditSession> updateSessionDeadline(
    String sessionId, {
    required DateTime deadline,
    required Map<String, int> ethiopianDeadline,
  }) async {
    final response = await _dio.patch('/credits/$sessionId', data: {
      'deadline': deadline.toIso8601String(),
      'ethiopianDeadline': ethiopianDeadline,
    });
    return CreditSession.fromJson(response.data as Map<String, dynamic>);
  }
}