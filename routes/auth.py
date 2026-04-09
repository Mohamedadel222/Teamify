import re
from flask import Blueprint, request, jsonify
from flask_bcrypt import Bcrypt
from flask_jwt_extended import (
    create_access_token, create_refresh_token,
    verify_jwt_in_request, get_jwt_identity, jwt_required
)
from models import db
from models.user import User
from models.log import Log
import uuid
from app import limiter

EMAIL_RE = re.compile(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
# At least 8 chars, 1 uppercase letter, 1 digit
PASSWORD_RE = re.compile(r'^(?=.*[A-Z])(?=.*\d).{8,}$')

auth_bp = Blueprint("auth", __name__, url_prefix="/api/auth")
bcrypt = Bcrypt()


@auth_bp.route("/register", methods=["POST"])
def register():
    """
    Register a new user.
    ---
    tags:
      - Auth
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - display_name
            - email
            - password
          properties:
            display_name:
              type: string
              example: johndoe
              description: Unique display name shown in the app
            email:
              type: string
              example: john@example.com
            password:
              type: string
              example: Password1
              minLength: 8
              description: Min 8 chars, must include at least 1 uppercase letter and 1 digit
            full_name:
              type: string
              example: John Doe
              description: Optional real full name
            role:
              type: string
              enum: [member, guest]
              example: member
              description: |
                System permission level. Defaults to 'member'.
                - member  → standard user (default)
                - guest   → read-only access
                - admin   → admin-only, requires existing admin JWT
            user_type:
              type: string
              enum: [freelancer, student, employee, business]
              example: freelancer
              description: |
                How the user describes themselves (optional).
                - freelancer → independent contractor / remote worker
                - student    → currently studying
                - employee   → works at a company
                - business   → owns or runs a business
    responses:
      201:
        description: User registered successfully
        schema:
          type: object
          properties:
            message:
              type: string
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
            access_token:
              type: string
      400:
        description: Validation errors
      409:
        description: Display name or email already exists
    """
    data = request.get_json()

    # --- Validation ---
    if not data:
        return jsonify({"error": "Request body is required"}), 400

    display_name = data.get("display_name", "").strip()
    full_name = data.get("full_name", "").strip()
    email = data.get("email", "").strip()
    password = data.get("password", "")

    # user_type: optional self-description — freelancer | student | employee | business
    VALID_USER_TYPES = {"freelancer", "student", "employee", "business"}
    raw_user_type = data.get("user_type", "").strip().lower()
    user_type = raw_user_type if raw_user_type in VALID_USER_TYPES else None

    # role: system permission level
    # Self-registration: member | guest allowed.
    # admin role requires an existing admin JWT.
    PUBLIC_ROLES = {"member", "guest"}
    requested_role = data.get("role", "member").strip().lower()

    # Check if caller is an authenticated admin trying to create an admin
    is_admin_caller = False
    try:
        verify_jwt_in_request(optional=True)
        caller_id = get_jwt_identity()
        if caller_id:
            caller = User.query.filter_by(id=uuid.UUID(caller_id)).first()
            if caller and caller.role == "admin":
                is_admin_caller = True
    except Exception:
        pass

    allowed_roles = {"member", "freelancer", "student", "guest", "admin"} if is_admin_caller else PUBLIC_ROLES
    role = requested_role if requested_role in allowed_roles else "member"

    errors = []
    if not display_name:
        errors.append("display_name is required")
    if not email:
        errors.append("Email is required")
    elif not EMAIL_RE.match(email):
        errors.append("Email format is invalid")
    if not password or not PASSWORD_RE.match(password):
        errors.append("Password must be at least 8 characters with 1 uppercase letter and 1 digit")
    if requested_role not in allowed_roles:
        errors.append(
            f"Role '{requested_role}' is not allowed. "
            + (f"Allowed: {', '.join(sorted(allowed_roles))}" if is_admin_caller
               else f"Allowed for self-registration: {', '.join(sorted(PUBLIC_ROLES))}")
        )
    if raw_user_type and raw_user_type not in VALID_USER_TYPES:
        errors.append(
            f"user_type '{raw_user_type}' is not valid. "
            f"Allowed: {', '.join(sorted(VALID_USER_TYPES))}"
        )

    if errors:
        return jsonify({"error": "Validation failed", "messages": errors}), 400

    # --- Check duplicates ---
    if User.query.filter_by(display_name=display_name).first():
        return jsonify({"error": "Conflict", "message": "Display name already exists"}), 409
    if User.query.filter_by(email=email).first():
        return jsonify({"error": "Conflict", "message": "Email already exists"}), 409

    # --- Hash password with bcrypt ---
    hashed_password = bcrypt.generate_password_hash(password).decode("utf-8")

    # --- Create user ---
    new_user = User(
        display_name=display_name,
        full_name=full_name or None,
        email=email,
        password=hashed_password,
        role=role,
        user_type=user_type,
    )
    db.session.add(new_user)
    db.session.flush()  # get new_user.id without committing yet

    # --- Log the registration (single commit) ---
    log = Log(
        action="REGISTER",
        entity="User",
        entity_id=new_user.id,
        details=f"User '{display_name}' registered with role '{role}'",
        user_id=new_user.id,
    )
    db.session.add(log)
    db.session.commit()

    # --- Generate JWT access + refresh tokens ---
    access_token = create_access_token(identity=str(new_user.id))
    refresh_token = create_refresh_token(identity=str(new_user.id))

    return jsonify({
        "message": "User registered successfully",
        "user": new_user.to_dict(),
        "access_token": access_token,
        "refresh_token": refresh_token,
    }), 201


@auth_bp.route("/login", methods=["POST"])
@limiter.limit("10 per minute")
def login():
    """
    Log in an existing user.
    ---
    tags:
      - Auth
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - email
            - password
          properties:
            email:
              type: string
              example: john@example.com
            password:
              type: string
              example: password123
    responses:
      200:
        description: Login successful
        schema:
          type: object
          properties:
            message:
              type: string
            user:
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
            access_token:
              type: string
            refresh_token:
              type: string
      400:
        description: Validation errors
      401:
        description: Invalid email or password
    """
    data = request.get_json()

    if not data:
        return jsonify({"error": "Request body is required"}), 400

    email = data.get("email", "").strip()
    password = data.get("password", "")

    if not email or not password:
        return jsonify({"error": "Email and password are required"}), 400

    # --- Find user ---
    user = User.query.filter_by(email=email).first()

    if not user or not bcrypt.check_password_hash(user.password, password):
        return jsonify({"error": "Invalid email or password"}), 401

    # --- Log the login ---
    log = Log(
        action="LOGIN",
        entity="User",
        entity_id=user.id,
        details=f"User '{user.display_name}' logged in",
        user_id=user.id,
    )
    db.session.add(log)
    db.session.commit()

    # --- Generate JWT access + refresh tokens ---
    access_token = create_access_token(identity=str(user.id))
    refresh_token = create_refresh_token(identity=str(user.id))

    return jsonify({
        "message": "Login successful",
        "user": user.to_dict(),
        "access_token": access_token,
        "refresh_token": refresh_token,
    }), 200


# ─── GET /api/auth/me ─────────────────────────────────────────────────────────

@auth_bp.route("/me", methods=["GET"])
def me():
    """
    Get the currently authenticated user from the JWT token.
    ---
    tags:
      - Auth
    security:
      - Bearer: []
    responses:
      200:
        description: Current user data
      401:
        description: Missing or invalid token
      404:
        description: User not found
    """
    from middleware.auth import auth_required as _guard
    from flask_jwt_extended import verify_jwt_in_request
    try:
        verify_jwt_in_request()
    except Exception:
        return jsonify({"error": "Unauthorized", "message": "Missing or invalid token"}), 401

    user_id = get_jwt_identity()
    user = User.query.filter_by(id=uuid.UUID(user_id)).first()
    if not user:
        return jsonify({"error": "Not Found", "message": "User not found"}), 404

    return jsonify({"user": user.to_dict()}), 200


# ─── POST /api/auth/refresh ───────────────────────────────────────────────────

@auth_bp.route("/refresh", methods=["POST"])
@jwt_required(refresh=True)
def refresh():
    """
    Get a new access token using a valid refresh token.
    ---
    tags:
      - Auth
    security:
      - Bearer: []
    responses:
      200:
        description: New access token issued
        schema:
          type: object
          properties:
            access_token:
              type: string
      401:
        description: Missing or invalid refresh token
    """
    user_id = get_jwt_identity()
    new_access_token = create_access_token(identity=user_id)
    return jsonify({"access_token": new_access_token}), 200


# ─── POST /api/auth/forgot-password ───────────────────────────────────────────

@auth_bp.route("/forgot-password", methods=["POST"])
@limiter.limit("5 per minute")
def forgot_password():
    """
    Request a password-reset OTP. The OTP is returned in the response
    (in production you would send it by email instead).
    ---
    tags:
      - Auth
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - email
          properties:
            email:
              type: string
              example: john@example.com
    responses:
      200:
        description: OTP sent (returned in response for dev)
      400:
        description: Email is required
      404:
        description: No account with this email
    """
    data = request.get_json() or {}
    email = data.get("email", "").strip()

    if not email:
        return jsonify({"error": "Email is required"}), 400

    user = User.query.filter_by(email=email).first()
    if not user:
        return jsonify({"error": "No account found with this email"}), 404

    otp = user.generate_otp()
    db.session.commit()

    # In production: send OTP via email service.
    # For development, return it directly so the Flutter app can use it.
    return jsonify({
        "message": f"OTP sent to {email}",
        "otp": otp,  # remove in production
    }), 200


# ─── POST /api/auth/verify-otp ────────────────────────────────────────────────

@auth_bp.route("/verify-otp", methods=["POST"])
@limiter.limit("10 per minute")
def verify_otp():
    """
    Verify the OTP code. Returns a short-lived reset token on success.
    ---
    tags:
      - Auth
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - email
            - otp
          properties:
            email:
              type: string
              example: john@example.com
            otp:
              type: string
              example: "1234"
    responses:
      200:
        description: OTP verified, reset_token returned
      400:
        description: Invalid or expired OTP
    """
    data = request.get_json() or {}
    email = data.get("email", "").strip()
    otp = data.get("otp", "").strip()

    if not email or not otp:
        return jsonify({"error": "Email and OTP are required"}), 400

    user = User.query.filter_by(email=email).first()
    if not user:
        return jsonify({"error": "Invalid email or OTP"}), 400

    if not user.verify_otp(otp):
        return jsonify({"error": "Invalid or expired OTP"}), 400

    # Create a short-lived token that authorises the password reset
    reset_token = create_access_token(
        identity=str(user.id),
        expires_delta=__import__('datetime').timedelta(minutes=15),
        additional_claims={"purpose": "password_reset"},
    )

    return jsonify({
        "message": "OTP verified successfully",
        "reset_token": reset_token,
    }), 200


# ─── POST /api/auth/reset-password ────────────────────────────────────────────

@auth_bp.route("/reset-password", methods=["POST"])
@limiter.limit("5 per minute")
def reset_password():
    """
    Reset the user's password using the reset token from verify-otp.
    ---
    tags:
      - Auth
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - reset_token
            - new_password
          properties:
            reset_token:
              type: string
            new_password:
              type: string
              minLength: 8
    responses:
      200:
        description: Password reset successfully
      400:
        description: Validation error
      401:
        description: Invalid or expired reset token
    """
    data = request.get_json() or {}
    reset_token = data.get("reset_token", "").strip()
    new_password = data.get("new_password", "")

    if not reset_token or not new_password:
        return jsonify({"error": "reset_token and new_password are required"}), 400

    if not PASSWORD_RE.match(new_password):
        return jsonify({"error": "Password must be at least 8 characters with 1 uppercase letter and 1 digit"}), 400

    # Decode the reset token
    from flask_jwt_extended import decode_token
    try:
        token_data = decode_token(reset_token)
    except Exception:
        return jsonify({"error": "Invalid or expired reset token"}), 401

    if token_data.get("purpose") != "password_reset":
        return jsonify({"error": "Invalid token purpose"}), 401

    user_id = token_data.get("sub")
    user = User.query.filter_by(id=uuid.UUID(user_id)).first()
    if not user:
        return jsonify({"error": "User not found"}), 404

    user.password = bcrypt.generate_password_hash(new_password).decode("utf-8")
    user.clear_otp()
    db.session.commit()

    return jsonify({"message": "Password reset successfully"}), 200
