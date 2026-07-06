enum BloomsLevel {
  c1(1, 'Remember'),
  c2(2, 'Understand'),
  c3(3, 'Apply'),
  c4(4, 'Analyze'),
  c5(5, 'Evaluate'),
  c6(6, 'Create');

  const BloomsLevel(
      this.level,
      this.label,
      );

  final int level;
  final String label;

  @override
  String toString() => 'C$level - $label';
}