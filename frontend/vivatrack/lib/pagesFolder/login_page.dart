import 'package:flutter/material.dart';
import 'package:vivatrack/pagesFolder/firebase_auth.dart';
import '../widgets/responsive_container.dart';
import 'home_page.dart';
import 'redirect_page.dart';
import 'profile_completion_page.dart';
//import 'home_page.dart';

class LoginPage extends StatefulWidget {
  final String role; // Attend 'etudiant' ou 'admin'

  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _isObscure = true; // Pour masquer le mot de passe
  bool _forLogin = true; // booleen de swap entre connexion et inscription

  bool get _allowsRegister {
    final roleLower = widget.role.toLowerCase();
    return roleLower == 'etudiant';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _forLogin
              ? 'CONNEXION ${widget.role.toUpperCase()}'
              : 'INSCRIPTION ${widget.role.toUpperCase()}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: sudocolor,
      ),
      body: ResponsivePageContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    widget.role == 'admin'
                        ? Icons.admin_panel_settings
                        : Icons.school,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    _forLogin
                        ? 'Se connecter en tant qu\'${widget.role}'
                        : 'S\'inscrire en tant qu\'${widget.role}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Champ de l'identifiant
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        widget.role == 'admin' ? Icons.email : Icons.school,
                        color: Colors.blue,
                      ),
                      labelText: widget.role == 'admin' ? 'E-mail' : 'E-mail',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre E-mail.';
                      }
                      if (widget.role == 'admin' || widget.role == 'etudiant') {
                        final veriferMail = RegExp(
                          r'^[a-z0-9_\-\.]+@[a-z0-9\-]+\.[a-z]{2,}$',
                        );
                        if (!veriferMail.hasMatch(value)) {
                          return 'Veuillez entrer un e-mail valide.';
                        }
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Champ du mot de passe
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe.';
                      }
                      if (value.length < 4) {
                        return 'Le mot de passe doit contenir au moins 6 caractères.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  //section inscription
                  if (_forLogin == false)
                    TextFormField(
                      controller: _passwordConfirmController,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre mot de passe.';
                        }
                        if (value != _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas.';
                        }
                        if (value.length < 4) {
                          return 'Le mot de passe doit contenir au moins 6 caractères.';
                        }
                        return null;
                      },
                    ),

                  const SizedBox(height: 40),

                  // Bouton de connexion
                  ElevatedButton(
                    onPressed: () async {
                      //code de validation de formulaire
                      if (_formKey.currentState!.validate()) {
                        try {
                          if (_forLogin) {
                            // Connexion
                            await SudoAuthService().loginInWithEmailAndPassword(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );
                            if (!mounted) return;
                            final navigator = Navigator.of(context);
                            navigator.pushReplacement(
                              MaterialPageRoute(
                                builder: (context) =>
                                    RedirectPage(role: widget.role),
                              ),
                            );
                          } else {
                            // Inscription: créer le compte (sans envoi de vérification)
                            await SudoAuthService()
                                .createUserWithEmailAndPassword(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                  widget.role,
                                );
                            // Afficher un message de succès
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Compte créé !'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            if (!mounted) return;
                            final navigator = Navigator.of(context);
                            navigator.pushReplacement(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProfileCompletionPage(role: widget.role),
                              ),
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Erreur : ${e.toString()}',
                                style: const TextStyle(color: Colors.red),
                              ),
                              behavior: SnackBarBehavior.floating,
                              showCloseIcon: true,
                            ),
                          );
                          return;
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sudocolor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                    ),
                    child: Text(
                      _forLogin ? 'Se connecter' : "S'inscrire",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // pour recuperer le mot de passe oublie
                  SizedBox(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          // _isLoginMode = !_isLoginMode;
                        });
                      },
                      child: Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  if (_allowsRegister) ...[
                    const SizedBox(height: 20),

                    // Bouton d'inscription
                    TextButton(
                      onPressed: () {
                        _emailController.text = "";
                        _passwordController.text = "";
                        _passwordConfirmController.text = "";
                        setState(() {
                          _forLogin = !_forLogin;
                        });
                      },
                      child: Text(
                        _forLogin ? 'S\'inscrire' : 'se connecter',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}






/*import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  final String role; // Attend 'etudiant' ou 'admin'

  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _idController =
      TextEditingController(); // INE pour étudiant, IDA pour admin
  final _passwordController = TextEditingController();
  //bool _isLoginMode = true; // true = Connexion, false = Inscription
  bool _isObscure = true; // Pour masquer le mot de passe

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.role == 'admin' ? 'ADMIN CONNEXION' : 'STUDENT CONNEXION',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: sudocolor,
      ),

      // Le corps de la page d'authentification
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            key: _formKey,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // L'icone étudiant ou admin
              Icon(
                widget.role == 'admin'
                    ? Icons.admin_panel_settings
                    : Icons.school,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 40),
              // Le texte de bienvenue
              Text(
                'Se connexion en tant qu\'${widget.role.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              //demande de l'identifiant de l'utilisateur
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: widget.role == 'admin' ? 'IDa :' : 'IDe :',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre ${widget.role == 'admin' ? 'IDA' : 'INE'}.';
                  }
                  if (widget.role == 'admin' &&
                      !RegExp(r'^[A-Z]\d{11}$').hasMatch(value)) {
                    return 'L\'IDa doit commencer par une lettre suivie de 11 chiffres.';
                  } else if (widget.role == 'admin' &&
                      !RegExp(r'^[NE]\d{11}$').hasMatch(value)) {
                    return 'L\'IDe doit commencer par une lettre suivie de 11 chiffres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              //demande du mot de passe de l'utilisateur
              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe.';
                  } else if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              // Le bouton de connexion
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Connexion réussie !'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: sudocolor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'Se connecter',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/











                /*import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final String role; // Attend 'etudiant' ou 'admin'

  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoginMode = true; // true = Connexion, false = Inscription

  // Contrôleurs pour récupérer les données des champs
  final _idController =
      TextEditingController(); // INE pour étudiant, IDA pour admin
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _filiereController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Variables pour la liste déroulante (Niveau)
  final List<String> _niveaux = [
    'Licence 1',
    'Licence 2',
    'Licence 3',
    'Master 1',
    'Master 2',
  ];
  String? _selectedNiveau;

  @override
  void dispose() {
    _idController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _filiereController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final String idType = widget.role == 'etudiant' ? 'INE' : 'IDA';

      debugPrint("--- Soumission du Formulaire ---");
      debugPrint("Rôle: ${widget.role}");
      debugPrint("Mode: ${_isLoginMode ? 'Connexion' : 'Inscription'}");
      debugPrint("$idType: ${_idController.text}");
      debugPrint("Mot de passe: ${_passwordController.text}");

      if (!_isLoginMode) {
        debugPrint(
          "Nom: ${_nomController.text} | Prénom: ${_prenomController.text}",
        );
        debugPrint(
          "Mail (Facultatif): ${_emailController.text.isEmpty ? 'Non fourni' : _emailController.text}",
        );
        if (widget.role == 'etudiant') {
          debugPrint(
            "Filière: ${_filiereController.text} | Niveau: $_selectedNiveau",
          );
        }
      }

      // C'est ici que tu ajouteras plus tard tes requêtes API ou Firebase
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Validation réussie ! Connexion au serveur...'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isStudent = widget.role == 'etudiant';
    final String idLabel = isStudent ? 'INE' : 'IDA';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Thème Gris clair de l'app
      appBar: AppBar(
        title: Text(
          _isLoginMode ? 'Connexion $idLabel' : 'Inscription $idLabel',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icône dynamique (Chapeau de diplôme ou Écusson de sécurité)
                Icon(
                  isStudent ? Icons.school : Icons.admin_panel_settings,
                  size: 70,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),

                Text(
                  _isLoginMode
                      ? 'Ravi de vous revoir !'
                      : 'Créer un compte ${widget.role}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 24),

                // ==========================================
                // CHAMP : INE ou IDA (Affiché tout le temps)
                // ==========================================
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: idLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre $idLabel.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                if (!_isLoginMode) ...[
                  TextFormField(
                    controller: _nomController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _prenomController,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre prénom.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (isStudent) ...[
                    TextFormField(
                      controller: _filiereController,
                      decoration: InputDecoration(
                        labelText: 'Filière',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre filière.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedNiveau,
                      decoration: InputDecoration(
                        labelText: 'Niveau',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      items: _niveaux.map((niveau) {
                        return DropdownMenuItem<String>(
                          value: niveau,
                          child: Text(niveau),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedNiveau = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez choisir un niveau.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email (facultatif)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe.';
                    }
                    if (!_isLoginMode && value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                if (!_isLoginMode)
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (_isLoginMode) return null;
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe.';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas.';
                      }
                      return null;
                    },
                  ),
                if (!_isLoginMode) const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(_isLoginMode ? 'Connexion' : 'S\'inscrire'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLoginMode = !_isLoginMode;
                    });
                  },
                  child: Text(
                    _isLoginMode
                        ? 'Pas encore de compte ? Inscrivez-vous'
                        : 'Déjà un compte ? Connectez-vous',
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

                // ==========================================
                // CHAMP : INE ou IDA (Affiché tout le temps)
                // ========================================== */