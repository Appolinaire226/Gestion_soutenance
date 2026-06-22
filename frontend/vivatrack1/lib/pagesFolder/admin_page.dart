import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vivatrack/pagesFolder/firebase_auth.dart';
import 'package:vivatrack/services/sudo_etudiant.dart';
import 'package:vivatrack/services/sudo_enseignant.dart';
import 'package:vivatrack/services/sudo_rapport.dart';
import 'package:vivatrack/services/sudo_session.dart';
import '../widgets/responsive_container.dart';
import 'home_page.dart';

//la resposivite
class NavigationItem {
  final String title;
  final IconData icon;
  final Widget page;

  NavigationItem({required this.title, required this.icon, required this.page});
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminHomeView(),
    const Center(child: Text('Gestion des Utilisateurs (Étudiants / Jurys)')),
    const Center(child: Text('Configuration des Soutenances')),
    const AdminSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Panneau d\'Administration'),
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
                            Icons.admin_panel_settings,
                            size: 50,
                            color: Colors.blue,
                          ),
                        ),
                        accountName: const Text(
                          'Administrateur',
                          style: TextStyle(color: Colors.black),
                        ),
                        accountEmail: Text(
                          SudoAuthService().currentEmail ??
                              'admin@vivatrack.com',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      _buildNavigationItem(
                        icon: Icons.analytics,
                        label: 'Dashboard',
                        index: 0,
                      ),
                      _buildNavigationItem(
                        icon: Icons.people,
                        label: 'Gestion Comptes',
                        index: 1,
                      ),
                      _buildNavigationItem(
                        icon: Icons.gavel,
                        label: 'Valider Un Programme',
                        index: 2,
                      ),
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
                      icon: Icon(Icons.analytics_outlined),
                      selectedIcon: Icon(Icons.analytics),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_outline),
                      selectedIcon: Icon(Icons.people),
                      label: Text('Gestion Comptes'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.gavel_outlined),
                      selectedIcon: Icon(Icons.gavel),
                      label: Text('Valider Un Programme'),
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
        final navigator = Navigator.of(context);
        await SudoAuthService().signOut();
        navigator.popUntil((route) => route.isFirst);
      },
    );
  }
}

// Vue principale de l'accueil Admin avec KPI (Indicateurs clés)
class AdminHomeView extends StatefulWidget {
  const AdminHomeView({super.key});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  final _etudiantService = SudoEtudiantService();
  final _enseignantService = SudoEnseignantService();
  final _rapportService = SudoRapportService();
  final _sessionService = SudoSessionService();

  bool _isLoadingStats = true;
  int _etudiantCount = 0;
  int _enseignantCount = 0;
  int _rapportCount = 0;
  int _sessionCount = 0;
  int _activeSessionCount = 0;
  int _rapportDeposeCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final etudiants = await _etudiantService.getAllEtudiants();
      final enseignants = await _enseignantService.getAllEnseignants();
      final rapports = await _rapportService.getAllRapports();
      final sessions = await _sessionService.getAllSessions();

      final now = DateTime.now();
      final activeSessions = sessions.cast<Map<String, dynamic>>().where((
        session,
      ) {
        final dateDebut = session['date_debut'] as String?;
        final dateFin = session['date_fin'] as String?;
        final statut = session['statut'] as String?;
        if (dateDebut == null || dateFin == null) return false;
        final debut = DateTime.tryParse(dateDebut);
        final fin = DateTime.tryParse(dateFin);
        if (debut == null || fin == null) return false;
        final isActiveByDate = !now.isBefore(debut) && !now.isAfter(fin);
        final isActiveByStatus =
            statut != null && statut.toLowerCase() == 'en_cours';
        return isActiveByDate || isActiveByStatus;
      }).length;

      final deposedCount = rapports.cast<Map<String, dynamic>>().where((
        rapport,
      ) {
        final statut = rapport['statut'] as String?;
        return statut != null && statut.toLowerCase() == 'déposé';
      }).length;

      if (!mounted) return;
      setState(() {
        _etudiantCount = etudiants.length;
        _enseignantCount = enseignants.length;
        _rapportCount = rapports.length;
        _rapportDeposeCount = deposedCount;
        _sessionCount = sessions.length;
        _activeSessionCount = activeSessions;
        _isLoadingStats = false;
      });
    } catch (e) {
      debugPrint(
        '[AdminHomeView] Échec chargement statistiques : ${e.toString()}',
      );
      if (!mounted) return;
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques Générales',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_isLoadingStats)
              const Center(child: CircularProgressIndicator())
            else ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1100
                      ? 4
                      : constraints.maxWidth >= 700
                      ? 2
                      : 1;
                  final cardWidth =
                      (constraints.maxWidth - (columns - 1) * 12) / columns;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: _buildStatCard(
                          'Étudiants',
                          '$_etudiantCount',
                          Icons.school,
                          Colors.blue,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildStatCard(
                          'Enseignants',
                          '$_enseignantCount',
                          Icons.person,
                          Colors.green,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildStatCard(
                          'Rapports',
                          '$_rapportCount',
                          Icons.gavel,
                          Colors.orange,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildStatCard(
                          'Sessions actives',
                          '$_activeSessionCount',
                          Icons.event,
                          Colors.purple,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final detailCardWidth = constraints.maxWidth >= 1100
                      ? (constraints.maxWidth - 32) / 3
                      : double.infinity;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: detailCardWidth,
                        child: _buildDetailCard(
                          'Total de sessions',
                          '$_sessionCount',
                          Icons.event_note,
                          Colors.indigo,
                        ),
                      ),
                      SizedBox(
                        width: detailCardWidth,
                        child: _buildDetailCard(
                          'Rapports déposés',
                          '$_rapportDeposeCount',
                          Icons.description,
                          Colors.teal,
                        ),
                      ),
                      SizedBox(
                        width: detailCardWidth,
                        child: _buildDetailCard(
                          'Sessions actives',
                          '$_activeSessionCount',
                          Icons.event_available,
                          Colors.deepPurple,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'Actions Rapides',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.settings_backup_restore,
                    color: Colors.green,
                  ),
                  title: const Text('Génerer un programme'),
                  subtitle: const Text('SudoAdminCollection'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Naviguer vers la gestion de la liste blanche
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.post_add, color: Colors.blue),
                  title: const Text('Planifier une nouvelle session'),
                  subtitle: const Text('Assignation des jurys et salles'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateSessionPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 18),
            Text(
              value,
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(14),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on Color {
  Color? get shade700 => null;
}

class CreateSessionPage extends StatefulWidget {
  const CreateSessionPage({super.key});

  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  final _formKey = GlobalKey<FormState>();
  final _libelleController = TextEditingController();
  final _anneeController = TextEditingController();
  DateTime? _dateDebut;
  DateTime? _dateFin;
  bool _isSubmitting = false;
  final _sessionService = SudoSessionService();

  @override
  void dispose() {
    _libelleController.dispose();
    _anneeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null) return;
    setState(() {
      if (isStart) {
        _dateDebut = date;
      } else {
        _dateFin = date;
      }
    });
  }

  Future<void> _submitSession() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateDebut == null || _dateFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez choisir les dates de début et de fin.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final data = {
        'libelle': _libelleController.text.trim(),
        'annee_academique': _anneeController.text.trim(),
        'date_debut': _dateDebut!.toIso8601String().split('T').first,
        'date_fin': _dateFin!.toIso8601String().split('T').first,
      };
      final session = await _sessionService.createSession(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Session créée : ${session['libelle']} (#${session['id_session']})',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, session);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur création session : ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une session'),
        backgroundColor: sudocolor,
        foregroundColor: Colors.black,
      ),
      body: ResponsivePageContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Nouvelle session de soutenance',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _libelleController,
                  decoration: InputDecoration(
                    labelText: 'Libellé de la session',
                    prefixIcon: const Icon(Icons.event, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le libellé est requis.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _anneeController,
                  decoration: InputDecoration(
                    labelText: 'Année académique',
                    hintText: '2025/2026',
                    prefixIcon: const Icon(Icons.school, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "L'année académique est requise.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _pickDate(isStart: true),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date de début',
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.blue,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      _dateDebut == null
                          ? 'Sélectionner la date de début'
                          : _dateDebut!
                                .toLocal()
                                .toIso8601String()
                                .split('T')
                                .first,
                      style: TextStyle(
                        color: _dateDebut == null
                            ? Colors.black54
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _pickDate(isStart: false),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date de fin',
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.blue,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      _dateFin == null
                          ? 'Sélectionner la date de fin'
                          : _dateFin!
                                .toLocal()
                                .toIso8601String()
                                .split('T')
                                .first,
                      style: TextStyle(
                        color: _dateFin == null ? Colors.black54 : Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sudocolor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Créer la session'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Page Paramètres pour l'administrateur avec bouton Déconnexion en bas
class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

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
              const Expanded(
                child: Center(
                  child: Text('Options de configuration administrateur'),
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
                      final navigator = Navigator.of(context);
                      await SudoAuthService().signOut();
                      navigator.popUntil((route) => route.isFirst);
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

/*class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ADMIN DASHBOARD')),
      body: const Center(
        child: Text(
          'Bienvenue sur la page d\'administration',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}*/
