import os
from flask import Flask, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from flask_bcrypt import Bcrypt
from flask_migrate import Migrate
from flasgger import Swagger
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from config import Config
from models import db

# Module-level limiter so routes can import it without circular deps
limiter = Limiter(key_func=get_remote_address, storage_uri="memory://")


def create_app():
    """Create and configure the Flask application."""

    app = Flask(__name__)
    app.config.from_object(Config)

    # --- Initialize Extensions ---
    db.init_app(app)
    Migrate(app, db)          # enables: flask db init / migrate / upgrade
    CORS(app, resources={r"/api/*": {"origins": "*"}})
    JWTManager(app)
    Bcrypt(app)
    limiter.init_app(app)

    # --- Swagger Configuration ---
    swagger_config = {
        "headers": [],
        "specs": [
            {
                "endpoint": "apispec",
                "route": "/apispec.json",
                "rule_filter": lambda rule: True,
                "model_filter": lambda tag: True,
            }
        ],
        "static_url_path": "/flasgger_static",
        "swagger_ui": True,
        "specs_route": "/swagger/",
    }

    swagger_template = {
        "info": {
            "title": "Backend Task 1 API",
            "description": "REST API with Auth, JWT, and DB Schema",
            "version": "1.0.0",
        },
        "securityDefinitions": {
            "Bearer": {
                "type": "apiKey",
                "name": "Authorization",
                "in": "header",
                "description": "JWT token. Format: Bearer <token>",
            }
        },
    }

    Swagger(app, config=swagger_config, template=swagger_template)

    # --- Register Blueprints ---
    from routes.auth import auth_bp
    from routes.users import users_bp
    from routes.projects import projects_bp
    from routes.tasks import tasks_bp
    from routes.logs import logs_bp

    app.register_blueprint(auth_bp)
    app.register_blueprint(users_bp)
    app.register_blueprint(projects_bp)
    app.register_blueprint(tasks_bp)
    app.register_blueprint(logs_bp)

    # ─── Health Check ─────────────────────────────────────────────────────────
    @app.route("/api/health", methods=["GET"])
    def health():
        """
        Health check — confirms the API and database are reachable.
        ---
        tags:
          - Health
        responses:
          200:
            description: API is healthy
            schema:
              type: object
              properties:
                status:
                  type: string
                  example: ok
                database:
                  type: string
                  example: ok
          503:
            description: Database unreachable
        """
        from sqlalchemy import text
        try:
            db.session.execute(text("SELECT 1"))
            db_status = "ok"
            http_status = 200
        except Exception:
            db_status = "error"
            http_status = 503
        return jsonify({"status": "ok" if http_status == 200 else "degraded", "database": db_status}), http_status

    # --- Import models + create tables if they don't exist ---
    with app.app_context():
        from models.user import User
        from models.project import Project
        from models.project_member import ProjectMember
        from models.task import Task
        from models.log import Log

        db.create_all()  # ← مهم: بينشئ الجداول في PostgreSQL لو مش موجودة

    return app


if __name__ == "__main__":
    app = create_app()
    port = int(os.getenv("PORT", 5022))
    debug = os.getenv("FLASK_DEBUG", "False").lower() in ("true", "1")

    print(f"[✓] Server running on http://localhost:{port}")
    print(f"[✓] Debug mode: {debug}")
    print(f"[✓] Swagger UI: http://localhost:{port}/swagger/")
    print(f"[✓] Endpoints:")
    print(f"    POST /api/auth/register")
    print(f"    POST /api/auth/login")
    print(f"    GET  /api/users/profile        (protected)")
    print(f"    GET  /api/users/admin-dashboard (admin only)")

    app.run(host="0.0.0.0", port=port, debug=debug)
