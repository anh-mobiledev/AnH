import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShareBottomSheet extends StatelessWidget {
  final String shareText;
  final String shareUrl;

  const ShareBottomSheet({
    super.key,
    required this.shareText,
    required this.shareUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Share via',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ShareOption(
                icon: Icons.share,
                label: 'More',
                onTap: () => Share.share('$shareText\n$shareUrl'),
              ),
              _ShareOption(
                icon: FontAwesomeIcons.whatsapp,
                label: 'WhatsApp',
                onTap: () =>
                    _launchUri("whatsapp://send?text=$shareText $shareUrl"),
              ),
              _ShareOption(
                icon: FontAwesomeIcons.google,
                label: 'Gmail',
                onTap: () => _launchUri(
                    "mailto:?subject=Check this out&body=$shareText $shareUrl"),
              ),
              _ShareOption(
                icon: FontAwesomeIcons.facebook,
                label: 'Facebook',
                onTap: () => _launchUri(
                    "https://www.facebook.com/sharer/sharer.php?u=$shareUrl"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _launchUri(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ Could not launch $url');
    }
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close bottom sheet
        onTap();
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
