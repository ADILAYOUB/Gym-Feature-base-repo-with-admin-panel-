import 'package:flutter/material.dart';
import 'layout/fitflow_sidebar.dart';
import 'layout/fitflow_header.dart';
import 'views/dashboard_overview_view.dart';
import 'views/member_list_view.dart';
import 'views/workout_routine_view.dart';
import 'views/diet_chart_view.dart';
import 'views/trainer_details_view.dart';
import 'views/admin_settings_view.dart';
import 'views/analytics_report_view.dart';

class FitflowAdminDashboard extends StatefulWidget {
  const FitflowAdminDashboard({Key? key}) : super(key: key);

  @override
  State<FitflowAdminDashboard> createState() => _FitflowAdminDashboardState();
}

class _FitflowAdminDashboardState extends State<FitflowAdminDashboard> {
  int _selectedNavIndex = 0;

  Widget _buildBodyContent() {
    switch (_selectedNavIndex) {
      case 0:
        return const DashboardOverviewView();
      case 1:
        return const MemberListView();
      case 2:
        return const WorkoutRoutineView();
      case 3:
        return const DietChartView();
      case 4:
        return const TrainerDetailsView();
      case 5:
        return const TrainerDetailsView();
      case 6:
        return const MemberListView();
      case 7:
        return const AnalyticsReportView();
      case 8:
        return const AdminSettingsView();
      default:
        return const DashboardOverviewView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161722),
      body: Row(
        children: [
          // Left Navigation Sidebar
          FitflowSidebar(
            selectedIndex: _selectedNavIndex,
            onItemSelected: (index) {
              setState(() => _selectedNavIndex = index);
            },
          ),

          // Main Desktop Content Area
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                const FitflowHeader(),

                // Dynamic Body Page View
                Expanded(
                  child: Container(
                    color: const Color(0xFF161722),
                    child: _buildBodyContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
