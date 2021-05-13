class NameInitials {
  String getInitials(String name) {
    final splittedName = name.split(' ');
    String initials = '';
    splittedName.forEach((word) => initials += word[0]);
    return initials.toUpperCase();
  }
}
