import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/events_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/earnings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'firebase_options.dart';
import 'services/vendor_service.dart';
import 'models/vendor_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FliqaIndiaPartnerApp());
}

class FliqaIndiaPartnerApp extends StatelessWidget {
  const FliqaIndiaPartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FliqaIndia Partner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColors.black,
              body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const MainScaffold();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(onNavTap: _onNavTap);
      case 1:
        return const ProjectsScreen();
      case 2:
        return const EventsScreen();
      case 3:
        return const EarningsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return HomeScreen(onNavTap: _onNavTap);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Home', 'Projects', 'Events', 'Earnings', 'Profile'];
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black2,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 20,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, color: AppColors.gold, size: 24),
            ),
            const SizedBox(width: 6),
            ShaderMask(
              shaderCallback: (b) => AppColors.goldGradient.createShader(b),
              child: Text(
                'FliqaIndia',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'PARTNERS',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: AppColors.whiteDim,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StreamBuilder<VendorModel?>(
              stream: VendorService().currentVendorStream(),
              builder: (context, snap) {
                final tier = snap.data?.tier ?? 'Silver';
                final tierEmoji = tier == 'Platinum' ? '💎' : (tier == 'Gold' ? '⭐' : '🥈');
                final tierColor = tier == 'Platinum'
                    ? const Color(0xFFB0C4DE)
                    : (tier == 'Gold' ? AppColors.gold : const Color(0xFFAAAAAA));
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: tierColor.withOpacity(0.5)),
                    color: tierColor.withOpacity(0.08),
                  ),
                  child: Text(
                    '$tierEmoji $tier',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: tierColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.goldBorder),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.black2,
          border: Border(top: BorderSide(color: AppColors.goldBorder)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.whiteDim,
          selectedLabelStyle: GoogleFonts.dmSans(
              fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          unselectedLabelStyle:
              GoogleFonts.dmSans(fontSize: 10, letterSpacing: 0.5),
          items: const [
            BottomNavigationBarItem(icon: Text('🏠', style: TextStyle(fontSize: 20)), label: 'Home'),
            BottomNavigationBarItem(icon: Text('📂', style: TextStyle(fontSize: 20)), label: 'Projects'),
            BottomNavigationBarItem(icon: Text('📢', style: TextStyle(fontSize: 20)), label: 'Events'),
            BottomNavigationBarItem(icon: Text('💰', style: TextStyle(fontSize: 20)), label: 'Earnings'),
            BottomNavigationBarItem(icon: Text('👤', style: TextStyle(fontSize: 20)), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
