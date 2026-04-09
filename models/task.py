from datetime import datetime, timezone
from models import db
import uuid

class Task(db.Model):
    """Task model belonging to a project, optionally assigned to a user."""

    __tablename__ = "tasks"

    id = db.Column(db.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text, nullable=True)
    status = db.Column(db.String(30), nullable=False, default="pending")
    priority = db.Column(db.String(20), nullable=False, default="medium")
    due_date = db.Column(db.Date, nullable=True)
    project_id = db.Column(db.UUID(as_uuid=True), db.ForeignKey("projects.id"), nullable=False)
    assigned_to = db.Column(db.UUID(as_uuid=True), db.ForeignKey("users.id"), nullable=True)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = db.Column(
        db.DateTime,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    __table_args__ = (
        # Fast lookups by project (most common query pattern)
        db.Index("ix_tasks_project_id", "project_id"),
        # Fast filtering by status within a project
        db.Index("ix_tasks_project_status", "project_id", "status"),
        # Fast filtering by assigned user
        db.Index("ix_tasks_assigned_to", "assigned_to"),
    )

    def to_dict(self):
        """Serialize task to dictionary."""
        return {
            "id": str(self.id),
            "title": self.title,
            "description": self.description,
            "status": self.status,
            "priority": self.priority,
            "due_date": self.due_date.isoformat() if self.due_date else None,
            "project_id": str(self.project_id),
            "assigned_to": str(self.assigned_to) if self.assigned_to else None,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }

    def __repr__(self):
        return f"<Task {self.title}>"
