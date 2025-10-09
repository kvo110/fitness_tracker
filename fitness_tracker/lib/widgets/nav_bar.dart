import 'package:flutter/material.dart';

// Represents icons in the navigation bar
class NavItem {
    final IconData icon;
    final String label;
    const NavItem({required this.icon, required this.label});
}

// Floating rectangular navigation bar with rounded edges
class NavBar extends StatelessWidget {
    final int currentIndex; // active icon
    final void Function(int) onTap; // called when icon pressed
    final List<NavItem> items; // list of new icons and labels

    const NavBar({
        super.key,
        required this.currentIndex,
        required this.onTap,
        required this.items,
    });

    @override
    Widget build(BuildContext context) {
        // Set background color based on toggled theme mode
        final bg = Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.grey[900];

        return Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: Container(
                height: 70,
                decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            offset: const Offset(0, 8),
                        ),
                    ],
                ),
                // Build nav icons
                child: Row(
                    mainAxisAlignment: MainAcisAlignment.spaceEvenly,
                    children: List.generate(items.length, (i) {
                        final selected = i == currentIndex;
                        final color = selected ? Theme.of(context).colorScheme.primary : Colors.grey;
                        return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => onTap(i),
                            child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                    borerRadius: BorderRadius.circular(16),
                                    color: selected ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : Colors.transparent,
                                ),
                                // Each nav icon and their corresponding labels
                                child: Row(
                                    children: [
                                        Icon(items[i].icon, color: color),
                                        const SizedBox(width: 6),
                                        if (selected)
                                            Text(
                                                items[i].label,
                                                style: TextStyle(
                                                    color: color,
                                                    fontWeight: fontWeight.w600,
                                                ),
                                            ),
                                    ],
                                ),
                            ),
                        );
                    }),
                ),
            ),
        );
    }
}