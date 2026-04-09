from datetime import datetime, timezone, timedelta
from models import db
import uuid
import random

class User(db.Model):
    """User model with bcrypt password hashing."""

    __tablename__ = "users"

    id = db.Column(db.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    full_name = db.Column(db.String(150), nullable=True)
    display_name = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    # role: system permission level — member | admin | guest
    role = db.Column(db.String(20), nullable=False, default="member")
    # user_type: how the user describes themselves — freelancer | student | employee | business
    user_type = db.Column(db.String(30), nullable=True)
    # OTP for email verification / password reset
    otp_code = db.Column(db.String(6), nullable=True)
    otp_expires_at = db.Column(db.DateTime, nullable=True)
    is_email_verified = db.Column(db.Boolean, default=False, nullable=False)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = db.Column(
        db.DateTime,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    # Relationships
    projects = db.relationship("Project", backref="owner", lazy=True)
    assigned_tasks = db.relationship(
        "Task", backref="assignee", lazy=True, foreign_keys="Task.assigned_to"
    )
    logs = db.relationship("Log", backref="user", lazy=True)

    def to_dict(self):
        """Serialize user to dictionary (excluding password)."""
        return {
            "id": str(self.id),
            "full_name": self.full_name,
            "display_name": self.display_name,
            "email": self.email,
            "role": self.role,
            "user_type": self.user_type,
            "is_email_verified": self.is_email_verified,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }

    def generate_otp(self):
        """Generate a 4-digit OTP valid for 10 minutes."""
        self.otp_code = str(random.randint(1000, 9999))
        self.otp_expires_at = datetime.now(timezone.utc) + timedelta(minutes=10)
        return self.otp_code

    def verify_otp(self, code):
        """Return True if the OTP is correct and not expired."""
        if not self.otp_code or not self.otp_expires_at:
            return False
        now = datetime.now(timezone.utc)
        otp_exp = self.otp_expires_at
        if otp_exp.tzinfo is None:
            otp_exp = otp_exp.replace(tzinfo=timezone.utc)
        if now > otp_exp:
            return False
        return self.otp_code == code

    def clear_otp(self):
        """Clear OTP after use."""
        self.otp_code = None
        self.otp_expires_at = None

    def __repr__(self):
        return f"<User {self.display_name}>"
