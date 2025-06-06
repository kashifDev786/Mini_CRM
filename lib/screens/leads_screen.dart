import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_crm/utils/helper.dart';
import 'package:mini_crm/widgets/add_and_edit_dialog.dart';
import 'package:uuid/uuid.dart';
import '../bloc_files/dashboard_bloc/dashboard_bloc.dart';
import '../bloc_files/contacts_bloc/contact_bloc.dart';
import '../bloc_files/contacts_bloc/contacts_event.dart';
import '../bloc_files/leads_bloc/leads_bloc.dart';
import '../models/lead.dart';
import '../utils/logactivity.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final statuses = ['All', 'New', 'Contacted', 'Converted', 'Dropped'];
  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<LeadsBloc>().add(LoadLeads()));
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('Leads',style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search leads...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => context.read<LeadsBloc>().add(SearchLeads(value)),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),

              border: Border.all( // <-- this line adds border color
                color: Colors.deepPurple, // you can use any color you like
                width: 1.5,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                borderRadius: BorderRadius.circular(12),
                value: selectedStatus,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedStatus = value);
                    context.read<LeadsBloc>().add(FilterLeads(value));
                  }
                },
                isExpanded: true,
                items: statuses.map((status) => DropdownMenuItem(value: status, child: Text(status,))).toList(),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<LeadsBloc, LeadsState>(
              builder: (context, state) {
                if (state is LeadsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is LeadsLoaded) {
                  if (state.leads.isEmpty) {
                    return const Center(child: Text("No leads available."));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.leads.length,
                    itemBuilder: (context, index) {
                      final lead = state.leads[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Dismissible(
                          key: Key(lead.key.toString()),
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (_) {
                            context.read<LeadsBloc>().add(DeleteLead(lead));
                            context.read<DashboardBloc>().add(LoadDashboardData());
                          },
                          child: Column(

                            children: [
                              ListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      lead.name,
                                      style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.deepPurple),
                                      onPressed: () => showDialog(
                                          context: context,
                                          builder: (_) => LeadDialog(lead: lead,)
                                      ).then((_){
                                        print("object");
                                        context.read<LeadsBloc>().add(LoadLeads());

                                      }),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text("Email   :",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),),
                                        Expanded(child: Text(lead.email)),
                                      ],
                                    ),
                                    SizedBox(height: 8,),
                                    Row(
                                      children: [
                                        Expanded(child: Text("Phone  :",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),),
                                        Expanded(child: Text(lead.phone)),
                                      ],
                                    ),
                                    SizedBox(height: 8,),
                                    Row(
                                      children: [
                                        Expanded(child: Text("Status  :",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),),
                                        Expanded(child: Text(lead.status)),
                                      ],
                                    ),


                                  ],
                                ),

                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple
                                    ),
                                      onPressed: () async{
                                        context.read<LeadsBloc>().add(ConvertLeadToContact(lead));
                                        context.read<ContactsBloc>().add(LoadContacts());
                                        await Helper().logActivity("Lead ${lead.name} converted to Contact");
                                        context.read<DashboardBloc>().add(LoadDashboardData());
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Lead converted to contact!')),
                                        );
                                      },
                                      child: Text("Converted to Contact",style: TextStyle(color: Colors.white),)
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
            context: context,
            builder: (_) => LeadDialog()
        ),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}
