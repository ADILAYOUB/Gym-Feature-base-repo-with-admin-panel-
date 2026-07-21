import 'package:flutter/material.dart';

class FitflowSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const FitflowSidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  static const List<Map<String, dynamic>> menuItems = [
    {'title': 'Dashboard', 'icon': Icons.grid_view_rounded},
    {'title': 'Member', 'icon': Icons.people_outline_rounded},
    {'title': 'Workout Routine', 'icon': Icons.calendar_month_outlined},
    {'title': 'Diet Chart', 'icon': Icons.restaurant_menu_outlined},
    {'title': 'Batch Schedule', 'icon': Icons.event_note_outlined},
    {'title': 'Trainer List', 'icon': Icons.badge_outlined},
    {'title': 'Billing List', 'icon': Icons.receipt_long_outlined},
    {'title': 'Report', 'icon': Icons.insert_chart_outlined},
    {'title': 'Setting', 'icon': Icons.settings_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    const sidebarBg = Color(0xFF1E1F2A);
    const activeOrange = Color(0xFFFF5500);

    return Container(
      width: 250,
      color: sidebarBg,
      child: Column(
        children: [
          // Logo Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: activeOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fitness_center, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Fitflow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Menu Navigation List
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                  child: InkWell(
                    onTap: () => onItemSelected(index),
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: isSelected ? activeOrange : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            color: isSelected ? Colors.white : Colors.grey.shade400,
                            size: 20,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade300,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Upgrade Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF282936),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Upgrade to ',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: activeOrange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Basic', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('21 Days Left', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.65,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: const AlwaysStoppedAnimation<Color>(activeOrange),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Upgrade Plan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
            child: InkWell(
              onTap: () {},
              child: Row(
                children: const [
                  Icon(Icons.logout, color: Colors.grey, size: 18),
                  SizedBox(width: 12),
                  Text('Log Out', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
