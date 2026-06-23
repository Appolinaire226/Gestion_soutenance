import 'package:flutter/material.dart';
import 'package:vivatrack/pagesFolder/firebase_auth.dart';
import 'package:vivatrack/services/sudo_etudiant.dart';
import 'package:vivatrack/services/sudo_enseignant.dart';
import 'package:vivatrack/services/sudo_programme.dart';
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
    const AdminProgrammesView(),
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
                        icon: Icons.list,
                        label: 'Programmes générés',
                        index: 1,
                      ),
                      _buildNavigationItem(
                        icon: Icons.people,
                        label: 'Gestion Comptes',
                        index: 2,
                      ),
                      _buildNavigationItem(
                        icon: Icons.gavel,
                        label: 'Valider Un Programme',
                        index: 3,
                      ),
                      _buildNavigationItem(
                        icon: Icons.settings,
                        label: 'Paramètres',
                        index: 4,
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
                      icon: Icon(Icons.list_outlined),
                      selectedIcon: Icon(Icons.list),
                      label: Text('Programmes'),
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
  int _activeSessionCount = 0;

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

      if (!mounted) return;
      setState(() {
        _etudiantCount = etudiants.length;
        _enseignantCount = enseignants.length;
        _rapportCount = rapports.length;
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques Générales',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Vue d’ensemble des soutenances, des rapports et des utilisateurs.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            if (_isLoadingStats)
              const Center(child: CircularProgressIndicator())
            else ...[
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  LayoutBuilder(
                    builder: (context, child) {
                      final sw = MediaQuery.of(context).size.width;
                      final w = sw >= 900 ? 280.0 : sw * 0.9;
                      return SizedBox(
                        width: w,
                        child: _buildStatCard(
                          'Étudiants',
                          '$_etudiantCount',
                          Icons.school,
                          Colors.blue,
                        ),
                      );
                    },
                  ),
                  LayoutBuilder(
                    builder: (context, child) {
                      final sw = MediaQuery.of(context).size.width;
                      final w = sw >= 900 ? 280.0 : sw * 0.9;
                      return SizedBox(
                        width: w,
                        child: _buildStatCard(
                          'Enseignants',
                          '$_enseignantCount',
                          Icons.person,
                          Colors.green,
                        ),
                      );
                    },
                  ),
                  LayoutBuilder(
                    builder: (context, child) {
                      final sw = MediaQuery.of(context).size.width;
                      final w = sw >= 900 ? 280.0 : sw * 0.9;
                      return SizedBox(
                        width: w,
                        child: _buildStatCard(
                          'Rapports',
                          '$_rapportCount',
                          Icons.gavel,
                          Colors.orange,
                        ),
                      );
                    },
                  ),
                  LayoutBuilder(
                    builder: (context, child) {
                      final sw = MediaQuery.of(context).size.width;
                      final w = sw >= 900 ? 280.0 : sw * 0.9;
                      return SizedBox(
                        width: w,
                        child: _buildStatCard(
                          'Sessions actives',
                          '$_activeSessionCount',
                          Icons.event_available,
                          Colors.purple,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Actions rapides',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  LayoutBuilder(
                    builder: (context, child) {
                      final sw = MediaQuery.of(context).size.width;
                      final w = sw >= 900 ? 280.0 : sw * 0.9;
                      return SizedBox(
                        width: w,
                        child: _buildActionCard(
                          'Générer un programme',
                          Icons.calendar_month_outlined,
                          Colors.purple,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const GenerateProgrammePage(),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  LayoutBuilder(
                    builder: (context, child) {
                      final sw = MediaQuery.of(context).size.width;
                      final w = sw >= 900 ? 280.0 : sw * 0.9;
                      return SizedBox(
                        width: w,
                        child: _buildActionCard(
                          'Ajouter une session',
                          Icons.post_add,
                          Colors.teal,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CreateSessionPage(),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: color.withAlpha((0.2 * 255).round()),
            child: Icon(icon, size: 40, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: color.withAlpha((0.2 * 255).round()),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
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

class AdminProgrammesView extends StatefulWidget {
  const AdminProgrammesView({super.key});

  @override
  State<AdminProgrammesView> createState() => _AdminProgrammesViewState();
}

class _AdminProgrammesViewState extends State<AdminProgrammesView> {
  final _programmeService = SudoProgrammeService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _programmes = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProgrammes();
  }

  Future<void> _loadProgrammes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final programmes = await _programmeService.getAllProgrammes();
      if (!mounted) return;
      setState(() {
        _programmes = programmes.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Impossible de charger les programmes : ${e.toString()}';
        _programmes = [];
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Programmes générés',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Liste de tous les programmes générés.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              )
            else if (_programmes.isEmpty)
              const Center(
                child: Text('Aucun programme généré n’est disponible.'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemCount: _programmes.length,
                itemBuilder: (context, index) {
                  final programme = _programmes[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Programme #${programme['id_programme'] ?? '-'}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Session : ${programme['id_session'] ?? '-'}'),
                          Text('Rapport : ${programme['id_rapport'] ?? '-'}'),
                          Text('Salle : ${programme['id_salle'] ?? '-'}'),
                          Text(
                            'Date / heure : ${programme['date_heure'] ?? '-'}',
                          ),
                          Text(
                            'Durée (minutes) : ${programme['duree_minutes'] ?? '-'}',
                          ),
                          Text('Statut : ${programme['statut'] ?? '-'}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class GenerateProgrammePage extends StatefulWidget {
  const GenerateProgrammePage({super.key});

  @override
  State<GenerateProgrammePage> createState() => _GenerateProgrammePageState();
}

class _GenerateProgrammePageState extends State<GenerateProgrammePage> {
  final _sessionService = SudoSessionService();
  final _programmeService = SudoProgrammeService();

  bool _isLoading = true;
  bool _isGenerating = false;
  List<Map<String, dynamic>> _sessions = [];
  int? _selectedSessionId;
  String? _responseMessage;
  String? _responseDetails;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    try {
      final sessions = await _sessionService.getAllSessions();
      if (!mounted) return;
      setState(() {
        _sessions = sessions.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('[GenerateProgrammePage] load sessions failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur chargement sessions : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      final shouldUpdate = mounted;
      if (shouldUpdate) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generateProgramme() async {
    if (_selectedSessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une session.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _responseMessage = null;
      _responseDetails = null;
    });

    try {
      final result = await _programmeService.generateProgramme(
        _selectedSessionId!,
      );
      if (!mounted) return;
      setState(() {
        _responseMessage = result['message'] as String? ?? 'Programme généré.';
        _responseDetails = result.containsKey('nb_planifiees')
            ? 'Séances planifiées: ${result['nb_planifiees']}'
            : null;
        if (result.containsKey('non_planifiees')) {
          final nonPlanifiees = result['non_planifiees'];
          _responseDetails =
              '${_responseDetails ?? ''}\nNon planifiées: $nonPlanifiees';
        }
      });
    } catch (e) {
      debugPrint('[GenerateProgrammePage] generate failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur génération programme : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      final shouldUpdate = mounted;
      if (shouldUpdate) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générer un programme'),
        backgroundColor: sudocolor,
        foregroundColor: Colors.black,
      ),
      body: ResponsivePageContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Génération du programme de soutenance',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                DropdownButtonFormField<int>(
                  initialValue: _selectedSessionId,
                  decoration: InputDecoration(
                    labelText: 'Session',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  items: _sessions.map((session) {
                    final id = session['id_session'] as int?;
                    final label = session['libelle'] as String? ?? 'Session';
                    final annee = session['annee_academique'] as String? ?? '';
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(
                        '$label ${annee.isNotEmpty ? '($annee)' : ''}',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedSessionId = value);
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isGenerating ? null : _generateProgramme,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sudocolor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Générer le programme'),
                ),
                const SizedBox(height: 24),
                if (_responseMessage != null) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _responseMessage!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_responseDetails != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _responseDetails!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
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
                child: FractionallySizedBox(
                  widthFactor: 0.6,
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
