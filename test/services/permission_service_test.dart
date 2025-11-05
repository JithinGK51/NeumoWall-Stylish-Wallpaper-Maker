import 'package:flutter_test/flutter_test.dart';
import 'package:neumowall/services/permission_service.dart';

void main() {
  group('PermissionService', () {
    late PermissionService permissionService;

    setUp(() {
      permissionService = PermissionService();
    });

    test('hasStoragePermission returns boolean', () async {
      final result = await permissionService.hasStoragePermission();
      expect(result, isA<bool>());
    });

    test('hasCameraPermission returns boolean', () async {
      final result = await permissionService.hasCameraPermission();
      expect(result, isA<bool>());
    });

    test('openSettings does not throw', () async {
      // Just verify it doesn't throw
      expect(() => permissionService.openSettings(), returnsNormally);
    });
  });
}

