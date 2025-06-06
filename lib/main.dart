
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:mini_crm/bloc_files/auth_bloc/login_bloc.dart';
import 'package:mini_crm/bloc_files/contacts_bloc/contact_bloc.dart';
import 'package:mini_crm/bloc_files/contacts_bloc/contacts_event.dart';
import 'package:mini_crm/bloc_files/leads_bloc/leads_bloc.dart';
import 'package:mini_crm/models/activity.dart';
import 'package:mini_crm/models/contacts_model.dart';
import 'package:mini_crm/models/lead.dart';
import 'package:mini_crm/repository/user_repo_impl.dart';
import 'package:mini_crm/screens/contacts_screen.dart';
import 'package:mini_crm/screens/leads_screen.dart';
import 'package:mini_crm/screens/login_page.dart';
import 'package:mini_crm/screens/splash_screen.dart';
import 'package:mini_crm/utils/localdatasource.dart';
import 'package:mini_crm/utils/loginusecase.dart';
import 'package:mini_crm/utils/theme_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:mini_crm/bloc_files/dashboard_bloc/dashboard_bloc.dart';
import 'models/user_model.dart';
import 'screens/dashboard_screen.dart';
import 'repository/dashboard_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  Hive.registerAdapter(LeadAdapter());
  Hive.registerAdapter(ContactAdapter());
  Hive.registerAdapter(ActivityAdapter());
  Hive.registerAdapter(UserModelAdapter());
  final userBox = await Hive.openBox<UserModel>('users');
  // Add a dummy user for login test
  if (userBox.isEmpty) {
    userBox.add(UserModel(email: 'test@gmail.com', password: '123456'));
  }
  final userRepo = UserRepositoryImpl(LocalUserDataSource());
  // Open box before runApp
  final leadBox = await Hive.openBox<Lead>('leads');
  final contactBox = await Hive.openBox<Contact>('contacts');
  await Hive.openBox('dashboardBox');
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DashboardRepository>(
          create: (_) => DashboardRepository(),
        ),
      ],
      child: ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: MyApp(userRepositoryImpl: userRepo,leadBox: leadBox,contactBox: contactBox,)),
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  final UserRepositoryImpl userRepositoryImpl;
  final Box<Lead> leadBox;
  final Box<Contact> contactBox;
  const MyApp({super.key,required this.userRepositoryImpl,required this.leadBox,required this.contactBox});

  @override
  Widget build(BuildContext context) {
    final themeprovider = Provider.of<ThemeProvider>(context);
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => DashboardBloc(DashboardRepository())..add(LoadDashboardData())),
          BlocProvider<LeadsBloc>(create: (_) => LeadsBloc(leadBox)..add(LoadLeads()),),
          BlocProvider<ContactsBloc>(
            create: (_) => ContactsBloc(contactBox)..add(LoadContacts()),
          ),
          BlocProvider(create: (_) => AuthBloc(LoginUseCase(userRepositoryImpl)))
        ],
        child: MaterialApp(
            title: 'CRM App',
            themeMode: themeprovider.themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            initialRoute: './',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/leads': (context) => LeadsScreen(),
              '/contact': (context) => ContactsScreen()
            },

        )
    );
  }
}
