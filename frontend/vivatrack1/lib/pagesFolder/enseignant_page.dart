import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:vivatrack/pagesFolder/firebase_auth.dart';
import 'package:vivatrack/services/sudo_disponibilite.dart';
import 'package:vivatrack/services/sudo_programme.dart';
import 'package:vivatrack/services/sudo_session.dart';
import '../widgets/responsive_container.dart';
import 'home_page.dart';

class EnseignantDashboard extends StatefulWidget {
  const EnseignantDashboard({super.key});

  @override
  State<EnseignantDashboard> createState() => _EnseignantDashboardState();
}

class _EnseignantDashboardState extends State<EnseignantDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const EnseignantHomeView(),
    const EnseignantDisponibilitesPage(),
    const EnseignantProgrammePage(),
    const Center(child: Text('Paramètres')),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Espace Enseignant'),
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
                          'Enseignant',
                          style: TextStyle(color: Colors.black),
                        ),
                        accountEmail: Text(
                          SudoAuthService().currentEmail ?? 'Email',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      _buildNavigationItem(
                        icon: Icons.home,
                        label: 'Accueil',
                        index: 0,
                      ),
                      _buildNavigationItem(
                        icon: Icons.calendar_month,
                        label: 'Disponibilités',
                        index: 1,
                      ),
                      _buildNavigationItem(
                        icon: Icons.group,
                        label: 'Jurys',
                        index: 2,
                      ),
                      const Divider(),
                      _buildLogoutItem(),
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
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Accueil'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month),
                      label: Text('Disponibilités'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.schedule_outlined),
                      selectedIcon: Icon(Icons.schedule),
                      label: Text('Programme'),
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

class EnseignantHomeView extends StatefulWidget {
  const EnseignantHomeView({super.key});

  @override
  State<EnseignantHomeView> createState() => _EnseignantHomeViewState();
}

class _EnseignantHomeViewState extends State<EnseignantHomeView> {
  final _sessionService = SudoSessionService();
  final _dispoService = SudoDisponibiliteService();

  bool _isLoading = true;
  int _totalSessions = 0;
  int _activeSessions = 0;
  int _myDisponibilites = 0;

  int? get _enseignantId => SudoAuthService().currentIdEnseignant;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
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

      final disponibilites = _enseignantId != null
          ? await _dispoService.getDisponibilites(_enseignantId!)
          : <dynamic>[];

      if (!mounted) return;
      setState(() {
        _totalSessions = sessions.length;
        _activeSessions = activeSessions;
        _myDisponibilites = disponibilites.length;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        '[EnseignantHomeView] Erreur chargement stats : ${e.toString()}',
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenue dans l\'espace enseignant',
            style: TextStyle(
              fontSize: 20,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Renseignez vos disponibilités et consultez le programme des soutenances.',
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStatCard(
                  label: 'Sessions totales',
                  value: '$_totalSessions',
                  icon: Icons.event_note,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  label: 'Sessions actives',
                  value: '$_activeSessions',
                  icon: Icons.event_available,
                  color: Colors.green,
                ),
                _buildStatCard(
                  label: 'Mes disponibilités',
                  value: '$_myDisponibilites',
                  icon: Icons.calendar_today,
                  color: Colors.orange,
                ),
              ],
            ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prêt pour la journée',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Sessions disponibles : $_totalSessions'),
                  Text('Sessions actives : $_activeSessions'),
                  Text('Disponibilités enregistrées : $_myDisponibilites'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: 260,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EnseignantDisponibilitesPage extends StatefulWidget {
  const EnseignantDisponibilitesPage({super.key});

  @override
  State<EnseignantDisponibilitesPage> createState() =>
      _EnseignantDisponibilitesPageState();
}

class _EnseignantDisponibilitesPageState
    extends State<EnseignantDisponibilitesPage> {
  final _formKey = GlobalKey<FormState>();
  final _sessionService = SudoSessionService();
  final _dispoService = SudoDisponibiliteService();
  final _enseignantIdController = TextEditingController();
  int? _selectedSessionId;
  DateTime? _debut;
  DateTime? _fin;
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _disponibilites = [];

  int? get _enseignantId => SudoAuthService().currentIdEnseignant;

  @override
  void initState() {
    super.initState();
    _loadSessions();
    // Si l'enseignant est déjà connecté, charger aussi ses disponibilités.
    if (_enseignantId != null) {
      _loadDisponibilites();
    }
  }

  @override
  void dispose() {
    _enseignantIdController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    try {
      final sessions = await _sessionService.getAllSessions();
      final loadedSessions = sessions.cast<Map<String, dynamic>>();
      final activeSessionId = _findActiveSessionId(loadedSessions);
      setState(() {
        _sessions = loadedSessions;
        _selectedSessionId = activeSessionId ?? _selectedSessionId;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int? _findActiveSessionId(List<Map<String, dynamic>> sessions) {
    final now = DateTime.now();
    for (final session in sessions) {
      final dateDebut = session['date_debut'] as String?;
      final dateFin = session['date_fin'] as String?;
      final statut = session['statut'] as String?;

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

  Future<void> _loadDisponibilites() async {
    final enseignantId =
        _enseignantId ?? int.tryParse(_enseignantIdController.text.trim());
    if (enseignantId == null) return;
    try {
      final avail = await _dispoService.getDisponibilites(enseignantId);
      setState(() {
        _disponibilites = avail.cast<Map<String, dynamic>>();
      });
    } catch (_) {
      setState(() {
        _disponibilites = [];
      });
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;

    final value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isStart) {
        _debut = value;
      } else {
        _fin = value;
      }
    });
  }

  Future<void> _submitDisponibilite() async {
    if (!_formKey.currentState!.validate()) return;
    final enseignantId =
        _enseignantId ?? int.tryParse(_enseignantIdController.text.trim());
    if (enseignantId == null) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('ID enseignant requis.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedSessionId == null || _debut == null || _fin == null) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Veuillez compléter tous les champs.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await _dispoService.ajouterDisponibilite(enseignantId, {
        'id_session': _selectedSessionId,
        'date_debut': _debut!.toIso8601String(),
        'date_fin': _fin!.toIso8601String(),
      });
      await _loadDisponibilites();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disponibilité enregistrée.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enseignantId = _enseignantId;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mes disponibilités',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (enseignantId == null) ...[
            TextFormField(
              controller: _enseignantIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'ID enseignant',
                prefixIcon: const Icon(Icons.badge, color: Colors.blue),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (_) => _loadDisponibilites(),
            ),
            const SizedBox(height: 16),
          ],
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: _selectedSessionId,
                    items: _sessions.map((session) {
                      final id = session['id_session'] as int;
                      final label = session['libelle'] ?? 'Session $id';
                      return DropdownMenuItem(
                        value: id,
                        child: Text('$label (#$id)'),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Session',
                      prefixIcon: const Icon(Icons.event, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => _selectedSessionId = value),
                    validator: (value) =>
                        value == null ? 'Session requise' : null,
                  ),
                  const SizedBox(height: 16),
                  _DateTimeField(
                    label: 'Début',
                    value: _debut,
                    onTap: () => _pickDateTime(isStart: true),
                  ),
                  const SizedBox(height: 16),
                  _DateTimeField(
                    label: 'Fin',
                    value: _fin,
                    onTap: () => _pickDateTime(isStart: false),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitDisponibilite,
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
                        : const Text('Enregistrer la disponibilité'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Disponibilités enregistrées',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_disponibilites.isEmpty)
              const Text('Aucune disponibilité trouvée.')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _disponibilites.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final dispo = _disponibilites[index];
                  return ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      dispo['id_session'] != null
                          ? 'Session #${dispo['id_session']}'
                          : 'Disponibilité',
                    ),
                    subtitle: Text(
                      'De ${dispo['date_debut'] ?? '-'} à ${dispo['date_fin'] ?? '-'}',
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}

class EnseignantProgrammePage extends StatefulWidget {
  const EnseignantProgrammePage({super.key});

  @override
  State<EnseignantProgrammePage> createState() =>
      _EnseignantProgrammePageState();
}

class _EnseignantProgrammePageState extends State<EnseignantProgrammePage> {
  final _sessionService = SudoSessionService();
  final _programmeService = SudoProgrammeService();
  List<Map<String, dynamic>> _sessions = [];
  int? _selectedSessionId;
  List<Map<String, dynamic>> _programmes = [];
  bool _isLoadingSessions = true;
  bool _isLoadingProgrammes = false;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final sessions = await _sessionService.getAllSessions();
      setState(() {
        _sessions = sessions.cast<Map<String, dynamic>>();
        _isLoadingSessions = false;
      });
    } catch (_) {
      setState(() {
        _sessions = [];
        _isLoadingSessions = false;
      });
    }
  }

  Future<void> _loadProgrammes() async {
    if (_selectedSessionId == null) return;
    setState(() => _isLoadingProgrammes = true);
    try {
      final programmes = await _programmeService.getProgrammesBySession(
        _selectedSessionId!,
      );
      setState(() {
        _programmes = programmes.cast<Map<String, dynamic>>();
      });
    } catch (_) {
      setState(() {
        _programmes = [];
      });
    } finally {
      setState(() => _isLoadingProgrammes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Programme des soutenances',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_isLoadingSessions)
            const Center(child: CircularProgressIndicator())
          else ...[
            DropdownButtonFormField<int>(
              initialValue: _selectedSessionId,
              items: _sessions.map((session) {
                final id = session['id_session'] as int;
                final label = session['libelle'] ?? 'Session $id';
                return DropdownMenuItem(
                  value: id,
                  child: Text('$label (#$id)'),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Choisir une session',
                prefixIcon: const Icon(Icons.event, color: Colors.blue),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedSessionId = value;
                });
                _loadProgrammes();
              },
            ),
            const SizedBox(height: 20),
            if (_isLoadingProgrammes)
              const Center(child: CircularProgressIndicator())
            else if (_programmes.isEmpty)
              const Text(
                'Aucun programme disponible pour la session sélectionnée.',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const Divider(),
                itemCount: _programmes.length,
                itemBuilder: (context, index) {
                  final programme = _programmes[index];
                  return ListTile(
                    leading: const Icon(Icons.event_note),
                    title: Text(
                      'Programme #${programme['id_programme'] ?? '-'}',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date/heure : ${programme['date_heure'] ?? '-'}'),
                        Text('Salle : ${programme['id_salle'] ?? '-'}'),
                        Text('Rapport : ${programme['id_rapport'] ?? '-'}'),
                        Text('Statut : ${programme['statut'] ?? '-'}'),
                      ],
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateTimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.access_time, color: Colors.blue),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          controller: TextEditingController(
            text: value == null
                ? ''
                : value!.toLocal().toString().substring(0, 16),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Ce champ est requis.' : null,
        ),
      ),
    );
  }
}
