import 'package:flutter/material.dart';

class SkinHealthTipsScreen extends StatelessWidget {
  final String userId;

  const SkinHealthTipsScreen({
    super.key,
    this.userId = "test-user-001",
  });

  static const pink = Color(0xffef5f8f);
  static const lightPink = Color(0xffffeef4);
  static const dark = Color(0xff251b35);
  static const muted = Color(0xff756578);
  static const sheetBg = Color(0xfffff7fa);

  static const featuredTip = SkinTip(
    title: "Always Use Sunscreen",
    heading: "Sunscreen kinda girl ",
    description:
    "Apply sunscreen daily, even on cloudy days. Choose SPF 30 or higher.",
    detail:
    "Sunscreen protects your skin from UV damage, premature aging, dark spots, and irritation. Apply SPF 30 or higher every morning and reapply every 2 hours when outdoors.",
    image: "assets/images/sunscreen_face.png",
    fallbackIcon: Icons.wb_sunny_outlined,
  );

  static const tips = [
    SkinTip(
      title: "Stay Hydrated",
      heading: "Drink Your Water Girl",
      description: "Drink plenty of water to keep your skin hydrated and fresh.",
      detail:
      "Hydration helps maintain skin elasticity, supports your skin barrier, and keeps your complexion looking fresh. Sip water throughout the day and include water-rich fruits.",
      image: "assets/images/hydrated.png",
      fallbackIcon: Icons.water_drop_outlined,
    ),
    SkinTip(
      title: "Gentle Cleansing",
      heading: "It's a little things always",
      description: "Use a mild cleanser to avoid irritating your skin.",
      detail:
      "Cleanse your face gently twice a day. Avoid harsh scrubbing because it can weaken your skin barrier and cause dryness, redness, or irritation.",
      image: "assets/images/cleanser.png",
      fallbackIcon: Icons.soap_outlined,
    ),
    SkinTip(
      title: "Healthy Diet",
      heading: "She eats like she Love her Self",
      description: "Eat fruits and vegetables for clear, radiant skin.",
      detail:
      "A balanced diet rich in fruits, vegetables, healthy fats, and antioxidants supports glowing skin from within. Try to reduce excess sugar and processed foods.",
      image: "assets/images/fruits_bowl.png",
      fallbackIcon: Icons.local_dining_outlined,
    ),
  ];

  void _showTip(BuildContext context, SkinTip tip) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TipSheet(tip: tip),
    );
  }

  void _showHeaderInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: sheetBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Skin Health Tips",
          style: TextStyle(
            fontFamily: "Georgia",
            color: dark,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        content: const Text(
          "Simple daily skincare habits to keep your skin healthy, glowing, and protected.",
          style: TextStyle(color: muted, fontSize: 16, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: pink)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _Bg(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.chevron_left),
                    iconSize: 34,
                    color: pink,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    "Skin Health Tips",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: "Georgia",
                      fontSize: 33,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      color: dark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _showHeaderInfo(context),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "It's a Glow O'clock",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 18, color: muted),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _SoftIcon(icon: Icons.local_florist, size: 22),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  _FeaturedCard(
                    tip: featuredTip,
                    onTap: () => _showTip(context, featuredTip),
                  ),
                  const SizedBox(height: 16),
                  ...tips.map(
                        (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TipTile(
                        tip: tip,
                        onTap: () => _showTip(context, tip),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final SkinTip tip;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.tip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      radius: 26,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: _TipCopy(
              badge: "Featured Tip",
              title: tip.title,
              heading: tip.heading,
              description: tip.description,
              titleSize: 28,
              headingSize: 15,
              descriptionSize: 15,
              showAccent: true,
            ),
          ),
          const SizedBox(width: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _SafeImage(
              asset: tip.image,
              width: 112,
              height: 154,
              fit: BoxFit.cover,
              icon: tip.fallbackIcon,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipTile extends StatelessWidget {
  final SkinTip tip;
  final VoidCallback onTap;

  const _TipTile({
    required this.tip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      radius: 24,
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          _ImageBox(asset: tip.image, icon: tip.fallbackIcon),
          const SizedBox(width: 12),
          Expanded(
            child: _TipCopy(
              title: tip.title,
              heading: tip.heading,
              description: tip.description,
              titleSize: 19,
              headingSize: 14,
              descriptionSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          const _ArrowButton(),
        ],
      ),
    );
  }
}

class _TipCopy extends StatelessWidget {
  final String title;
  final String heading;
  final String description;
  final String? badge;
  final double titleSize;
  final double headingSize;
  final double descriptionSize;
  final bool showAccent;

  const _TipCopy({
    required this.title,
    required this.heading,
    required this.description,
    required this.titleSize,
    required this.headingSize,
    required this.descriptionSize,
    this.badge,
    this.showAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (badge != null) ...[
          _Badge(text: badge!),
          const SizedBox(height: 14),
        ],
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: "Georgia",
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            height: 1.08,
            color: SkinHealthTipsScreen.dark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          heading,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: headingSize,
            fontWeight: FontWeight.w700,
            color: SkinHealthTipsScreen.pink,
          ),
        ),
        if (showAccent) ...[
          const SizedBox(height: 10),
          const _AccentLine(),
        ],
        const SizedBox(height: 8),
        Text(
          description,
          maxLines: showAccent ? 3 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: descriptionSize,
            height: 1.35,
            color: SkinHealthTipsScreen.dark,
          ),
        ),
      ],
    );
  }
}

class _TipSheet extends StatelessWidget {
  final SkinTip tip;

  const _TipSheet({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
      decoration: const BoxDecoration(
        color: SkinHealthTipsScreen.sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 5,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: SkinHealthTipsScreen.pink.withValues(alpha: .25),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            _ImageBox(asset: tip.image, icon: tip.fallbackIcon),
            const SizedBox(height: 14),
            Text(
              tip.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "Georgia",
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: SkinHealthTipsScreen.dark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tip.heading,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: SkinHealthTipsScreen.pink,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tip.detail,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.45,
                color: SkinHealthTipsScreen.muted,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: SkinHealthTipsScreen.pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36),
                  ),
                ),
                child: const Text(
                  "Got it",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
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

class _Bg extends StatelessWidget {
  const _Bg();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        "assets/images/background.png",
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Container(color: SkinHealthTipsScreen.lightPink),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double radius;
  final EdgeInsets padding;

  const _GlassCard({
    required this.child,
    required this.onTap,
    required this.radius,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .78),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: .65)),
            boxShadow: [
              BoxShadow(
                color: SkinHealthTipsScreen.pink.withValues(alpha: .07),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: SkinHealthTipsScreen.pink.withValues(alpha: .32),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 13, color: SkinHealthTipsScreen.pink),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: SkinHealthTipsScreen.pink,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageBox extends StatelessWidget {
  final String asset;
  final IconData icon;

  const _ImageBox({
    required this.asset,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: 58,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: SkinHealthTipsScreen.lightPink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: _SafeImage(asset: asset, icon: icon),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 31,
      width: 31,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: SkinHealthTipsScreen.lightPink,
        border: Border.all(
          color: SkinHealthTipsScreen.pink.withValues(alpha: .16),
        ),
      ),
      child: const Icon(
        Icons.chevron_right,
        color: SkinHealthTipsScreen.pink,
        size: 21,
      ),
    );
  }
}

class _SoftIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const _SoftIcon({
    required this.icon,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: SkinHealthTipsScreen.pink.withValues(alpha: .38),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(icon, size: size * .58, color: Colors.white),
    );
  }
}

class _AccentLine extends StatelessWidget {
  const _AccentLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 3,
      decoration: BoxDecoration(
        color: SkinHealthTipsScreen.pink.withValues(alpha: .75),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _SafeImage extends StatelessWidget {
  final String asset;
  final IconData icon;
  final double? height;
  final double? width;
  final BoxFit fit;

  const _SafeImage({
    required this.asset,
    required this.icon,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Icon(icon, color: SkinHealthTipsScreen.pink, size: 28);
      },
    );
  }
}

class SkinTip {
  final String title;
  final String heading;
  final String description;
  final String detail;
  final String image;
  final IconData fallbackIcon;

  const SkinTip({
    required this.title,
    required this.heading,
    required this.description,
    required this.detail,
    required this.image,
    required this.fallbackIcon,
  });
}