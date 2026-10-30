import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config/app_config.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SerenityApp());
}

class HotelColors {
  static const navy = Color(0xFF101827);
  static const navyLight = Color(0xFF172338);
  static const navySoft = Color(0xFF202D42);

  static const cream = Color(0xFF101827);
  static const creamDeep = Color(0xFF202D42);
  static const white = Color(0xFF1C2738);
  static const surface = Color(0xFF1C2738);

  static const charcoal = Color(0xFFF4F0E8);
  static const muted = Color(0xFFADB7C6);
  static const border = Color(0xFF354257);

  static const bronze = Color(0xFFD5B46A);
  static const gold = Color(0xFFE0C47E);
  static const goldLight = Color(0xFFF0DCA9);
  static const green = Color(0xFF42A77A);
}

class SerenityApp extends StatelessWidget {
  const SerenityApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: HotelColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: HotelColors.navy,
        primary: HotelColors.navy,
        secondary: HotelColors.bronze,
        surface: HotelColors.white,
      ),
    );

    return MaterialApp(
      title: AppConfig.hotelName,
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: GoogleFonts.interTextTheme(base.textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: HotelColors.white,
          foregroundColor: HotelColors.charcoal,
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: HotelColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: HotelColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: HotelColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: HotelColors.bronze, width: 1.5),
          ),
        ),
      ),
      home: const IPBHomePage(),
    );
  }
}

class IPBHomePage extends StatefulWidget {
  const IPBHomePage({super.key});

  @override
  State<IPBHomePage> createState() => _IPBHomePageState();
}

class _IPBHomePageState extends State<IPBHomePage> {
  int _selectedIndex = 0;
  bool _english = false;

  void _navigate(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openInquiry({String type = 'general', String? title}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InquiryScreen(
          inquiryType: type,
          title: title ?? (_english ? 'Contact hotel' : 'Hubungi hotel'),
          english: _english,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        english: _english,
        onBooking: () => _navigate(1),
        onServices: () => _navigate(2),
        onInquiry: _openInquiry,
      ),
      BookingScreen(english: _english),
      ServicesScreen(english: _english, onInquiry: _openInquiry),
      ConciergeScreen(english: _english, onInquiry: _openInquiry),
      ProfileScreen(
        english: _english,
        onLanguageChanged: (value) => setState(() => _english = value),
      ),
    ];

    final labels = _english
        ? ['Home', 'Booking', 'Services', 'Concierge', 'Profile']
        : ['Beranda', 'Booking', 'Layanan', 'Concierge', 'Profil'];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: LuxuryBottomNavigation(
        selectedIndex: _selectedIndex,
        labels: labels,
        onSelected: _navigate,
      ),
    );
  }
}

class LuxuryBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onSelected;

  const LuxuryBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.labels,
    required this.onSelected,
  });

  static const _icons = [
    Icons.home_outlined,
    Icons.calendar_month_outlined,
    Icons.room_service_outlined,
    Icons.chat_bubble_outline,
    Icons.person_outline,
  ];

  static const _activeIcons = [
    Icons.home_rounded,
    Icons.calendar_month_rounded,
    Icons.room_service_rounded,
    Icons.chat_bubble_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HotelColors.white,
        border: const Border(
          top: BorderSide(color: HotelColors.border, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: List.generate(5, (index) {
              final active = selectedIndex == index;
              return Expanded(
                child: InkWell(
                  onTap: () => onSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.only(top: 8, bottom: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: active ? 1.08 : 1,
                          duration: const Duration(milliseconds: 220),
                          child: Icon(
                            active ? _activeIcons[index] : _icons[index],
                            color: active
                                ? HotelColors.bronze
                                : HotelColors.muted,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: active ? 5 : 0,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: HotelColors.bronze,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          labels[index],
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: active
                                ? HotelColors.charcoal
                                : HotelColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final bool english;
  final VoidCallback onBooking;
  final VoidCallback onServices;
  final void Function({String type, String? title}) onInquiry;

  const HomeScreen({
    super.key,
    required this.english,
    required this.onBooking,
    required this.onServices,
    required this.onInquiry,
  });

  String t(String id, String en) => english ? en : id;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            automaticallyImplyLeading: false,
            backgroundColor: HotelColors.white,
            surfaceTintColor: HotelColors.white,
            elevation: 1,
            scrolledUnderElevation: 3,
            shadowColor: Colors.black.withValues(alpha: 0.09),
            toolbarHeight: 94,
            expandedHeight: 104,
            centerTitle: true,
            title: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 58,
              width: 280,
              alignment: Alignment.center,
              child: Image.asset(
                AppConfig.hotelLogo,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.apartment_rounded,
                  color: HotelColors.navy,
                  size: 42,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  tooltip: t('Hubungi hotel', 'Contact hotel'),
                  onPressed: () => onInquiry(
                    type: 'general',
                    title: t('Hubungi hotel', 'Contact hotel'),
                  ),
                  icon: const Icon(
                    Icons.support_agent_rounded,
                    color: HotelColors.gold,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: HotelColors.cream,
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: CinematicHero(english: english, onBooking: onBooking),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 14),
              child: SectionTitle(
                eyebrow: t('PENGALAMAN HOTEL', 'THE HOTEL EXPERIENCE'),
                title: t('Jelajahi Hotel Kami', 'Discover Our Hotel'),
                subtitle: t(
                  'Temukan ruang, fasilitas, dan pengalaman untuk momen istimewa Anda.',
                  'Discover spaces, facilities and experiences for your special moments.',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 226,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20, right: 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  HorizontalExperienceCard(
                    image: AppConfig.lobbyImage,
                    title: t('Hotel & Lobby', 'Hotel & Lobby'),
                    subtitle: t(
                      'Kenyamanan menyambut Anda',
                      'A warm welcome awaits',
                    ),
                    icon: Icons.hotel_outlined,
                    onTap: () => onInquiry(
                      type: 'hotel_information',
                      title: t('Informasi hotel', 'Hotel information'),
                    ),
                  ),
                  HorizontalExperienceCard(
                    image: AppConfig.weddingImage,
                    title: t('Wedding & Event', 'Wedding & Events'),
                    subtitle: t('Momen spesial Anda', 'Your special moments'),
                    icon: Icons.celebration_outlined,
                    onTap: () => onInquiry(
                      type: 'event_inquiry',
                      title: t('Inquiry event', 'Event inquiry'),
                    ),
                  ),
                  HorizontalExperienceCard(
                    image: AppConfig.conferenceImage,
                    title: t('Convention', 'Convention'),
                    subtitle: t('Kebutuhan acara bisnis', 'Business occasions'),
                    icon: Icons.meeting_room_outlined,
                    onTap: () => onInquiry(
                      type: 'event_inquiry',
                      title: t('Inquiry convention', 'Convention inquiry'),
                    ),
                  ),
                  HorizontalExperienceCard(
                    image: AppConfig.heroImage,
                    title: t('Layanan Hotel', 'Hotel Services'),
                    subtitle: t(
                      'Jelajahi layanan kami',
                      'Explore our services',
                    ),
                    icon: Icons.room_service_outlined,
                    onTap: onServices,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  const Icon(
                    Icons.swipe_rounded,
                    size: 16,
                    color: HotelColors.bronze,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    t('Geser untuk menjelajahi', 'Swipe to explore'),
                    style: const TextStyle(
                      fontSize: 10,
                      color: HotelColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 14),
              child: SectionTitle(
                eyebrow: t('FASILITAS HOTEL', 'HOTEL FACILITIES'),
                title: t('Jelajahi Fasilitas', 'Explore Our Facilities'),
                subtitle: t(
                  'Temukan fasilitas untuk menunjang kenyamanan kunjungan Anda.',
                  'Discover facilities designed for a comfortable stay.',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.05,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  FacilityShortcut(
                    icon: Icons.restaurant_rounded,
                    title: t('Dining', 'Dining'),
                    onTap: () => onInquiry(
                      type: 'hotel_information',
                      title: t('Informasi dining', 'Dining information'),
                    ),
                  ),
                  FacilityShortcut(
                    icon: Icons.meeting_room_rounded,
                    title: t('Meeting', 'Meeting'),
                    onTap: () => onInquiry(
                      type: 'event_inquiry',
                      title: t('Informasi meeting', 'Meeting information'),
                    ),
                  ),
                  FacilityShortcut(
                    icon: Icons.celebration_rounded,
                    title: t('Wedding', 'Wedding'),
                    onTap: () => onInquiry(
                      type: 'event_inquiry',
                      title: t('Informasi wedding', 'Wedding information'),
                    ),
                  ),
                  FacilityShortcut(
                    icon: Icons.room_service_rounded,
                    title: t('Layanan', 'Services'),
                    onTap: onServices,
                  ),
                  FacilityShortcut(
                    icon: Icons.local_parking_rounded,
                    title: t('Parkir', 'Parking'),
                    onTap: () => onInquiry(
                      type: 'hotel_information',
                      title: t('Informasi parkir', 'Parking information'),
                    ),
                  ),
                  FacilityShortcut(
                    icon: Icons.wifi_rounded,
                    title: 'Wi-Fi',
                    onTap: () => onInquiry(
                      type: 'hotel_information',
                      title: t('Informasi Wi-Fi', 'Wi-Fi information'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 14),
              child: SectionTitle(
                eyebrow: t('MOMEN ISTIMEWA', 'SPECIAL MOMENTS'),
                title: t(
                  'Ruang untuk Setiap Cerita',
                  'A Space for Every Story',
                ),
                subtitle: t(
                  'Temukan inspirasi untuk pertemuan, perayaan, dan acara Anda.',
                  'Find inspiration for your meetings, celebrations and events.',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/showcase.jpg',
                      height: 175,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 175,
                        color: HotelColors.creamDeep,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_outlined,
                          color: HotelColors.gold,
                          size: 42,
                        ),
                      ),
                    ),
                    Container(
                      height: 175,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            HotelColors.navy.withValues(alpha: 0.92),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 17,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('IPB CONVENTION HOTEL', 'IPB CONVENTION HOTEL'),
                            style: const TextStyle(
                              color: HotelColors.gold,
                              fontSize: 10,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            t(
                              'Ciptakan momen berkesan bersama kami',
                              'Create memorable moments with us',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
              child: AssistanceCard(
                english: english,
                onTap: () => onInquiry(
                  type: 'general',
                  title: t('Hubungi hotel', 'Contact hotel'),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: PoweredByFooter()),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
        ],
      ),
    );
  }
}

class FacilityShortcut extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const FacilityShortcut({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HotelColors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: HotelColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: HotelColors.gold, size: 29),
              const SizedBox(height: 9),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: HotelColors.charcoal,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CinematicHero extends StatelessWidget {
  final bool english;
  final VoidCallback onBooking;

  const CinematicHero({
    super.key,
    required this.english,
    required this.onBooking,
  });

  @override
  Widget build(BuildContext context) {
    final title = english
        ? 'A Stay to Remember'
        : 'Pengalaman Menginap yang Berkesan';

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: SizedBox(
        height: 410,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AppConfig.heroImage,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, syncLoaded) {
                if (syncLoaded || frame != null) return child;
                return const ShimmerPlaceholder();
              },
              errorBuilder: (_, _, _) => Container(
                color: HotelColors.navy,
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.05, 0.38, 1],
                  colors: [
                    Color(0x16000000),
                    Color(0x42000000),
                    Color(0xE8000000),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: HotelColors.bronze.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      english ? 'WELCOME TO IPB' : 'SELAMAT DATANG',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    title,
                    style: GoogleFonts.cormorantGaramond(
                      color: Colors.white,
                      fontSize: 39,
                      height: 0.98,
                      fontWeight: FontWeight.w700,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 16,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 11),
                  Text(
                    english
                        ? 'Comfort, hospitality and memorable experiences in one destination.'
                        : 'Kenyamanan, keramahan, dan pengalaman dalam satu destinasi.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.55,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(height: 19),
                  PressableGoldButton(
                    label: english ? 'EXPLORE BOOKING' : 'JELAJAHI BOOKING',
                    onPressed: onBooking,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PressableGoldButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const PressableGoldButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  State<PressableGoldButton> createState() => _PressableGoldButtonState();
}

class _PressableGoldButtonState extends State<PressableGoldButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 110),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 14),
          decoration: BoxDecoration(
            color: HotelColors.bronze,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HorizontalExperienceCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const HorizontalExperienceCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 252,
      margin: const EdgeInsets.only(right: 13),
      child: Material(
        color: HotelColors.white,
        borderRadius: BorderRadius.circular(19),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: HotelColors.border),
              borderRadius: BorderRadius.circular(19),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        image,
                        fit: BoxFit.cover,
                        frameBuilder: (context, child, frame, syncLoaded) {
                          if (syncLoaded || frame != null) return child;
                          return const ShimmerPlaceholder();
                        },
                        errorBuilder: (_, _, _) => Container(
                          color: HotelColors.creamDeep,
                          child: const Icon(
                            Icons.image_outlined,
                            color: HotelColors.muted,
                            size: 35,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: HotelColors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            size: 19,
                            color: HotelColors.bronze,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: HotelColors.charcoal,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: HotelColors.muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShimmerPlaceholder extends StatefulWidget {
  const ShimmerPlaceholder({super.key});

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.5 + _controller.value * 3, 0),
              end: Alignment(-0.5 + _controller.value * 3, 0),
              colors: const [
                Color(0xFFEAE5DC),
                Color(0xFFF8F5EF),
                Color(0xFFEAE5DC),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BookingScreen extends StatelessWidget {
  final bool english;

  const BookingScreen({super.key, required this.english});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
        children: [
          SectionTitle(
            eyebrow: english ? 'YOUR STAY' : 'PENGINAPAN ANDA',
            title: english ? 'Plan Your Stay' : 'Rencanakan Penginapan',
            subtitle: english
                ? 'Share your preferred dates and guest details with our team.'
                : 'Sampaikan tanggal dan detail tamu pilihan Anda kepada tim hotel.',
          ),
          const SizedBox(height: 22),
          RoomInquiryForm(english: english),
          const SizedBox(height: 18),
          InfoPanel(
            icon: Icons.info_outline_rounded,
            text: english
                ? 'This form sends an inquiry to the hotel. It does not confirm room availability or create a reservation.'
                : 'Formulir ini mengirim permintaan informasi kepada hotel. Formulir ini tidak mengonfirmasi ketersediaan kamar atau membuat reservasi.',
          ),
          const SizedBox(height: 20),
          const PoweredByFooter(),
        ],
      ),
    );
  }
}

class RoomInquiryForm extends StatefulWidget {
  final bool english;

  const RoomInquiryForm({super.key, required this.english});

  @override
  State<RoomInquiryForm> createState() => _RoomInquiryFormState();
}

class _RoomInquiryFormState extends State<RoomInquiryForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();

  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 2;
  int _rooms = 1;
  bool _loading = false;

  bool get en => widget.english;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  String _date(DateTime? value) {
    if (value == null) return en ? 'Select date' : 'Pilih tanggal';
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  Future<void> _pickDate(bool checkIn) async {
    final now = DateTime.now();
    final initial = checkIn
        ? (_checkIn ?? now)
        : (_checkOut ?? (_checkIn ?? now).add(const Duration(days: 1)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: HotelColors.navy,
            secondary: HotelColors.bronze,
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;

    setState(() {
      if (checkIn) {
        _checkIn = picked;
        if (_checkOut != null && !_checkOut!.isAfter(picked)) {
          _checkOut = null;
        }
      } else if (_checkIn == null || picked.isAfter(_checkIn!)) {
        _checkOut = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_checkIn == null || _checkOut == null) {
      _message(
        en
            ? 'Please select check-in and check-out dates.'
            : 'Pilih tanggal check-in dan check-out terlebih dahulu.',
      );
      return;
    }

    if (!_checkOut!.isAfter(_checkIn!)) {
      _message(
        en
            ? 'Check-out must be after check-in.'
            : 'Tanggal check-out harus setelah check-in.',
      );
      return;
    }

    final notes = [
      'Customer mobile room inquiry',
      'Check-in: ${_date(_checkIn)}',
      'Check-out: ${_date(_checkOut)}',
      'Guests: $_guests',
      'Rooms: $_rooms',
    ].join('\n');

    setState(() => _loading = true);

    try {
      final result = await ApiService.submitInquiry(
        guestName: _name.text,
        email: _email.text,
        inquiryType: 'room_booking',
        notes: notes,
      );

      if (!mounted) return;

      if (result['status'] == 'success') {
        _formKey.currentState!.reset();
        _name.clear();
        _email.clear();
        setState(() {
          _checkIn = null;
          _checkOut = null;
          _guests = 2;
          _rooms = 1;
        });
        _message(
          en
              ? 'Your inquiry was sent. The hotel team must confirm availability and reservation details.'
              : 'Permintaan informasi terkirim. Tim hotel perlu mengonfirmasi ketersediaan dan detail reservasi Anda.',
          success: true,
        );
      } else {
        _message(
          result['message']?.toString() ??
              (en
                  ? 'The request could not be confirmed by the server.'
                  : 'Permintaan belum dapat dikonfirmasi oleh server.'),
        );
      }
    } catch (e) {
      if (mounted) _message(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String value, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
        backgroundColor: success ? HotelColors.green : HotelColors.navy,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LuxuryPanel(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              en ? 'Stay details' : 'Detail penginapan',
              style: GoogleFonts.cormorantGaramond(
                color: HotelColors.charcoal,
                fontSize: 27,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 17),
            FormLabel(en ? 'CHECK-IN' : 'TANGGAL CHECK-IN'),
            DateField(value: _date(_checkIn), onTap: () => _pickDate(true)),
            const SizedBox(height: 14),
            FormLabel(en ? 'CHECK-OUT' : 'TANGGAL CHECK-OUT'),
            DateField(value: _date(_checkOut), onTap: () => _pickDate(false)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: CounterField(
                    label: en ? 'Guests' : 'Tamu',
                    value: _guests,
                    onChanged: (v) => setState(() => _guests = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CounterField(
                    label: en ? 'Rooms' : 'Kamar',
                    value: _rooms,
                    onChanged: (v) => setState(() => _rooms = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FormLabel(en ? 'FULL NAME' : 'NAMA LENGKAP'),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: en ? 'Your name' : 'Nama Anda',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? (en ? 'Name is required' : 'Nama wajib diisi')
                  : null,
            ),
            const SizedBox(height: 14),
            FormLabel('EMAIL'),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'name@email.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) {
                if (v == null ||
                    !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                  return en ? 'Enter a valid email' : 'Masukkan email valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: HotelColors.navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 19,
                        width: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        en
                            ? 'SEND BOOKING INQUIRY'
                            : 'KIRIM PERMINTAAN BOOKING',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServicesScreen extends StatelessWidget {
  final bool english;
  final void Function({String type, String? title}) onInquiry;

  const ServicesScreen({
    super.key,
    required this.english,
    required this.onInquiry,
  });

  @override
  Widget build(BuildContext context) {
    final items = english
        ? [
            (
              'Dining & Restaurant',
              'Dining and restaurant information',
              Icons.restaurant_outlined,
              'dining_inquiry',
            ),
            (
              'Housekeeping',
              'Housekeeping service inquiries',
              Icons.cleaning_services_outlined,
              'service_inquiry',
            ),
            (
              'Laundry',
              'Laundry service information',
              Icons.local_laundry_service_outlined,
              'service_inquiry',
            ),
            (
              'Transportation',
              'Transportation information',
              Icons.directions_car_outlined,
              'transport_inquiry',
            ),
            (
              'Meeting & Event',
              'Meeting rooms and event requirements',
              Icons.meeting_room_outlined,
              'event_inquiry',
            ),
            (
              'General Assistance',
              'General help and hotel information',
              Icons.support_agent_outlined,
              'general',
            ),
          ]
        : [
            (
              'Dining & Restaurant',
              'Informasi makanan dan dining',
              Icons.restaurant_outlined,
              'dining_inquiry',
            ),
            (
              'Housekeeping',
              'Pertanyaan layanan kebersihan',
              Icons.cleaning_services_outlined,
              'service_inquiry',
            ),
            (
              'Laundry',
              'Informasi layanan laundry',
              Icons.local_laundry_service_outlined,
              'service_inquiry',
            ),
            (
              'Transportation',
              'Informasi transportasi',
              Icons.directions_car_outlined,
              'transport_inquiry',
            ),
            (
              'Meeting & Event',
              'Kebutuhan ruang pertemuan dan acara',
              Icons.meeting_room_outlined,
              'event_inquiry',
            ),
            (
              'General Assistance',
              'Bantuan dan informasi umum',
              Icons.support_agent_outlined,
              'general',
            ),
          ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
        children: [
          SectionTitle(
            eyebrow: english ? 'HOSPITALITY' : 'KERAMAHAN HOTEL',
            title: english ? 'Hotel Services' : 'Layanan Hotel',
            subtitle: english
                ? 'Choose a service to send an inquiry to the hotel team.'
                : 'Pilih layanan untuk mengirim pertanyaan kepada tim hotel.',
          ),
          const SizedBox(height: 22),
          ...items.map(
            (item) => ServiceTile(
              title: item.$1,
              subtitle: item.$2,
              icon: item.$3,
              onTap: () => onInquiry(type: item.$4, title: item.$1),
            ),
          ),
          const SizedBox(height: 18),
          const PoweredByFooter(),
        ],
      ),
    );
  }
}

class ConciergeScreen extends StatelessWidget {
  final bool english;
  final void Function({String type, String? title}) onInquiry;

  const ConciergeScreen({
    super.key,
    required this.english,
    required this.onInquiry,
  });

  @override
  Widget build(BuildContext context) {
    final faqs = english
        ? [
            (
              'How can I ask about room availability?',
              'Use the Booking tab to send your preferred dates to the hotel.',
            ),
            (
              'Can I request event information?',
              'Choose Meeting & Event in Hotel Services to send an inquiry.',
            ),
            (
              'Is online payment available?',
              'Online payment is not connected in this app yet.',
            ),
            (
              'Is my booking automatically confirmed?',
              'No. The hotel team must confirm availability and reservation details.',
            ),
          ]
        : [
            (
              'Bagaimana menanyakan ketersediaan kamar?',
              'Gunakan menu Booking untuk mengirim tanggal pilihan Anda kepada hotel.',
            ),
            (
              'Bisakah saya meminta informasi event?',
              'Pilih Meeting & Event pada menu Layanan Hotel.',
            ),
            (
              'Apakah pembayaran online tersedia?',
              'Pembayaran online belum terhubung pada aplikasi ini.',
            ),
            (
              'Apakah booking otomatis terkonfirmasi?',
              'Tidak. Tim hotel harus mengonfirmasi ketersediaan dan detail reservasi.',
            ),
          ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
        children: [
          SectionTitle(
            eyebrow: 'GUEST ASSISTANCE',
            title: english ? 'How can we help?' : 'Ada yang bisa kami bantu?',
            subtitle: english
                ? 'Find answers or send a message to the hotel.'
                : 'Temukan jawaban atau kirim pertanyaan kepada hotel.',
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [HotelColors.navy, HotelColors.navySoft],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.support_agent_rounded,
                  color: HotelColors.gold,
                  size: 38,
                ),
                const SizedBox(height: 13),
                Text(
                  english ? 'Contact our hotel team' : 'Hubungi tim hotel',
                  style: GoogleFonts.cormorantGaramond(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  english
                      ? 'Send your question and our team can follow up.'
                      : 'Kirim pertanyaan Anda agar tim hotel dapat menindaklanjuti.',
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.55,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 17),
                PressableGoldButton(
                  label: english ? 'SEND AN INQUIRY' : 'KIRIM PERTANYAAN',
                  onPressed: () => onInquiry(
                    type: 'general',
                    title: english ? 'Contact concierge' : 'Hubungi concierge',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 27),
          Text(
            english ? 'FREQUENTLY ASKED QUESTIONS' : 'PERTANYAAN UMUM',
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.5,
              color: HotelColors.bronze,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...faqs.map(
            (faq) => Container(
              margin: const EdgeInsets.only(bottom: 9),
              decoration: BoxDecoration(
                color: HotelColors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: HotelColors.border),
              ),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  title: Text(
                    faq.$1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: HotelColors.charcoal,
                      fontSize: 12,
                    ),
                  ),
                  iconColor: HotelColors.bronze,
                  collapsedIconColor: HotelColors.muted,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        faq.$2,
                        style: const TextStyle(
                          color: HotelColors.muted,
                          fontSize: 12,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          const PoweredByFooter(),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final bool english;
  final ValueChanged<bool> onLanguageChanged;

  const ProfileScreen({
    super.key,
    required this.english,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
        children: [
          SectionTitle(
            eyebrow: 'GUEST ACCOUNT',
            title: english ? 'Your Profile' : 'Profil Anda',
            subtitle: english
                ? 'Manage your app preferences.'
                : 'Atur preferensi aplikasi Anda.',
          ),
          const SizedBox(height: 22),
          LuxuryPanel(
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: HotelColors.creamDeep,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: HotelColors.bronze,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        english ? 'Hotel Guest' : 'Tamu Hotel',
                        style: const TextStyle(
                          color: HotelColors.charcoal,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        english
                            ? 'Guest login is not available yet'
                            : 'Fitur login tamu belum tersedia',
                        style: const TextStyle(
                          color: HotelColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Text(
            english ? 'PREFERENCES' : 'PREFERENSI',
            style: const TextStyle(
              color: HotelColors.bronze,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 11),
          LuxuryPanel(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              value: english,
              onChanged: onLanguageChanged,
              secondary: const Icon(
                Icons.language_rounded,
                color: HotelColors.bronze,
              ),
              title: Text(
                english ? 'English language' : 'Bahasa Inggris',
                style: const TextStyle(
                  color: HotelColors.charcoal,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              subtitle: Text(
                english ? 'Switch to Indonesian' : 'Ganti ke Bahasa Inggris',
                style: const TextStyle(fontSize: 11),
              ),
              activeThumbColor: HotelColors.bronze,
            ),
          ),
          const SizedBox(height: 10),
          LuxuryPanel(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(
                Icons.info_outline_rounded,
                color: HotelColors.bronze,
              ),
              title: const Text(
                'About this application',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              subtitle: const Text(
                'IPB Convention Hotel Customer App',
                style: TextStyle(fontSize: 11),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: AppConfig.hotelName,
                applicationVersion: '1.0.0',
                applicationLegalese: 'Powered by SERENITY',
              ),
            ),
          ),
          const SizedBox(height: 28),
          const PoweredByFooter(),
        ],
      ),
    );
  }
}

class InquiryScreen extends StatefulWidget {
  final String inquiryType;
  final String title;
  final bool english;

  const InquiryScreen({
    super.key,
    required this.inquiryType,
    required this.title,
    required this.english,
  });

  @override
  State<InquiryScreen> createState() => _InquiryScreenState();
}

class _InquiryScreenState extends State<InquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _notes = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final result = await ApiService.submitInquiry(
        guestName: _name.text,
        email: _email.text,
        inquiryType: widget.inquiryType,
        notes: _notes.text,
      );

      if (!mounted) return;

      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.english
                  ? 'Your inquiry has been received by the server.'
                  : 'Permintaan informasi telah diterima server.',
            ),
            backgroundColor: HotelColors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw ApiException(
          result['message']?.toString() ?? 'Inquiry not confirmed.',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: HotelColors.navy,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final en = widget.english;

    return Scaffold(
      backgroundColor: HotelColors.cream,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          children: [
            Text(
              en ? 'Tell us what you need' : 'Sampaikan kebutuhan Anda',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: HotelColors.charcoal,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              en
                  ? 'Complete this form so the hotel team can follow up.'
                  : 'Lengkapi formulir agar tim hotel dapat menindaklanjuti.',
              style: const TextStyle(
                color: HotelColors.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 21),
            LuxuryPanel(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: en ? 'Full name' : 'Nama lengkap',
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? (en ? 'Name is required' : 'Nama wajib diisi')
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null ||
                            !RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(v.trim())) {
                          return en
                              ? 'Enter a valid email'
                              : 'Email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _notes,
                      minLines: 4,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: en ? 'Your message' : 'Pesan Anda',
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 70),
                          child: Icon(Icons.message_outlined),
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? (en ? 'Message is required' : 'Pesan wajib diisi')
                          : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _send,
                        style: FilledButton.styleFrom(
                          backgroundColor: HotelColors.navy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 17),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 19,
                                width: 19,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(en ? 'SEND INQUIRY' : 'KIRIM PERMINTAAN'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            InfoPanel(
              icon: Icons.verified_user_outlined,
              text: en
                  ? 'Sending this form is an inquiry only, not a confirmed booking or service order.'
                  : 'Pengiriman formulir ini hanya berupa inquiry, bukan booking atau pesanan layanan yang terkonfirmasi.',
            ),
            const SizedBox(height: 20),
            const PoweredByFooter(),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const SectionTitle({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: HotelColors.bronze,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.9,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          title,
          style: GoogleFonts.cormorantGaramond(
            color: HotelColors.charcoal,
            fontSize: 34,
            fontWeight: FontWeight.w700,
            height: 1.02,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          style: const TextStyle(
            color: HotelColors.muted,
            fontSize: 11.5,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class ServiceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const ServiceTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: HotelColors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: HotelColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: HotelColors.cream,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: HotelColors.bronze, size: 21),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: HotelColors.charcoal,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 10.5, color: HotelColors.muted),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: HotelColors.bronze,
        ),
      ),
    );
  }
}

class DateField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const DateField({super.key, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: HotelColors.white,
          border: Border.all(color: HotelColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: HotelColors.bronze,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: HotelColors.charcoal,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: HotelColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class CounterField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const CounterField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HotelColors.white,
        border: Border.all(color: HotelColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: HotelColors.muted, fontSize: 10),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: value > 1 ? () => onChanged(value - 1) : null,
                child: Icon(
                  Icons.remove_circle_outline,
                  size: 21,
                  color: value > 1 ? HotelColors.bronze : HotelColors.border,
                ),
              ),
              Expanded(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: HotelColors.charcoal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              InkWell(
                onTap: value < 10 ? () => onChanged(value + 1) : null,
                child: Icon(
                  Icons.add_circle_outline,
                  size: 21,
                  color: value < 10 ? HotelColors.bronze : HotelColors.border,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FormLabel extends StatelessWidget {
  final String text;

  const FormLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          color: HotelColors.muted,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class LuxuryPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const LuxuryPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: HotelColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HotelColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class InfoPanel extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoPanel({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: HotelColors.creamDeep,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: HotelColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: HotelColors.bronze, size: 20),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 10.5,
                height: 1.55,
                color: HotelColors.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AssistanceCard extends StatelessWidget {
  final bool english;
  final VoidCallback onTap;

  const AssistanceCard({super.key, required this.english, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: HotelColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.headset_mic_outlined,
            color: HotelColors.gold,
            size: 34,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  english ? 'Need assistance?' : 'Butuh bantuan?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  english
                      ? 'Our hotel team is ready to help.'
                      : 'Tim hotel siap menerima pertanyaan Anda.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: HotelColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}

class PoweredByFooter extends StatelessWidget {
  const PoweredByFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          children: [
            Text(
              AppConfig.hotelName.toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
                color: HotelColors.charcoal,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'POWERED BY ${AppConfig.platformName}',
              style: const TextStyle(
                color: HotelColors.muted,
                fontSize: 8,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
