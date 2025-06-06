import 'package:hive/hive.dart';
import '../models/activity.dart';
import '../models/contacts_model.dart';
import '../models/dashboard_data.dart';
import '../models/lead.dart';

class DashboardRepository {
  Future<DashboardData> fetchDashboardData() async {
    final leadsBox = await Hive.openBox<Lead>('leads');
    final contactsBox = await Hive.openBox<Contact>('contacts');
    final activityBox = await Hive.openBox<Activity>('activityBox');

    final activities = activityBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // most recent first

    // You can also track recent activity by maintaining a recent activity box or key if needed.
    final data = DashboardData(
      totalLeads: leadsBox.length,
      totalContacts: contactsBox.length,
      recentActivities: activities.take(10).map((e) => e.message).toList(),
    );

    return data;
  }
}
