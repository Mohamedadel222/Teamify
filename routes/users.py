from flask import Blueprint, request, jsonify
from flask_jwt_extended import get_jwt_identity
from middleware.auth import auth_required, admin_required
from models import db
from models.user import User
import re
import uuid

users_bp = Blueprint("users", __name__, url_prefix="/api/users")

EMAIL_RE = re.compile(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
VALID_USER_TYPES = {"freelancer", "student", "employee", "business"}


@users_bp.route("/profile", methods=["GET"])
@auth_required
def get_profile():
    """
    Get the current authenticated user's profile.
    ---
    tags:
      - Users
    security:
      - Bearer: []
    responses:
      200:
        description: User profile data
        schema:
          type: object
          properties:
            user:
              type: object
              properties:
                id:
                  type: string
                display_name:
                  type: string
                full_name:
                  type: string
                email:
                  type: string
                role:
                  type: string
                user_type:
                  type: string
                created_at:
                  type: string
                updated_at:
                  type: string
      401:
        description: Unauthorized — missing or invalid token
      404:
        description: User not found
    """
    current_user_id = get_jwt_identity()
    user = User.query.filter_by(id=uuid.UUID(current_user_id)).first()

    if not user:
        return jsonify({"error": "Not Found", "message": "User not found"}), 404

    return jsonify({"user": user.to_dict()}), 200


@users_bp.route("/profile", methods=["PUT"])
@auth_required
def update_profile():
    """
    Update the current user's profile.
    ---
    tags:
      - Users
    security:
      - Bearer: []
    parameters:
      - in: body
        name: body
        schema:
          type: object
          properties:
            display_name:
              type: string
              description: New unique display name
            full_name:
              type: string
              description: Real full name (optional)
            user_type:
              type: string
              enum: [freelancer, student, employee, business]
              description: How the user describes themselves
    responses:
      200:
        description: Profile updated successfully
      400:
        description: Validation error
      409:
        description: Display name already taken
      401:
        description: Unauthorized
    """
    current_user_id = get_jwt_identity()
    user = User.query.filter_by(id=uuid.UUID(current_user_id)).first()

    if not user:
        return jsonify({"error": "Not Found", "message": "User not found"}), 404

    data = request.get_json() or {}
    errors = []

    if "display_name" in data:
        new_name = data["display_name"].strip()
        if not new_name:
            errors.append("display_name cannot be empty")
        else:
            taken = User.query.filter(
                User.display_name == new_name,
                User.id != user.id
            ).first()
            if taken:
                return jsonify({"error": "Conflict", "message": "Display name already taken"}), 409
            user.display_name = new_name

    if "full_name" in data:
        user.full_name = data["full_name"].strip() or None

    if "user_type" in data:
        raw = data["user_type"].strip().lower() if data["user_type"] else ""
        if raw and raw not in VALID_USER_TYPES:
            errors.append(f"user_type must be one of: {', '.join(sorted(VALID_USER_TYPES))}")
        else:
            user.user_type = raw or None

    if errors:
        return jsonify({"error": "Validation failed", "messages": errors}), 400

    db.session.commit()
    return jsonify({"message": "Profile updated successfully", "user": user.to_dict()}), 200


@users_bp.route("/admin-dashboard", methods=["GET"])
@admin_required
def admin_dashboard():
    """
    Admin-only endpoint — returns list of all users.
    ---
    tags:
      - Admin
    security:
      - Bearer: []
    responses:
      200:
        description: List of all users (admin only)
        schema:
          type: object
          properties:
            users:
              type: array
              items:
                type: object
                properties:
                  id:
                    type: string
                  display_name:
                    type: string
                  email:
                    type: string
                  role:
                    type: string
            total:
              type: integer
      401:
        description: Unauthorized — missing or invalid token
      403:
        description: Forbidden — admin access required
    """
    all_users = User.query.order_by(User.created_at.desc()).all()
    return jsonify({
        "users": [u.to_dict() for u in all_users],
        "total": len(all_users),
    }), 200
