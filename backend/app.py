from flask import Flask
from config import Config
from flask_cors import CORS
from extension import db


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    db.init_app(app)
    CORS(app)

    from routes import etudiant_bp, enseignant_bp, session_bp, programme_bp, soutenance_bp, salle_bp, jury_bp, participation_bp, resultat_bp
    app.register_blueprint(etudiant_bp)
    app.register_blueprint(enseignant_bp)
    app.register_blueprint(session_bp)
    app.register_blueprint(programme_bp)
    app.register_blueprint(soutenance_bp)
    app.register_blueprint(salle_bp)
    app.register_blueprint(jury_bp)
    app.register_blueprint(participation_bp)
    app.register_blueprint(resultat_bp)
    return app

app = create_app()

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)
