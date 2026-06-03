enum ProfileGender {
  male('male', 'Male'),
  female('female', 'Female'),
  other('other', 'Other');

  const ProfileGender(this.wire, this.label);

  final String wire;
  final String label;

  static ProfileGender? fromWire(String? wire) {
    final v = (wire ?? '').trim().toLowerCase();
    for (final g in ProfileGender.values) {
      if (g.wire == v) return g;
    }
    return null;
  }
}
