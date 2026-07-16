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
}

class DemoAccount {
  final UserRole role;
  final String email;
  final String password;

  const DemoAccount({
    required this.role,
    required this.email,
    required this.password,
  });
}

const List<DemoAccount> demoAccounts = [
  DemoAccount(
    role: UserRole.facultyExtensionist,
    email: 'faculty.demo@cics.edu',
    password: 'faculty123',
  ),
  DemoAccount(
    role: UserRole.extensionCoordinator,
    email: 'coordinator.demo@cics.edu',
    password: 'coordinator123',
  ),
  DemoAccount(
    role: UserRole.collegeDean,
    email: 'dean.demo@cics.edu',
    password: 'dean123',
  ),
];

DemoAccount? findDemoAccount(UserRole role) {
  for (final account in demoAccounts) {
    if (account.role == role) return account;
  }
  return null;
}
