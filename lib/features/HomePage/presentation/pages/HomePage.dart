import 'package:carseva/features/voice_search/presentation/voice_search.dart';
import 'package:carseva/features/car_market/presentation/pages/availability_prediction_page.dart';
import 'package:carseva/core/user_profile/widgets/vehicle_profile_card.dart';
import 'package:carseva/core/user_profile/utils/predictive_maintenance.dart';
import 'package:carseva/features/mechanics/presentation/pages/find_mechanics_page.dart';
import 'package:carseva/core/user_profile/pages/vehicle_profile_settings_page.dart';
import 'package:carseva/features/diagnostics/presentation/pages/diagnostic_dashboard_page.dart';
import 'package:carseva/features/predictive_maintenance/presentation/pages/health_dashboard_page.dart';
import 'package:carseva/features/market_trends/presentation/pages/ai_market_trends_page.dart';
import 'package:carseva/features/vehicle_insights/presentation/pages/vehicle_insights_page.dart';
import 'package:carseva/core/auth/local_user.dart';
import 'package:carseva/features/auth/data/repositories/auth_implement.dart';
import 'package:carseva/core/user_profile/bloc/user_profile_bloc.dart';
import 'package:carseva/core/user_profile/bloc/user_profile_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CarSevaHome extends StatefulWidget {
  const CarSevaHome({super.key});

  @override
  State<CarSevaHome> createState() => _CarSevaHomeState();
}

class _CarSevaHomeState extends State<CarSevaHome> {
  static const _bg = Color(0xFF0F1117);
  static const _card = Color(0xFF1A1D27);
  static const _cardBorder = Color(0xFF262A36);
  static const _accent = Color(0xFF6C63FF);
  static const _textPrimary = Color(0xFFF1F1F4);
  static const _textSecondary = Color(0xFF8B8FA3);

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final user = await AuthRepositoryImpl.getCurrentUser();
    if (user != null && mounted) {
      context.read<UserProfileBloc>().add(InitializeUserProfileEvent(user.uid));
    }
  }

  void _navigateToVoiceAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VoiceSearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              _buildWelcome(),
              const SizedBox(height: 8),

              // Vehicle Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: VehicleProfileCard(),
              ),

              // Maintenance Alerts
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: MaintenanceAlertsWidget(),
              ),

              const SizedBox(height: 8),
              _buildSectionTitle('Features'),
              _buildFeaturesGrid(),

              _buildSectionTitle('Quick Actions'),
              _buildQuickActions(),

              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToVoiceAssistant,
        backgroundColor: _accent,
        elevation: 4,
        child: const Icon(Icons.mic, size: 26, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ─── App Bar ───────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_car, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CarSeva',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Your AI Car Assistant',
                style: TextStyle(color: _textSecondary, fontSize: 11),
              ),
            ],
          ),
          const Spacer(),
          _iconBtn(Icons.settings, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VehicleProfileSettingsPage()),
            );
          }),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: _textSecondary, size: 20),
        ),
      ),
    );
  }

  // ─── Welcome ──────────────────────────────────────────────────────
  Widget _buildWelcome() {
    return FutureBuilder<LocalUser?>(
      future: AuthRepositoryImpl.getCurrentUser(),
      builder: (context, snap) {
        final name = snap.data?.displayName?.split(' ')[0] ?? 'there';
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name 👋',
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your car is in good hands.',
                style: TextStyle(color: _textSecondary, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Section Title ────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          color: _textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ─── Features Grid ────────────────────────────────────────────────
  Widget _buildFeaturesGrid() {
    final features = [
      _Feature(Icons.build_circle, 'Diagnosis', 'AI analysis', const Color(0xFF6C63FF), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DiagnosticDashboardPage()));
      }),
      _Feature(Icons.trending_up, 'Market Trends', 'Price insights', const Color(0xFF4CAF50), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AIMarketTrendsPage()));
      }),
      _Feature(Icons.health_and_safety, 'Health Check', 'Maintenance', const Color(0xFF10B981), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthDashboardPage()));
      }),
      _Feature(Icons.location_on, 'Mechanics', 'Nearby services', const Color(0xFFFF9800), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FindMechanicsPage()));
      }),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.25,
        ),
        itemCount: features.length,
        itemBuilder: (context, i) => _buildFeatureCard(features[i]),
      ),
    );
  }

  Widget _buildFeatureCard(_Feature f) {
    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: f.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: f.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(f.icon, color: f.color, size: 24),
              ),
              const SizedBox(height: 14),
              Text(
                f.title,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                f.subtitle,
                style: const TextStyle(color: _textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Quick Actions ────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _quickActionTile(
            Icons.insights,
            'Vehicle Insights',
            'AI-powered advice',
            const Color(0xFF10B981),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<UserProfileBloc>(),
                    child: const VehicleInsightsPage(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _quickActionTile(
            Icons.chat_bubble_outline,
            'AI Chat Support',
            'Instant assistance',
            const Color(0xFFFF6584),
            _navigateToVoiceAssistant,
          ),
          const SizedBox(height: 8),
          _quickActionTile(
            Icons.location_searching,
            'Availability',
            'Market prediction',
            _accent,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AvailabilityPredictionPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _quickActionTile(
      IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: _textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Logout ───────────────────────────────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFEF4444)),
              SizedBox(width: 12),
              Text('Logout', style: TextStyle(color: _textPrimary)),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: _textSecondary, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: _textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await AuthRepositoryImpl.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _Feature(this.icon, this.title, this.subtitle, this.color, this.onTap);
}
