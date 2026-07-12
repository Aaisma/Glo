<<<<<<< HEAD
import 'package:flutter/material.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Daily Journal Page")),
    );
  }
}

=======
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../../model/user_model.dart';
import '../admin_navigation/admin_top_panel.dart';
import '../admin_navigation/admin_sidebar.dart';
import '../../app_colors.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Modern gradient avatar generator based on initials
  List<Color> _getInitialGradients(String name) {
    if (name.isEmpty) {
      return [const Color(0xFF6366F1), const Color(0xFF4F46E5)]; // Indigo
    }
    final int code = name.codeUnitAt(0);
    if (code % 3 == 0) {
      return [const Color(0xFFEC4899), const Color(0xFFD946EF)]; // Pink/Fuchsia
    } else if (code % 3 == 1) {
      return [const Color(0xFF3B82F6), const Color(0xFF2563EB)]; // Blue
    } else {
      return [const Color(0xFF10B981), const Color(0xFF059669)]; // Emerald
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.trim().split(" ");
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().getAllUser();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmRemoveUser(BuildContext context, UserViewModel userVM, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              "Remove User",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to remove '${user.name}'? This will permanently delete their account and data from the system.",
          style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Cancel",
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await userVM.deleteUser(user.id);
              await userVM.getAllUser();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("User '${user.name}' removed successfully"),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            child: Text(
              "Remove",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleUserRole(BuildContext context, UserViewModel userVM, UserModel user) {
    final isCurrentlyAdmin = user.role == 'admin';
    final newRole = isCurrentlyAdmin ? 'user' : 'admin';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCurrentlyAdmin ? const Color(0xFFFFF3CD) : const Color(0xFFE0F2FE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCurrentlyAdmin ? Icons.arrow_downward : Icons.shield_outlined,
                color: isCurrentlyAdmin ? Colors.orange : const Color(0xFF0284C7),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isCurrentlyAdmin ? "Demote to User" : "Promote to Admin",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to change '${user.name}''s role to ${isCurrentlyAdmin ? 'Regular User' : 'Administrator'}?",
          style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Cancel",
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentlyAdmin ? Colors.orange : const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final updatedUser = user.copyWith(role: newRole);
              await userVM.editProfile(updatedUser);
              await userVM.getAllUser();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("User '${user.name}' updated to $newRole successfully"),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            child: Text(
              isCurrentlyAdmin ? "Demote" : "Promote",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userVM = context.watch<UserViewModel>();
    final allUsers = userVM.allUsers ?? [];

    // Filter users by search query
    final filteredUsers = allUsers.where((u) {
      final name = u.name.toLowerCase();
      final query = _searchQuery.trim().toLowerCase();
      return name.contains(query);
    }).toList();

    // Stats
    final totalCount = allUsers.length;
    final adminCount = allUsers.where((u) => u.role == 'admin').length;
    final activeCount = totalCount - adminCount;

    return Container(
      color: const Color(0xFFF0FFFF),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AdminTopPanel(),
        drawer: const AdminSidebar(),
        body: SafeArea(
          child: Column(
            children: [
              // Welcome & Stats Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Members Directory",
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Glassmorphic Statistics Board
                    Row(
                      children: [
                        _buildStatCard("Total Directory", totalCount.toString(), const Color(0xFF6366F1)),
                        const SizedBox(width: 12),
                        _buildStatCard("Administrators", adminCount.toString(), const Color(0xFFEC4899)),
                        const SizedBox(width: 12),
                        _buildStatCard("Active Users", activeCount.toString(), const Color(0xFF10B981)),
                      ],
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: GoogleFonts.outfit(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: "Search members by name...",
                      hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 15),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: Color(0xFF94A3B8)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = "";
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              // Users List Section
              Expanded(
                child: userVM.loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.pink))
                    : filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.supervised_user_circle_outlined, size: 70, color: const Color(0xFF94A3B8).withOpacity(0.5)),
                                const SizedBox(height: 12),
                                Text(
                                  "No matching members found",
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    color: const Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: filteredUsers.length,
                            padding: const EdgeInsets.only(bottom: 24),
                            itemBuilder: (ctx, index) {
                              final user = filteredUsers[index];
                              final initials = _getInitials(user.name);
                              final gradientColors = _getInitialGradients(user.name);
                              final isAdmin = user.role == 'admin';

                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isAdmin
                                        ? const Color(0xFFE0E7FF)
                                        : const Color(0xFFF1F5F9),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0F172A).withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Custom Initials Gradient Avatar
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: gradientColors,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: gradientColors[0].withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          initials,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Details & Buttons
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  user.name.isNotEmpty ? user.name : 'No Name Set',
                                                  style: GoogleFonts.outfit(
                                                    color: const Color(0xFF1E293B),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              
                                              // Premium Pill Badges
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isAdmin ? const Color(0xFFEEF2FF) : const Color(0xFFECFDF5),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      isAdmin ? Icons.shield : Icons.person_rounded,
                                                      size: 11,
                                                      color: isAdmin ? const Color(0xFF4F46E5) : const Color(0xFF059669),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      isAdmin ? "Admin" : "User",
                                                      style: GoogleFonts.outfit(
                                                        color: isAdmin ? const Color(0xFF4F46E5) : const Color(0xFF059669),
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            user.email ?? "no email registered",
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFF64748B),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 14),
                                          
                                          // Action Buttons
                                          Row(
                                            children: [
                                              // Remove User Button
                                              InkWell(
                                                onTap: () => _confirmRemoveUser(context, userVM, user),
                                                borderRadius: BorderRadius.circular(10),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFEF2F2),
                                                    border: Border.all(color: const Color(0xFFFEE2E2)),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 15),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        "Remove",
                                                        style: GoogleFonts.outfit(
                                                          color: const Color(0xFFEF4444),
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              
                                              // Convert Button (Admin <-> User)
                                              InkWell(
                                                onTap: () => _toggleUserRole(context, userVM, user),
                                                borderRadius: BorderRadius.circular(10),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: isAdmin ? const Color(0xFFFFF3CD) : const Color(0xFFE0F2FE),
                                                    border: Border.all(
                                                      color: isAdmin ? const Color(0xFFFFE0B2) : const Color(0xFFBAE6FD),
                                                    ),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        isAdmin ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                                        color: isAdmin ? Colors.orange[800] : const Color(0xFF0369A1),
                                                        size: 15,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        isAdmin ? "Convert to user" : "Convert to admin",
                                                        style: GoogleFonts.outfit(
                                                          color: isAdmin ? Colors.orange[800] : const Color(0xFF0369A1),
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                color: const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 18,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  count,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
>>>>>>> origin/development_branch
