import 'package:flutter/material.dart';

class FitflowHeader extends StatelessWidget {
  const FitflowHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      color: const Color(0xFF1E1F2A),
      child: Row(
        children: [
          // Search Input Box
          Expanded(
            child: MaxWidthContainer(
              maxWidth: 400,
              child: SizedBox(
                height: 42,
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Find something here...',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                    filled: true,
                    fillColor: const Color(0xFF282936),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Sparkle / AI Button
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.auto_awesome, color: Color(0xFFFF5500), size: 22),
            tooltip: 'AI Assistant',
          ),

          // Notifications Bell Icon
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none, color: Colors.grey, size: 22),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5500),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // User Profile Pill
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200'),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Emon',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    'Super Admin',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class MaxWidthContainer extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const MaxWidthContainer({
    Key? key,
    required this.maxWidth,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
