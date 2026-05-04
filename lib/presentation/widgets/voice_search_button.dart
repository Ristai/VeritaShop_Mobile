import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Voice Search Button với các trạng thái:
/// - Idle: Mic icon
/// - Recording: Animated pulse với duration
/// - Transcribing: Loading spinner
class VoiceSearchButton extends StatefulWidget {
  final bool isRecording;
  final bool isTranscribing;
  final Duration recordingDuration;
  final VoidCallback? onStartRecording;
  final VoidCallback? onStopRecording;
  final VoidCallback? onCancel;

  const VoiceSearchButton({
    super.key,
    this.isRecording = false,
    this.isTranscribing = false,
    this.recordingDuration = Duration.zero,
    this.onStartRecording,
    this.onStopRecording,
    this.onCancel,
  });

  @override
  State<VoiceSearchButton> createState() => _VoiceSearchButtonState();
}

class _VoiceSearchButtonState extends State<VoiceSearchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant VoiceSearchButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds;
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // Processing state
    if (widget.isTranscribing) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: kAccentColor,
            ),
          ),
        ),
      );
    }

    // Recording state
    if (widget.isRecording) {
      return GestureDetector(
        onTap: widget.onStopRecording,
        onLongPress: widget.onCancel,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: kRedColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kRedColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: kRedColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDuration(widget.recordingDuration),
                      style: const TextStyle(
                        color: kRedColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.stop_rounded, color: kRedColor, size: 20),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    // Idle state - Press to start
    return GestureDetector(
      onTap: widget.onStartRecording,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Icon(
          Icons.mic_rounded,
          color: colors.secondaryText,
          size: 22,
        ),
      ),
    );
  }
}
