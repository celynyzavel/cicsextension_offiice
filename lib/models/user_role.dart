enum UserRole { facultyExtensionist, extensionCoordinator, collegeDean }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.facultyExtensionist:
        return 'Faculty Extensionist';
      case UserRole.extensionCoordinator:
        return 'Extension Coordinator';
      case UserRole.collegeDean:
        return 'College Dean';
    }
  }


  String get storageValue {
    switch (this) {
      case UserRole.facultyExtensionist:
        return 'facultyExtensionist';
      case UserRole.extensionCoordinator:
        return 'extensionCoordinator';
      case UserRole.collegeDean:
        return 'collegeDean';
    }
  }
}

UserRole? userRoleFromString(String? value) {
  for (final role in UserRole.values) {
    if (role.storageValue == value) return role;
  }
  return null;
}
