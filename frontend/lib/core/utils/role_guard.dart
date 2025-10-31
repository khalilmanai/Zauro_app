typedef UserRole = String;

class RoleGuard {
  static const UserRole admin = 'ADMIN';
  static const UserRole employee = 'EMPLOYEE_TRADER';

  /// Returns true if `userRole` is allowed to access a resource requiring `requiredRole`.
  /// Current policy: ADMIN can access everything; EMPLOYEE_TRADER can access employee areas only.
  static bool canAccess(UserRole? userRole, UserRole requiredRole) {
    if (userRole == null) return false;
    if (userRole == admin) return true;
    return userRole == requiredRole;
  }

  /// Convenience: check against a set of allowed roles.
  static bool canAccessAny(UserRole? userRole, List<UserRole> allowed) {
    if (userRole == null) return false;
    if (userRole == admin) return true;
    return allowed.contains(userRole);
  }
}


