import 'package:carseva/features/voice_search/presentation/voice_search.dart';
import 'package:carseva/features/car_market/presentation/pages/market_trends_page.dart';
import 'package:carseva/features/car_market/presentation/pages/availability_prediction_page.dart';
import 'package:carseva/core/user_profile/widgets/vehicle_profile_card.dart';
import 'package:carseva/core/user_profile/utils/predictive_maintenance.dart';
import 'package:carseva/features/mechanics/presentation/pages/find_mechanics_page.dart';
import 'package:carseva/core/user_profile/pages/vehicle_profile_settings_page.dart';
import 'package:carseva/features/diagnostics/presentation/pages/diagnostic_dashboard_page.dart';
import 'package:carseva/features/predictive_maintenance/presentation/pages/health_dashboard_page.dart';
import 'package:carseva/features/market_trends/presentation/pages/ai_market_trends_page.dart';
import 'package:carseva/features/vehicle_insights/presentation/pages/vehicle_insights_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CarSevaHome extends StatefulWidget {
  const CarSevaHome({super.key});

  @override
  State<CarSevaHome> createState() => _CarSevaHomeState();
}

class _CarSevaHomeState extends State<CarSevaHome>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _navigateToVoiceAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VoiceSearchPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0E27),
              const Color(0xFF1A1F3A),
              const Color(0xFF0F1535),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  _buildEnhancedAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildWelcomeSection(),
                          // Vehicle Profile Card (shows details or add button)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: VehicleProfileCard(),
                          ),
                          // Maintenance Alerts
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: MaintenanceAlertsWidget(),
                          ),
                          const SizedBox(height: 10),
                          _buildFeaturesGrid(),
                          _buildQuickActions(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildVoiceAssistantFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildVoiceAssistantFAB() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: FloatingActionButton(
        onPressed: _navigateToVoiceAssistant,
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 8,
        child: const Icon(Icons.mic, size: 28),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Transform.rotate(
                angle: _rotateController.value * 2 * math.pi,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6C63FF).withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Transform.rotate(
                angle: -_rotateController.value * 2 * math.pi,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF6584).withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnhancedAppBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1F3A).withOpacity(0.9),
            const Color(0xFF2D3561).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CarSeva',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Your AI Car Assistant',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 22),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              padding: const EdgeInsets.all(8),
            ),
          ),
          _buildAppBarButton(Icons.notifications_active, () {}),
          const SizedBox(width: 8),
          _buildAppBarButton(Icons.settings, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VehicleProfileSettingsPage(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAppBarButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D3561).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1F3A).withOpacity(0.6),
              const Color(0xFF2D3561).withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '👋',
                  style: TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getWelcomeMessage(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'How can we assist you today?',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      {
        'icon': Icons.build_circle,
        'title': 'Problem\nDiagnosis',
        'subtitle': 'AI-powered analysis',
        'color': const Color(0xFF6C63FF),
        'delay': 0,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DiagnosticDashboardPage(),
            ),
          );
        },
      },

      {
        'icon': Icons.trending_up,
        'title': 'Market\nTrends',
        'subtitle': 'Price prediction',
        'color': const Color(0xFF4CAF50),
        'delay': 200,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AIMarketTrendsPage(),
            ),
          );
        },
      },
      {
        'icon': Icons.event_available,
        'title': 'Predictive\nMaintenance',
        'subtitle': 'Stay ahead',
        'color': const Color(0xFF10B981),
        'delay': 100,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HealthDashboardPage(),
            ),
          );
        },
      },
      {
        'icon': Icons.search,
        'title': 'Find\nMechanics',
        'subtitle': 'Nearby services',
        'color': const Color(0xFFFF9800),
        'delay': 200,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FindMechanicsPage(),
            ),
          );
        },
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          return _buildFeatureCard(features[index], features[index]['onTap'] as VoidCallback?);
        },
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature, VoidCallback? onTap) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 700 + feature['delay'] as int),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  feature['color'].withOpacity(0.25),
                  feature['color'].withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: feature['color'].withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: feature['color'].withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                splashColor: feature['color'].withOpacity(0.3),
                onTap: onTap ?? () {},
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              feature['color'],
                              feature['color'].withOpacity(0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: feature['color'].withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          feature['icon'],
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        feature['title'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        feature['subtitle'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1F3A).withOpacity(0.8),
              const Color(0xFF2D3561).withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flash_on,
                    color: Color(0xFF6C63FF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildQuickActionItem(
              Icons.insights,
              'Vehicle Insights',
              'AI-powered tips for your car',
              const Color(0xFF10B981),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VehicleInsightsPage(
                      make: 'Maruti Suzuki',
                      model: 'Swift',
                      year: 2020,
                      mileage: 45000,
                    ),
                  ),
                );
              },
            ),
            _buildQuickActionItem(
              Icons.location_on_outlined,
              'Find Mechanics',
              'Locate nearby service centers',
              const Color(0xFF4CAF50),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FindMechanicsPage(),
                  ),
                );
              },
            ),
            _buildQuickActionItem(
              Icons.chat_bubble_outline,
              'Chat Support',
              'Get instant AI-powered help',
              const Color(0xFFFF6584),
              onTap: _navigateToVoiceAssistant,
            ),
            _buildQuickActionItem(
              Icons.location_searching,
              'Availability Check',
              'Predict car availability in your area',
              const Color(0xFF6C63FF),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AvailabilityPredictionPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
      IconData icon, String title, String subtitle, Color color, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            splashColor: color.withOpacity(0.2),
            onTap: onTap ?? () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: color,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getWelcomeMessage() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Try to get display name first
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        return 'Welcome, ${user.displayName}!';
      }
      // If no display name, extract name from email
      if (user.email != null) {
        String emailName = user.email!.split('@')[0];
        // Capitalize first letter
        emailName = emailName[0].toUpperCase() + emailName.substring(1);
        return 'Welcome, $emailName!';
      }
    }
    return 'Welcome Back!';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFEF4444)),
              SizedBox(width: 12),
              Text('Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
