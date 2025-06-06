
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_crm/widgets/app_bar_widget.dart';
import '../bloc_files/dashboard_bloc/dashboard_bloc.dart';
import '../models/dashboard_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardLoaded) {
              return _buildDashboard(context,state.data);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext ctx,DashboardData data) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            _buildStatCard(ctx,'Total Leads', data.totalLeads.toString(), Colors.deepPurple[500]!),
            const SizedBox(width: 16),
            _buildStatCard(ctx,'Total Contacts', data.totalContacts.toString(), Colors.deepPurple[500]!),
          ],
        ),
        const SizedBox(height: 32),
        const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        data.recentActivities.isNotEmpty ? Expanded(
          child: ListView.builder(
            itemCount: data.recentActivities.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.timeline,color: Colors.deepPurple,),
                  title: Text(data.recentActivities[index]),
                ),
              );
            },
          ),
        ) : Center(child: Text("No any recent activity")),
      ],
    );
  }

  Widget _buildStatCard(BuildContext ctx,String title, String count, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () async{
          if(title == 'Total Leads'){
            Navigator.pushNamed(ctx, '/leads');
          }
          else if(title == 'Total Contacts'){
            Navigator.pushNamed(ctx, '/contact');
          }
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(count, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
