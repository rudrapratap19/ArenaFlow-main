import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import '../../../data/models/auth/user_model.dart';
import '../../blocs/auth/auth_bloc.dart';
import 'widgets/admin_card.dart';
import 'widgets/empty_admins_state.dart';
import 'widgets/user_panel_header.dart';

class UserPanel extends StatefulWidget {
  const UserPanel({super.key});

  @override
  State<UserPanel> createState() => _UserPanelState();
}

class _UserPanelState extends State<UserPanel>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _adminsStream;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _adminsStream = FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: 'Admin')
        .snapshots();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'User Panel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushReplacementNamed(AppRouter.login);
          }
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: AppColors.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        String userName = 'User';
                        if (state is AuthAuthenticated) {
                          userName = state.user.name;
                        }
                        return UserPanelHeader(userName: userName);
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: _buildSectionTitle(),
                  ),
                ),
                _buildAdminsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.primaryGradient,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.supervisor_account,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Administrators',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildAdminsList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _adminsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: EmptyAdminsState(),
          );
        }

        final admins = snapshot.data!.docs
            .map((doc) => UserModel.fromMap(doc.id, doc.data()))
            .toList();
        admins.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => AdminCard(admin: admins[index]),
              childCount: admins.length,
            ),
          ),
        );
      },
    );
  }
}
