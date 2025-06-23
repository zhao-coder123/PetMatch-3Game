import 'pet_type.dart';

class PetTile {
  final int row;
  final int col;
  final PetType petType;
  bool isSelected;
  bool isMatched;
  bool isHighlighted;
  bool isFalling;

  PetTile({
    required this.row,
    required this.col,
    required this.petType,
    this.isSelected = false,
    this.isMatched = false,
    this.isHighlighted = false,
    this.isFalling = false,
  }) : assert(row >= 0, 'Row must be non-negative'),
       assert(col >= 0, 'Col must be non-negative');

  PetTile copyWith({
    int? row,
    int? col,
    PetType? petType,
    bool? isSelected,
    bool? isMatched,
    bool? isHighlighted,
    bool? isFalling,
  }) {
    return PetTile(
      row: row ?? this.row,
      col: col ?? this.col,
      petType: petType ?? this.petType,
      isSelected: isSelected ?? this.isSelected,
      isMatched: isMatched ?? this.isMatched,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isFalling: isFalling ?? this.isFalling,
    );
  }

  // 重置所有状态
  PetTile resetStates() {
    return copyWith(
      isSelected: false,
      isMatched: false,
      isHighlighted: false,
      isFalling: false,
    );
  }

  // 检查是否处于动画状态
  bool get isAnimated => isSelected || isMatched || isFalling;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetTile &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col &&
          petType == other.petType;

  @override
  int get hashCode => row.hashCode ^ col.hashCode ^ petType.hashCode;

  @override
  String toString() {
    return 'PetTile(row: $row, col: $col, petType: $petType, states: [selected: $isSelected, matched: $isMatched, highlighted: $isHighlighted, falling: $isFalling])';
  }
} 