import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Row of compact social link buttons
          Row(
            children: <Widget>[
              Expanded(
                child: _CompactSocialButton(
                  title: 'Website',
                  icon: Icons.language,
                  gradient: LinearGradient(
                    colors: <Color>[
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 200),
                    ],
                  ),
                  onTap: () => _launchUrl('https://www.dancefirst.nl'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CompactSocialButton(
                  title: 'Instagram',
                  icon: Icons.camera_alt,
                  gradient: const LinearGradient(
                    colors: <Color>[
                      Color(0xFFE1306C),
                      Color(0xFFC13584),
                      Color(0xFF833AB4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => _launchUrl(
                    'https://www.instagram.com/dancefirst/',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CompactSocialButton(
                  title: 'Facebook',
                  icon: Icons.facebook,
                  gradient: const LinearGradient(
                    colors: <Color>[
                      Color(0xFF1877F2),
                      Color(0xFF0F62C9),
                    ],
                  ),
                  onTap: () => _launchUrl(
                    'https://www.facebook.com/dancefirstalkmaar/',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // News header & placeholder content
          Text(
            'Laatste Nieuws',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Volg ons op social media!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "We plaatsen regelmatig updates, foto's en video's "
                    'van onze danslessen, choreografieën en evenementen '
                    'op onze social media kanalen. Klik op een van de '
                    "knoppen hierboven om direct naar onze pagina's te gaan "
                    'en niets te missen!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
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

class _CompactSocialButton extends StatelessWidget {
  const _CompactSocialButton({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  icon,
                  size: 24,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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
