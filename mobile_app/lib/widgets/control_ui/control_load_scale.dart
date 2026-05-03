import 'package:flutter/material.dart';

class ControlLoadScale extends StatelessWidget {
  final double currentLoad;
  final double maxLoad;
  final String bottomLabel;

  final double? markerAValue;
  final IconData? markerAIcon;
  final String? markerALabel;

  final double? markerBValue;
  final IconData? markerBIcon;
  final String? markerBLabel;

  const ControlLoadScale({
    super.key,
    required this.currentLoad,
    this.maxLoad = 30,
    required this.bottomLabel,
    this.markerAValue,
    this.markerAIcon,
    this.markerALabel,
    this.markerBValue,
    this.markerBIcon,
    this.markerBLabel,
  });

  @override
  Widget build(BuildContext context) {
    final current = currentLoad.abs().clamp(0.0, maxLoad);
    final a = markerAValue?.abs().clamp(0.0, maxLoad);
    final b = markerBValue?.abs().clamp(0.0, maxLoad);

    return Padding(
      padding: const EdgeInsets.only(right: 12, top: 20, bottom: 20),
      child: SizedBox(
        width: 97,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final h = constraints.maxHeight;

                  double yFromLoad(double v) => h - (v / maxLoad) * h;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 38,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        top: yFromLoad(current) - 2,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      if (a != null)
                        Positioned(
                          left: 34,
                          width: 16,
                          top: yFromLoad(a) - 1.5,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade700,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      if (b != null)
                        Positioned(
                          left: 34,
                          width: 16,
                          top: yFromLoad(b) - 1.5,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.lightBlue.shade300,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      if (a != null && markerALabel != null && markerAIcon != null)
                        Positioned(
                          right: -5,
                          top: yFromLoad(a) - 18,
                          child: _LoadMark(
                            label: markerALabel!,
                            icon: markerAIcon!,
                          ),
                        ),
                      if (b != null && markerBLabel != null && markerBIcon != null)
                        Positioned(
                          right: -5,
                          top: yFromLoad(b) - 18,
                          child: _LoadMark(
                            label: markerBLabel!,
                            icon: markerBIcon!,
                          ),
                        ),
                      Positioned(
                        left: 0,
                        bottom: -4,
                        child: Text(
                          '0',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: h * (1 - 10 / maxLoad) - 6,
                        child: Text(
                          '10',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: h * (1 - 20 / maxLoad) - 6,
                        child: Text(
                          '20',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: -6,
                        child: Text(
                          maxLoad.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              bottomLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadMark extends StatelessWidget {
  final String label;
  final IconData icon;

  const _LoadMark({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF6E87FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}