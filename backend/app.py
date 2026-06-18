
from flask import Flask
from config import Config
from extensions import db, jwt, migrate
from flask_cors import CORS

def create_app():
    app = Flask(__name__)

    app.config.from_object(Config)
    CORS(app)
    db.init_app(app)       
    jwt.init_app(app)      
    migrate.init_app(app, db)  
    
    from models import (
        Filiere, Salle, Session, Enseignant,
        Etudiant, Rapport, Disponibilite, Programme,
        Jury, Resultat, ValidationProgramme, Utilisateur
    )

    from routes import (
        auth_bp, sessions_bp, enseignants_bp, etudiants_bp,
        rapports_bp, programme_bp, jury_bp, resultats_bp
    )

    app.register_blueprint(auth_bp,         url_prefix="/auth")
    app.register_blueprint(sessions_bp,     url_prefix="/sessions")
    app.register_blueprint(enseignants_bp,  url_prefix="/enseignants")
    app.register_blueprint(etudiants_bp,    url_prefix="/etudiants")
    app.register_blueprint(rapports_bp,     url_prefix="/rapports")
    app.register_blueprint(programme_bp,    url_prefix="/programme")
    app.register_blueprint(jury_bp,         url_prefix="/jury")
    app.register_blueprint(resultats_bp,    url_prefix="/resultats")


    @app.route("/")
    def index():
        return {"message": "API Gestion Soutenances — OK ✓"}

    return app


if __name__ == "__main__":
    app = create_app()
    app.run(debug=True)  
                         