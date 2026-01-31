enum BodyPart { shoulder, neck, back }

extension BodyPartX on BodyPart {
  String get displayName {
    switch (this) {
      case BodyPart.shoulder:
        return '어깨';
      case BodyPart.neck:
        return '목';
      case BodyPart.back:
        return '허리';
    }
  }
}
