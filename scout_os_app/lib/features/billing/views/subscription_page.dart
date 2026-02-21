import 'package:scout_os_app/core/widgets/grass_sos_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scout_os_app/features/billing/models/subscription_tier.dart';
import 'package:scout_os_app/features/billing/services/billing_service.dart';

const _kDarkBg = Color(0xFF0A0E1A);
const _kCardBg = Color(0xFF12182B);
const _kSurfaceDark = Color(0xFF1A2138);

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoonPage();
  }
}

class _SubscriptionPricingPage extends StatefulWidget {
  const _SubscriptionPricingPage({super.key});

  @override
  State<_SubscriptionPricingPage> createState() =>
      _SubscriptionPricingPageState();
}

class _SubscriptionPricingPageState extends State<_SubscriptionPricingPage>
    with SingleTickerProviderStateMixin {
  final BillingService _billingService = BillingService();
  final List<SubscriptionTier> _tiers = SubscriptionTier.tiers;

  late PageController _pageController;
  late AnimationController _pulseController;
  String? _selectedTierId;
  int _currentPage = 2; // Default to Pro
  bool _isLoading = false;
  Map<String, dynamic>? _currentStatus;

  @override
  void initState() {
    super.initState();
    int initialIndex = _tiers.indexWhere((t) => t.id == 'pro');
    if (initialIndex == -1) initialIndex = 0;
    _currentPage = initialIndex;
    _selectedTierId = 'pro';

    _pageController = PageController(
      viewportFraction: 0.82,
      initialPage: initialIndex,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _loadStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);
    try {
      final status = await _billingService.fetchSubscriptionStatus();
      setState(() {
        _currentStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDarkBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Pilih Paket',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading && _currentStatus == null
          ? const Center(child: GrassSosLoader(color: Color(0xFF7C4DFF)))
          : Stack(
              children: [
                // Background glow circles
                _buildBackgroundGlows(),
                // Main content
                Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 56),
                    _buildHeroSection(),
                    const SizedBox(height: 20),
                    // Page indicator dots
                    _buildPageIndicator(),
                    const SizedBox(height: 16),
                    // Cards
                    Expanded(child: _buildCardCarousel()),
                    // Bottom CTA
                    _buildBottomAction(),
                  ],
                ),
              ],
            ),
    );
  }

  /// Ambient neon glow circles in the background
  Widget _buildBackgroundGlows() {
    final tier = _tiers[_currentPage];
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final pulse = 0.15 + (_pulseController.value * 0.1);
        return Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      tier.glowColor.withOpacity(pulse),
                      tier.glowColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      tier.primaryColor.withOpacity(pulse * 0.6),
                      tier.primaryColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Text(
            'Buka Akses Super Pramuka',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15),
          const SizedBox(height: 10),
          Text(
            'Pilih paket dan kuasai semua materi kepramukaan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.5),
              height: 1.4,
            ),
          ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.15),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_tiers.length, (index) {
        final isActive = _currentPage == index;
        final tier = _tiers[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? tier.primaryColor : Colors.white24,
            borderRadius: BorderRadius.circular(4),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: tier.primaryColor.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }

  Widget _buildCardCarousel() {
    return PageView.builder(
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
          _selectedTierId = _tiers[index].id;
        });
      },
      itemCount: _tiers.length,
      itemBuilder: (context, index) {
        final tier = _tiers[index];
        final isSelected = _currentPage == index;
        final isCurrent = _currentStatus?['tier'] == tier.id;

        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double scale = 1.0;
            if (_pageController.position.haveDimensions) {
              double val = _pageController.page! - index;
              scale = (1 - (val.abs() * 0.12)).clamp(0.88, 1.0);
            } else {
              scale = isSelected ? 1.0 : 0.88;
            }
            return Transform.scale(scale: scale, child: child);
          },
          child: _buildTierCard(tier, isSelected, isCurrent, index),
        );
      },
    );
  }

  Widget _buildTierCard(
    SubscriptionTier tier,
    bool isSelected,
    bool isCurrent,
    int index,
  ) {
    final bool isPro = tier.id == 'pro';

    return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          // Flat 3D: the lip/shadow layer
          decoration: BoxDecoration(
            color: tier.lipColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: tier.glowColor.withOpacity(0.3),
                      blurRadius: 24,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 6), // The 3D lip depth
            decoration: BoxDecoration(
              color: _kCardBg,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isSelected
                    ? tier.primaryColor.withOpacity(0.6)
                    : Colors.white.withOpacity(0.06),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Background icon watermark
                Positioned(
                  right: -10,
                  bottom: 20,
                  child: Icon(
                    tier.icon,
                    size: 120,
                    color: tier.primaryColor.withOpacity(0.06),
                  ),
                ),
                // Recommended badge
                if (tier.isRecommended)
                  Positioned(
                    top: -14,
                    left: 0,
                    right: 0,
                    child: Center(
                      child:
                          Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: tier.primaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: tier.glowColor.withOpacity(0.5),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '⭐ PALING POPULER',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              )
                              .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true),
                              )
                              .scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.04, 1.04),
                                duration: 1200.ms,
                              ),
                    ),
                  ),
                // Card body
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top: Icon + Name
                      Row(
                        children: [
                          // 3D Icon circle
                          Container(
                            decoration: BoxDecoration(
                              color: tier.lipColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: tier.primaryColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                tier.icon,
                                color: isPro ? Colors.black : Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tier.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: tier.primaryColor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tier.subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (isCurrent) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF00E676).withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            '✅ PAKET AKTIF',
                            style: TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            tier.priceLabel,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: isPro ? tier.primaryColor : Colors.white,
                              height: 1,
                            ),
                          ),
                          if (tier.priceValue > 0) ...[
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '/bulan',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.35),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tier.anchorText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: tier.primaryColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Divider with glow
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              tier.primaryColor.withOpacity(0.0),
                              tier.primaryColor.withOpacity(0.3),
                              tier.primaryColor.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Benefits
                      Expanded(
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: tier.benefits.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: tier.primaryColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: tier.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    tier.benefits[i],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.75),
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 120).ms)
        .slideY(begin: 0.08, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildBottomAction() {
    if (_selectedTierId == null) return const SizedBox.shrink();

    final selectedTier = _tiers.firstWhere((t) => t.id == _selectedTierId);
    final bool isFree = selectedTier.id == 'free';
    final bool isPro = selectedTier.id == 'pro';
    final bool isCurrent = _currentStatus?['tier'] == selectedTier.id;

    Color buttonColor;
    Color buttonLipColor;

    if (isCurrent) {
      buttonColor = _kSurfaceDark;
      buttonLipColor = Colors.black;
    } else if (isPro) {
      buttonColor = selectedTier.primaryColor;
      buttonLipColor = selectedTier.lipColor;
    } else if (isFree) {
      buttonColor = _kSurfaceDark;
      buttonLipColor = const Color(0xFF0D1120);
    } else {
      buttonColor = selectedTier.primaryColor;
      buttonLipColor = selectedTier.lipColor;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kDarkBg.withOpacity(0.0), _kDarkBg, _kDarkBg],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isFree && !isCurrent)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Langganan per bulan. Batalkan kapan saja.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            // Flat 3D button
            GestureDetector(
              onTap: isCurrent ? null : _handlePurchase,
              child: Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: buttonLipColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: !isCurrent && !isFree
                      ? [
                          BoxShadow(
                            color: selectedTier.glowColor.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Container(
                  height: 54,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      isCurrent
                          ? 'PAKET SEDANG AKTIF'
                          : (isFree
                                ? 'LANJUTKAN GRATIS'
                                : 'BERLANGGANAN SEKARANG'),
                      style: TextStyle(
                        color: isCurrent
                            ? Colors.white38
                            : (isPro ? Colors.black : Colors.white),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(
      begin: 0.5,
      end: 0,
      duration: 500.ms,
      curve: Curves.easeOutCubic,
    );
  }

  void _handlePurchase() {
    if (_selectedTierId == null || _selectedTierId == 'free') {
      Navigator.pop(context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _ComingSoonPage()),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// "Sistem Sedang Dalam Tahap Pengembangan" — Flat 3D Duolingo
// ─────────────────────────────────────────────────────────────
class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage();

  static const _bg = Color(0xFF0A0E1A);
  static const _card = Color(0xFF12182B);
  static const _accent = Color(0xFF7C4DFF); // Purple
  static const _accentLip = Color(0xFF4A148C);
  static const _accentGlow = Color(0xFFB388FF);
  static const _green = Color(0xFF58CC02); // Duolingo green
  static const _greenLip = Color(0xFF46A302);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accentGlow.withOpacity(0.15),
                    _accentGlow.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_green.withOpacity(0.1), _green.withOpacity(0.0)],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // 3D Icon Card
                  _buildIconCard()
                      .animate()
                      .scale(
                        delay: 200.ms,
                        duration: 500.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(),
                  const SizedBox(height: 36),
                  // Title
                  const Text(
                    'Fitur Sedang\nDalam Pengembangan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: 0.3,
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.15),
                  const SizedBox(height: 16),
                  // Subtitle
                  Text(
                    'Tim kami sedang bekerja keras untuk\nmenghadirkan fitur berlangganan ini.\nTunggu update selanjutnya ya! 🚀',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.5),
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.15),
                  const SizedBox(height: 40),
                  // Info chips
                  _buildInfoChips()
                      .animate()
                      .fadeIn(delay: 700.ms)
                      .slideY(begin: 0.1),
                  const Spacer(flex: 3),
                  // CTA Button
                  _buildBackButton(context)
                      .animate()
                      .slideY(
                        begin: 0.4,
                        end: 0,
                        delay: 800.ms,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .fadeIn(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconCard() {
    return Container(
      decoration: BoxDecoration(
        color: _accentLip,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _accentGlow.withOpacity(0.25),
            blurRadius: 30,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _accent.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Inner 3D icon
            Container(
                  decoration: BoxDecoration(
                    color: _accentLip,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.construction_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                  begin: -3,
                  end: 3,
                  duration: 1800.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 16),
            // Progress bar
            Container(
              width: 120,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child:
                    Container(
                          width: 80,
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_accent, _accentGlow],
                            ),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: _accentGlow.withOpacity(0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleX(
                          begin: 0.6,
                          end: 1.0,
                          duration: 2.seconds,
                          curve: Curves.easeInOut,
                        ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Progress: 65%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _accentGlow.withOpacity(0.7),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChips() {
    final items = [
      ('🔒', 'Pembayaran Aman'),
      ('⚡', 'Segera Hadir'),
      ('🎁', 'Bonus Early Access'),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Text(
            '${item.$1}  ${item.$2}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _greenLip,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _green.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Container(
          height: 54,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(
            child: Text(
              'SAYA MENGERTI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
