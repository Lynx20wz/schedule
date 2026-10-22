import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedule_phone/lesson_offset.dart';

class LessonOffsetCard extends ConsumerStatefulWidget {
  const LessonOffsetCard({super.key});

  @override
  ConsumerState<LessonOffsetCard> createState() => _LessonOffsetCardState();
}

class _LessonOffsetCardState extends ConsumerState<LessonOffsetCard> {
  static final double _maxSeconds = maxLessonOffset.inSeconds.toDouble();

  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final offset = ref.watch(lessonOffsetProvider).value ?? Duration.zero;
    final value = (_dragValue ?? offset.inSeconds.toDouble())
        .clamp(-_maxSeconds, _maxSeconds)
        .toDouble();
    final displayedOffset = Duration(seconds: value.round());
    final colorScheme = Theme.of(context).colorScheme;
    final accent = switch (displayedOffset.compareTo(Duration.zero)) {
      < 0 => colorScheme.tertiary,
      > 0 => colorScheme.primary,
      _ => colorScheme.onSurfaceVariant,
    };

    return Card(
      clipBehavior: .antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                Icon(Icons.timer_outlined, color: accent),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Сдвиг звонков',
                    style: TextStyle(fontWeight: .bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: displayedOffset == Duration.zero ? null : _reset,
                  icon: const Icon(Icons.restart_alt),
                  tooltip: 'Сбросить',
                ),
              ],
            ),

            Text(
              _formatOffset(displayedOffset),
              style: TextStyle(
                color: accent,
                fontSize: 34,
                fontWeight: .bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Slider(
              value: value,
              min: -_maxSeconds,
              max: _maxSeconds,
              divisions: maxLessonOffset.inSeconds * 2,
              label: _formatOffset(displayedOffset),
              activeColor: accent,
              onChanged: (value) => setState(() => _dragValue = value),
              onChangeEnd: (value) {
                setState(() => _dragValue = null);
                ref
                    .read(lessonOffsetProvider.notifier)
                    .set(Duration(seconds: value.round()));
              },
            ),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                _EdgeLabel(
                  _formatOffset(Duration(seconds: -maxLessonOffset.inSeconds)),
                  colorScheme,
                ),
                _EdgeLabel(_formatOffset(Duration.zero), colorScheme),
                _EdgeLabel(_formatOffset(maxLessonOffset), colorScheme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _reset() {
    setState(() => _dragValue = null);
    ref.read(lessonOffsetProvider.notifier).set(Duration.zero);
  }

  String _formatOffset(Duration offset) {
    if (offset == Duration.zero) return '0:00';

    final sign = offset.isNegative ? '-' : '+';
    return '$sign${_formatDuration(offset)}';
  }

  String _formatDuration(Duration offset) {
    final seconds = offset.inSeconds.abs();
    final minutes = seconds ~/ 60;
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }
}

class _EdgeLabel extends StatelessWidget {
  final String text;
  final ColorScheme colorScheme;

  const _EdgeLabel(this.text, this.colorScheme);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
  );
}
