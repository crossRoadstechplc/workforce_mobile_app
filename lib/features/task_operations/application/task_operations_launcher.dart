import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';

final taskOperationsLauncherProvider = Provider<TaskOperationsLauncher>((ref) {
  return TaskOperationsLauncher(ref.watch(dioProvider));
});

class TaskOperationsLauncher {
  TaskOperationsLauncher(this._dio);

  final Dio _dio;

  Future<void> open() async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.taskTrackerSessionExchange,
      data: const <String, dynamic>{},
    );
    final data = response.data ?? const <String, dynamic>{};
    final nested = data['data'];
    final token = (data['exchangeToken'] ??
            (nested is Map<String, dynamic> ? nested['exchangeToken'] : null))
        ?.toString();
    if (token == null || token.isEmpty) {
      throw StateError('Task Operations handoff token missing.');
    }

    final uri = Uri.parse(
      '${AppConfig.resolvedTaskTrackerUrl}/auth/handoff?token=${Uri.encodeComponent(token)}',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw StateError('Could not open Task Operations.');
    }
  }
}
