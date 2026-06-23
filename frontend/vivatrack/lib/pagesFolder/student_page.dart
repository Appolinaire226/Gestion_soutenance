import 'package:flutter/material.dart';
import 'package:vivatrack/pagesFolder/firebase_auth.dart';
import 'package:vivatrack/services/sudo_rapport.dart';
import 'package:vivatrack/services/sudo_session.dart';
import 'package:vivatrack/services/sudo_programme.dart';
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
    const StudentProgrammesPage(),
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
                        icon: Icons.list,
                        label: 'Programmes',
                        index: 2,
                      ),
                      _buildNavigationItem(
                        icon: Icons.school,
                        label: 'Mes notes',
                        index: 3,
                      ),
                      const Divider(),
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
                      icon: Icon(Icons.list_outlined),
                      selectedIcon: Icon(Icons.list),
                      label: Text('Programmes'),
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
        final navigator = Navigator.of(context);
        await SudoAuthService().signOut();
        navigator.popUntil((route) => route.isFirst);
      },
    );
  }
}

class StudentProgrammesPage extends StatefulWidget {
  const StudentProgrammesPage({super.key});

  @override
  State<StudentProgrammesPage> createState() => _StudentProgrammesPageState();
}

class _StudentProgrammesPageState extends State<StudentProgrammesPage> {
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
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
                          const SizedBox(height: 10),
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
                    _buildMenuCard(
                      context,
                      'Déposer un rapport',
                      Icons.upload_file,
                      Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReportSubmissionPage(),
                          ),
                        );
                      },
                    ),
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
    Color color, {
    void Function()? onTap,
  }) {
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
              radius: 30,
              backgroundColor: color.withAlpha((0.2 * 255).round()),
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

class ReportSubmissionPage extends StatefulWidget {
  const ReportSubmissionPage({super.key});

  @override
  State<ReportSubmissionPage> createState() => _ReportSubmissionPageState();
}

class _ReportSubmissionPageState extends State<ReportSubmissionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _resumeController = TextEditingController();
  final _fichierUrlController = TextEditingController();
  final _matriculeController = TextEditingController();

  final _rapportService = SudoRapportService();
  final _sessionService = SudoSessionService();

  bool _isSubmitting = false;
  bool _isLoadingSession = false;
  int? _activeSessionId;
  int? _selectedSessionId;
  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoadingSession = true;
    });
    try {
      final sessions = await _sessionService.getAllSessions();
      _sessions = sessions.cast<Map<String, dynamic>>();
      _activeSessionId = _findActiveSessionId(_sessions);
      _selectedSessionId = _activeSessionId;
      debugPrint('[StudentPage] Sessions chargées : $_sessions');
      debugPrint(
        '[StudentPage] Session active pré-sélectionnée : id_session=$_activeSessionId',
      );
    } catch (e) {
      debugPrint('[StudentPage] Échec chargement sessions : ${e.toString()}');
      _sessions = [];
      _activeSessionId = null;
      _selectedSessionId = null;
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSession = false;
        });
      }
    }
  }

  int? _findActiveSessionId(List<Map<String, dynamic>> sessions) {
    final now = DateTime.now();
    for (final session in sessions) {
      final dateDebut = session['date_debut'] as String?;
      final dateFin = session['date_fin'] as String?;
      final statut = session['statut'] as String?;

      debugPrint(
        '[StudentPage] Vérification session : id_session=${session['id_session']}, date_debut=$dateDebut, date_fin=$dateFin, statut=$statut',
      );

      if (dateDebut == null || dateFin == null) continue;

      final debut = DateTime.tryParse(dateDebut);
      final fin = DateTime.tryParse(dateFin);
      if (debut == null || fin == null) continue;

      final isActiveByDate = !now.isBefore(debut) && !now.isAfter(fin);
      final isActiveByStatus =
          statut != null && statut.toLowerCase() == 'en_cours';

      if (isActiveByDate || isActiveByStatus) {
        return session['id_session'] as int?;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _titreController.dispose();
    _resumeController.dispose();
    _fichierUrlController.dispose();
    _matriculeController.dispose();
    super.dispose();
  }

  // ===== SOUMISSION DU RAPPORT =====
  // Étapes :
  // 1. Récupérer le matricule et la session active
  // 2. Envoyer le POST avec titre, matricule, id_session, resume, fichier_url
  // 3. Le backend cherche l'id_etudiant via le matricule
  Future<void> _submitRapport() async {
    if (!_formKey.currentState!.validate()) return;

    final matricule = _matriculeController.text.trim();

    if (matricule.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir votre matricule.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final selectedSessionId = _selectedSessionId ?? _activeSessionId;
      debugPrint(
        '[StudentPage] Session sélectionnée pour envoi : id_session=$selectedSessionId',
      );

      if (selectedSessionId == null) {
        debugPrint('[StudentPage] Aucune session sélectionnée');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Veuillez sélectionner une session avant d’envoyer le rapport.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ===== PAYLOAD DU POST =====
      // Envoi : titre, matricule, id_session, resume, fichier_url
      // Le backend se charge de chercher id_etudiant via matricule
      final requestBody = {
        'titre': _titreController.text.trim(),
        'matricule': matricule, // Backend cherche id_etudiant via ça
        'id_session': selectedSessionId,
        'resume': _resumeController.text.trim().isEmpty
            ? null
            : _resumeController.text.trim(),
        'fichier_url': _fichierUrlController.text.trim().isEmpty
            ? null
            : _fichierUrlController.text.trim(),
      };
      debugPrint('[StudentPage] POST rapport payload: $requestBody');
      final result = await _rapportService.createRapport(requestBody);

      debugPrint(
        '[StudentPage] Rapport envoyé avec succès, id_rapport=${result['id_rapport']}, id_session=$selectedSessionId',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rapport déposé avec succès.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('[StudentPage] Échec du POST rapport, erreur=${e.toString()}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi : ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Déposer un rapport'),
        backgroundColor: sudocolor,
        foregroundColor: Colors.black,
      ),
      body: ResponsivePageContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Envoyer un rapport',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _titreController,
                  decoration: InputDecoration(
                    labelText: 'Titre du rapport',
                    prefixIcon: const Icon(Icons.title, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le titre est requis.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _matriculeController,
                  decoration: InputDecoration(
                    labelText: 'Matricule de l’étudiant',
                    prefixIcon: const Icon(Icons.badge, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le matricule est requis.';
                    }
                    if (value.trim().length < 1) {
                      return 'Matricule trop court.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                if (_isLoadingSession)
                  const Text(
                    'Chargement des sessions...',
                    style: TextStyle(color: Colors.black54),
                  )
                else if (_sessions.isEmpty)
                  const Text(
                    'Aucune session disponible pour le moment.',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  DropdownButtonFormField<int>(
                    value: _selectedSessionId,
                    decoration: InputDecoration(
                      labelText: 'Session disponible',
                      prefixIcon: const Icon(Icons.event, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: _sessions.map((session) {
                      final id = session['id_session'] as int;
                      final label = session['libelle'] as String?;
                      final dateDebut = session['date_debut'] as String?;
                      final dateFin = session['date_fin'] as String?;
                      return DropdownMenuItem(
                        value: id,
                        child: Text(
                          '${label ?? 'Session #$id'} ${dateDebut != null && dateFin != null ? '($dateDebut → $dateFin)' : ''}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedSessionId = value),
                    validator: (value) =>
                        value == null ? 'Veuillez choisir une session.' : null,
                  ),
                const SizedBox(height: 10),
                if (_selectedSessionId != null)
                  Text(
                    'Session sélectionnée : #$_selectedSessionId',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _resumeController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Résumé (optionnel)',
                    hintText: 'Résumé du rapport',
                    prefixIcon: const Icon(
                      Icons.description,
                      color: Colors.blue,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fichierUrlController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: 'URL du fichier (optionnel)',
                    hintText: 'https://... ou lien de téléchargement',
                    prefixIcon: const Icon(Icons.link, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRapport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sudocolor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Envoyer le rapport',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
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
                      // Optionnel: revenir à l'écran de login
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
