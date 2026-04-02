import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet/premium/providers/premium_provider.dart';

class PremiumGate extends StatelessWidget {
  final Widget child;
  final String title;
  final String subtitle;
  final bool requiresExperimental;

  const PremiumGate({
    super.key,
    required this.child,
    required this.title,
    required this.subtitle,
    this.requiresExperimental = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, premium, _) {
        if (premium.isPremium &&
            (!requiresExperimental || premium.experimentalEnabled)) {
          return child;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (!premium.isPremium) {
                    premium.setPremium(true);
                  } else if (requiresExperimental) {
                    premium.setExperimental(true);
                  }
                },
                child: Text(
                  !premium.isPremium ? 'Unlock Premium' : 'Enable Experimental',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
