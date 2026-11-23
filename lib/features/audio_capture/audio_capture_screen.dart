import 'dart:async';

import 'package:athaar/features/audio_capture/audio_capture_controller.dart';
import 'package:athaar/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioCaptureScreen extends ConsumerStatefulWidget {
  const AudioCaptureScreen({super.key});

  @override
  ConsumerState<AudioCaptureScreen> createState() =>
      _AudioCaptureScreenState();
}

class _AudioCaptureScreenState extends ConsumerState<AudioCaptureScreen>
    with WidgetsBindingObserver {
  late AudioCaptureController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = ref.read(audioCaptureControllerProvider.notifier);
    _controller.setForeground(_isAppResumed());
    unawaited(_controller.prepare());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller.setForeground(state == AppLifecycleState.resumed);
  }

  bool _isAppResumed() =>
      WidgetsBinding.instance.lifecycleState == null ||
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(audioCaptureControllerProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.audioCaptureTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.phonelink_lock_rounded, color: colors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.audioPrivacyTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.audioPrivacyBody,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _StatusPanel(state: state, l10n: l10n),
            if (state.error case final error?) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(
                  _errorMessage(l10n, error),
                  style: TextStyle(color: colors.error),
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (state.status == AudioCaptureStatus.idle)
              FilledButton.icon(
                key: const ValueKey('audio-start'),
                onPressed: state.isBusy
                    ? null
                    : () => unawaited(_controller.start()),
                icon: const Icon(Icons.mic_rounded),
                label: Text(l10n.audioStart),
              ),
            if (state.status == AudioCaptureStatus.recording)
              FilledButton.icon(
                key: const ValueKey('audio-stop-recording'),
                onPressed: () => unawaited(_controller.stop()),
                icon: const Icon(Icons.stop_circle_outlined),
                label: Text(l10n.audioStopRecording),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                ),
              ),
            if (state.status == AudioCaptureStatus.requestingPermission ||
                state.status == AudioCaptureStatus.stopping ||
                state.status == AudioCaptureStatus.deleting)
              const Center(child: CircularProgressIndicator()),
            if (state.status == AudioCaptureStatus.preparing)
              Center(child: Text(l10n.audioPreparing)),
            if (state.status == AudioCaptureStatus.recorded ||
                state.status == AudioCaptureStatus.playing)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (state.status == AudioCaptureStatus.recorded)
                    OutlinedButton.icon(
                      key: const ValueKey('audio-play'),
                      onPressed: () => unawaited(_controller.play()),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(l10n.audioPlay),
                    ),
                  if (state.status == AudioCaptureStatus.playing)
                    OutlinedButton.icon(
                      key: const ValueKey('audio-stop-playback'),
                      onPressed: () => unawaited(_controller.stopPlayback()),
                      icon: const Icon(Icons.stop_rounded),
                      label: Text(l10n.audioStopPlayback),
                    ),
                  TextButton.icon(
                    key: const ValueKey('audio-delete'),
                    onPressed: () => unawaited(_controller.deleteRecording()),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(l10n.audioDelete),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _errorMessage(AppLocalizations l10n, AudioCaptureError error) =>
      switch (error) {
        AudioCaptureError.preparationFailed => l10n.audioPreparationError,
        AudioCaptureError.permissionDenied => l10n.audioPermissionDenied,
        AudioCaptureError.recordingFailed => l10n.audioRecordingError,
        AudioCaptureError.playbackFailed => l10n.audioPlaybackError,
        AudioCaptureError.deletionFailed => l10n.audioDeletionError,
      };
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.state, required this.l10n});

  final AudioCaptureState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (icon, label, color) = switch (state.status) {
      AudioCaptureStatus.preparing =>
        (Icons.hourglass_empty_rounded, l10n.audioPreparing, colors.onSurfaceVariant),
      AudioCaptureStatus.idle =>
        (Icons.mic_none_rounded, l10n.audioReadyToRecord, colors.onSurfaceVariant),
      AudioCaptureStatus.requestingPermission =>
        (Icons.mic_none_rounded, l10n.audioRequestingPermission, colors.primary),
      AudioCaptureStatus.recording =>
        (Icons.fiber_manual_record_rounded, l10n.audioRecordingIndicator, colors.error),
      AudioCaptureStatus.stopping =>
        (Icons.hourglass_empty_rounded, l10n.audioStopping, colors.primary),
      AudioCaptureStatus.recorded =>
        (Icons.graphic_eq_rounded, l10n.audioRecordingReady, colors.primary),
      AudioCaptureStatus.playing =>
        (Icons.volume_up_rounded, l10n.audioPlaying, colors.primary),
      AudioCaptureStatus.deleting =>
        (Icons.delete_outline_rounded, l10n.audioDeleting, colors.primary),
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
