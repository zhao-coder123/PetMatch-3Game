import 'package:flutter/material.dart';

enum PetType {
  cat,
  dog,
  rabbit,
  panda,
  fox,
  unicorn,
}

extension PetTypeExtension on PetType {
  String get name {
    switch (this) {
      case PetType.cat:
        return '小猫咪';
      case PetType.dog:
        return '小狗狗';
      case PetType.rabbit:
        return '小兔子';
      case PetType.panda:
        return '小熊猫';
      case PetType.fox:
        return '小狐狸';
      case PetType.unicorn:
        return '小独角兽';
    }
  }

  Color get color {
    switch (this) {
      case PetType.cat:
        return const Color(0xFFFF6B9D); // 粉色
      case PetType.dog:
        return const Color(0xFF4ECDC4); // 薄荷绿
      case PetType.rabbit:
        return const Color(0xFFFFE66D); // 柠檬黄
      case PetType.panda:
        return const Color(0xFF95E1D3); // 浅薄荷绿
      case PetType.fox:
        return const Color(0xFFFFB347); // 橘色
      case PetType.unicorn:
        return const Color(0xFFC7CEEA); // 薰衣草紫
    }
  }

  String get emoji {
    switch (this) {
      case PetType.cat:
        return '🐱';
      case PetType.dog:
        return '🐶';
      case PetType.rabbit:
        return '🐰';
      case PetType.panda:
        return '🐼';
      case PetType.fox:
        return '🦊';
      case PetType.unicorn:
        return '🦄';
    }
  }

  Color get shadowColor {
    return color.withOpacity(0.3);
  }
} 