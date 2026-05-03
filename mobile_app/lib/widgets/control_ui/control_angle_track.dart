import 'package:flutter/material.dart';

class ControlAngleTrack extends StatelessWidget {
  final double currentAngle;
  final List<ControlAngleMark> marks;
  final double minAngle;
  final double maxAngle;
  final List<String> scaleLabels;

  const ControlAngleTrack({
    super.key,
    required this.currentAngle,
    this.marks = const [],
    this.minAngle = -10,
    this.maxAngle = 120,
    this.scaleLabels = const ['-10°', '30°', '60°', '90°', '120°'],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (marks.isNotEmpty) ...[
            Row(
              children: marks
                  .asMap()
                  .entries
                  .expand((entry) {
                final i = entry.key;
                final mark = entry.value;

                return <Widget>[
                  Expanded(
                    child: _ZoneChip(
                      icon: mark.icon,
                      label: '${mark.value.toInt()}°',
                      dark: mark.dark,
                    ),
                  ),
                  if (i != marks.length - 1) const SizedBox(width: 6),
                ];
              })
                  .toList(),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            height: 46,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;

                double xFromAngle(double value) =>
                    ((value - minAngle) / (maxAngle - minAngle)) * w;

                return Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 16,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9ECF4),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Positioned(
                      left: xFromAngle(
                        currentAngle.clamp(minAngle, maxAngle),
                      ) -
                          6,
                      top: 10,
                      child: Container(
                        width: 12,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    for (final mark in marks)
                      Positioned(
                        left: xFromAngle(
                          mark.value.clamp(minAngle, maxAngle),
                        ) -
                            2,
                        top: 8,
                        child: Container(
                          width: 4,
                          height: 22,
                          decoration: BoxDecoration(
                            color:
                            mark.dark ? Colors.black : Colors.blue.shade300,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    Positioned.fill(
                      top: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: scaleLabels
                            .map(
                              (label) => Text(
                            label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        )
                            .toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ControlAngleMark {
  final double value;
  final IconData icon;
  final bool dark;

  const ControlAngleMark({
    required this.value,
    required this.icon,
    this.dark = false,
  });
}

class _ZoneChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool dark;

  const _ZoneChip({
    required this.icon,
    required this.label,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: dark ? Colors.black : const Color(0xFFE7EBFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: dark ? Colors.white : Colors.blue,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: dark ? Colors.white : Colors.blueGrey.shade800,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}