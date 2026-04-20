import 'package:flutter/material.dart';
import 'package:germana/models/ride_model.dart';

Color _driverAvatarBackground(RideModel ride) {
  final seed = ride.driverDisplayName.toLowerCase().trim();
  final index = seed.isEmpty ? 0 : seed.hashCode.abs();

  if (ride.driverSex == DriverSex.female) {
    const femalePalette = <Color>[
      Color(0xFFF6D9E7),
      Color(0xFFEEDCFA),
      Color(0xFFFFDDE2),
      Color(0xFFEAD6F8),
      Color(0xFFF9DCEB),
    ];
    return femalePalette[index % femalePalette.length];
  }

  const malePalette = <Color>[
    Color(0xFFD7E9FF),
    Color(0xFFDDEEFF),
    Color(0xFFCFE5FF),
    Color(0xFFE1EEFF),
    Color(0xFFD8EFFF),
  ];
  return malePalette[index % malePalette.length];
}

Color _driverAvatarTextColor(RideModel ride) {
  if (ride.driverSex == DriverSex.female) {
    return const Color(0xFF6B3566);
  }
  return const Color(0xFF2C4F7A);
}

class DriverInitialsAvatar extends StatelessWidget {
  final RideModel ride;
  final double size;
  final double fontSize;
  final FontWeight fontWeight;

  const DriverInitialsAvatar({
    super.key,
    required this.ride,
    this.size = 30,
    this.fontSize = 11,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _driverAvatarBackground(ride),
      ),
      alignment: Alignment.center,
      child: Text(
        ride.driverInitials,
        style: TextStyle(
          color: _driverAvatarTextColor(ride),
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: 0.2,
          height: 1,
        ),
      ),
    );
  }
}