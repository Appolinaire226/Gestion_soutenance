import 'package:flutter/material.dart';
import 'package:vivatrack/pagesFolder/firebase_auth.dart';
import '../widgets/responsive_container.dart';
import 'home_page.dart';
//import '/services/sudo_services.dart';

//la resposivite
class NavigationItem {
  final String title;
  final IconData icon;
  final Widget page;

  NavigationItem({required this.title, required this.icon, required this.page});
}

//le corps du code
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;
  //final SudoService _apiService = SudoService();

  // Liste des pages disponibles pour l'étudiant
  final List<Widget> _pages = [
    const StudentHomeView(),
    const Center(child: Text('Mon Planning / Soutenances')),
    const Center(child: Text('Mes Notes / Résultats')),
    const StudentSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Espace Etudiant'),
            backgroundColor: sudocolor,
            foregroundColor: Colors.black,
          ),
          drawer: isWide
              ? null
              : Drawer(
                  child: Column(
                    children: [
                      UserAccountsDrawerHeader(
                        decoration: BoxDecoration(color: sudocolor),
                        currentAccountPicture: const CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.blue,
                          ),
                        ),
                        accountName: const Text(
                          'Nom de Etudiant',
                          style: TextStyle(color: Colors.black),
                        ),
                        accountEmail: Text(
                          SudoAuthService().currentEmail ?? 'Email',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      _buildNavigationItem(
                        icon: Icons.dashboard,
                        label: 'Accueil',
                        index: 0,
                      ),
                      _buildNavigationItem(
                        icon: Icons.calendar_month,
                        label: 'Planning',
                        index: 1,
                      ),
                      _buildNavigationItem(
                        icon: Icons.school,
                        label: 'Mes notes',
                        index: 2,
                      ),
                      const Divider(),
                      _buildNavigationItem(
                        icon: Icons.settings,
                        label: 'Paramètres',
                        index: 3,
                      ),
                      _buildLogoutItem(),
                      const Divider(),
                      const Spacer(),
                      const Divider(height: 1),
                    ],
                  ),
                ),
          body: Row(
            children: [
              if (isWide)
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.white,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Accueil'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month),
                      label: Text('Planning'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.school_outlined),
                      selectedIcon: Icon(Icons.school),
                      label: Text('Mes notes'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Paramètres'),
                    ),
                  ],
                ),
              Expanded(
                child: ResponsivePageContainer(child: _pages[_selectedIndex]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildLogoutItem() {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
      onTap: () async {
        await SudoAuthService().signOut();
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }
}

// Vue principale de l'accueil
class StudentHomeView extends StatelessWidget {
  const StudentHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // final SudoService _service = SudoService();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenue dans l\'espace étudiant,',
            style: TextStyle(
              fontSize: 18,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Que souhaitez-vous faire ?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxis = constraints.maxWidth >= 1100
                    ? 4
                    : constraints.maxWidth >= 700
                    ? 3
                    : 2;
                return GridView.count(
                  crossAxisCount: crossAxis,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildMenuCard(
                      context,
                      'Soutenances',
                      Icons.assignment,
                      Colors.orange,
                    ),
                    _buildMenuCard(
                      context,
                      'Mon Planning',
                      Icons.calendar_today,
                      Colors.blue,
                    ),
                    _buildMenuCard(
                      context,
                      'Documents',
                      Icons.folder,
                      Colors.green,
                    ),
                    _buildMenuCard(
                      context,
                      'Messages',
                      Icons.message,
                      Colors.purple,
                    ),

                    //testt
                    /*  ElevatedButton(
                      onPressed: () async {
                        Map<String, dynamic> nouvelleDonnee = {
                          //donnees a envoyer
                        };

                        try {
                          await _service.createData(nouvelleDonnee);
                          print("Succès : Donnée envoyée !");

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Donnée envoyée avec succès !")),
                          );
                        } catch (e) {
                          print("Erreur : $e");

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Erreur lors de l'envoi")),
                          );
                        }
                      },
                      child: const Text("Envoyer"),
                    ),*/
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // les widget pour gererer les cartes de menu
  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // action lors du clic sur une carte ici
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// Page Paramètres pour l'étudiant avec bouton Déconnexion en bas
class StudentSettingsPage extends StatelessWidget {
  const StudentSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsivePageContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paramètres',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Placez ici d'autres éléments de paramètres
              const Expanded(
                child: Center(
                  child: Text('Options de configuration du compte'),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 220,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Déconnexion'),
                    onPressed: () async {
                      await SudoAuthService().signOut();
                      // Optionnel: revenir à l'écran de login
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('STUDENT DASHBOARD')),
      body: const Center(
        child: Text(
          'Bienvenue sur la page étudiant',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}*/

/*// Flutter code sample for [NavigationRail].

void main() => runApp(const NavigationRailExampleApp());

class NavigationRailExampleApp extends StatelessWidget {
  const NavigationRailExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: NavRailExample());
  }
}

class NavRailExample extends StatefulWidget {
  const NavRailExample({super.key});

  @override
  State<NavRailExample> createState() => _NavRailExampleState();
}

class _NavRailExampleState extends State<NavRailExample> {
  int _selectedIndex = 0;
  NavigationRailLabelType labelType = .all;
  bool showLeading = false;
  bool showTrailing = false;
  double groupAlignment = -1.0;
  MainAxisAlignment? alignment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: _selectedIndex,
              groupAlignment: groupAlignment,
              mainAxisAlignment: alignment,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: labelType,
              leading: showLeading
                  ? FloatingActionButton(
                      elevation: 0,
                      onPressed: () {
                        // Add your onPressed code here!
                      },
                      child: const Icon(Icons.add),
                    )
                  : null,
              trailing: showTrailing
                  ? IconButton(
                      onPressed: () {
                        // Add your onPressed code here!
                      },
                      icon: const Icon(Icons.more_horiz_rounded),
                    )
                  : null,
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  label: Text('First'),
                ),
                NavigationRailDestination(
                  icon: Badge(child: Icon(Icons.bookmark_border)),
                  selectedIcon: Badge(child: Icon(Icons.book)),
                  label: Text('Second'),
                ),
                NavigationRailDestination(
                  icon: Badge(label: Text('4'), child: Icon(Icons.star_border)),
                  selectedIcon: Badge(
                    label: Text('4'),
                    child: Icon(Icons.star),
                  ),
                  label: Text('Third'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // This is the main content.
            Expanded(
              child: Column(
                mainAxisAlignment: .center,
                children: <Widget>[
                  Text('selectedIndex: $_selectedIndex'),
                  const SizedBox(height: 20),
                  Text('Label type: ${labelType.name}'),
                  const SizedBox(height: 10),
                  SegmentedButton<NavigationRailLabelType>(
                    segments: const <ButtonSegment<NavigationRailLabelType>>[
                      ButtonSegment<NavigationRailLabelType>(
                        value: NavigationRailLabelType.none,
                        label: Text('None'),
                      ),
                      ButtonSegment<NavigationRailLabelType>(
                        value: NavigationRailLabelType.selected,
                        label: Text('Selected'),
                      ),
                      ButtonSegment<NavigationRailLabelType>(
                        value: NavigationRailLabelType.all,
                        label: Text('All'),
                      ),
                    ],
                    selected: <NavigationRailLabelType>{labelType},
                    onSelectionChanged:
                        (Set<NavigationRailLabelType> newSelection) {
                          setState(() {
                            labelType = newSelection.first;
                          });
                        },
                  ),
                  const SizedBox(height: 20),
                  Text('Group alignment: $groupAlignment'),
                  const SizedBox(height: 10),
                  SegmentedButton<double>(
                    segments: const <ButtonSegment<double>>[
                      ButtonSegment<double>(value: -1.0, label: Text('Top')),
                      ButtonSegment<double>(value: 0.0, label: Text('Center')),
                      ButtonSegment<double>(value: 1.0, label: Text('Bottom')),
                    ],
                    selected: <double>{groupAlignment},
                    onSelectionChanged: (Set<double> newSelection) {
                      setState(() {
                        groupAlignment = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Main Axis Alignment:'),
                  const SizedBox(height: 10),
                  SegmentedButton<MainAxisAlignment?>(
                    segments: const <ButtonSegment<MainAxisAlignment?>>[
                      ButtonSegment<MainAxisAlignment?>(
                        value: null,
                        label: Text('Default'),
                      ),
                      ButtonSegment<MainAxisAlignment?>(
                        value: MainAxisAlignment.start,
                        label: Text('Start'),
                      ),
                      ButtonSegment<MainAxisAlignment?>(
                        value: MainAxisAlignment.end,
                        label: Text('End'),
                      ),
                      ButtonSegment<MainAxisAlignment?>(
                        value: MainAxisAlignment.center,
                        label: Text('Center'),
                      ),
                      ButtonSegment<MainAxisAlignment?>(
                        value: MainAxisAlignment.spaceEvenly,
                        label: Text('Space Evenly'),
                      ),
                      ButtonSegment<MainAxisAlignment?>(
                        value: MainAxisAlignment.spaceBetween,
                        label: Text('Space Between'),
                      ),
                      ButtonSegment<MainAxisAlignment?>(
                        value: MainAxisAlignment.spaceAround,
                        label: Text('Space Around'),
                      ),
                    ],
                    selected: <MainAxisAlignment?>{alignment},
                    onSelectionChanged: (Set<MainAxisAlignment?> newSelection) {
                      setState(() {
                        alignment = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: Text(showLeading ? 'Hide Leading' : 'Show Leading'),
                    value: showLeading,
                    onChanged: (bool value) {
                      setState(() {
                        showLeading = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text(
                      showTrailing ? 'Hide Trailing' : 'Show Trailing',
                    ),
                    value: showTrailing,
                    onChanged: (bool value) {
                      setState(() {
                        showTrailing = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
