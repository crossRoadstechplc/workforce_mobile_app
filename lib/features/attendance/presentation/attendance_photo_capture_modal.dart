import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';

enum AttendancePhotoPurpose { checkIn, checkOut }

/// Local selfie capture only — no upload. Returns `true` when the user confirms a photo.
Future<bool?> showAttendancePhotoCapture(
  BuildContext context, {
  required AttendancePhotoPurpose purpose,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _AttendancePhotoCaptureDialog(purpose: purpose),
  );
}

class _AttendancePhotoCaptureDialog extends StatefulWidget {
  const _AttendancePhotoCaptureDialog({required this.purpose});

  final AttendancePhotoPurpose purpose;

  @override
  State<_AttendancePhotoCaptureDialog> createState() => _AttendancePhotoCaptureDialogState();
}

class _AttendancePhotoCaptureDialogState extends State<_AttendancePhotoCaptureDialog> {
  final _picker = ImagePicker();
  Uint8List? _bytes;
  bool _permissionDenied = false;
  String? _error;

  Future<bool> _ensureCameraAccess() async {
    if (kIsWeb) return true;

    var status = await Permission.camera.status;
    if (status.isGranted || status.isLimited) return true;

    status = await Permission.camera.request();
    if (status.isGranted || status.isLimited) return true;

    if (!mounted) return false;
    setState(() {
      _permissionDenied = true;
      _error = context.l10n.photoCameraPermissionRequired;
    });
    return false;
  }

  Future<void> _openPermissionSettings() async {
    if (kIsWeb) return;
    await openAppSettings();
  }

  Future<void> _capture() async {
    setState(() {
      _error = null;
      _permissionDenied = false;
    });

    final allowed = await _ensureCameraAccess();
    if (!allowed) return;

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 82,
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() => _bytes = bytes);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _permissionDenied = true;
        _error = kIsWeb
            ? context.l10n.photoCameraPermissionWeb
            : context.l10n.photoCameraPermissionRequired;
      });
    }
  }

  void _confirm() {
    if (_bytes == null) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final title = widget.purpose == AttendancePhotoPurpose.checkIn
        ? l10n.photoCaptureTitleCheckIn
        : l10n.photoCaptureTitleCheckOut;

    return Dialog(
      backgroundColor: colors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.photoCaptureHint,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            _CirclePreview(
              bytes: _bytes,
              colors: colors,
              onTap: _capture,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.error, fontSize: 12, height: 1.35),
              ),
              if (_permissionDenied && !kIsWeb) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _openPermissionSettings,
                  child: Text(l10n.photoOpenSettings),
                ),
              ],
            ],
            const SizedBox(height: 20),
            if (_bytes == null)
              FilledButton.icon(
                onPressed: _capture,
                icon: const Icon(Icons.camera_alt_rounded, size: 20),
                label: Text(l10n.photoCaptureButton),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _capture,
                      child: Text(l10n.photoRetake),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _confirm,
                      child: Text(l10n.photoUse),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }
}

class _CirclePreview extends StatelessWidget {
  const _CirclePreview({
    required this.bytes,
    required this.colors,
    this.onTap,
  });

  final Uint8List? bytes;
  final AppColorsExtension colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const size = 220.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.muted,
            border: Border.all(color: colors.primary.withValues(alpha: 0.35), width: 3),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.12),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: bytes == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.face_retouching_natural_rounded, size: 48, color: colors.primary.withValues(alpha: 0.7)),
                    const SizedBox(height: 8),
                    Icon(Icons.camera_alt_outlined, size: 22, color: colors.textSecondary),
                  ],
                )
              : Image.memory(bytes!, fit: BoxFit.cover, width: size, height: size),
        ),
      ),
    );
  }
}
