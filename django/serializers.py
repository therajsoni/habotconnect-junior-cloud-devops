from rest_framework import serializers

from .dcyn import DCYN
from .models import StudentOnboarding


class StudentOnboardingSerializer(serializers.ModelSerializer):
    class Meta:
        model = StudentOnboarding
        fields = [
            "student_id",
            "student_name",
            "parent_name",
            "parent_email",
            "age",
            "learning_support_required",
            "parent_consent",
            "region",
        ]

    def validate_student_id(self, value):
        if not 3 <= len(value) <= 50:
            raise serializers.ValidationError(
                "Student ID must contain between 3 and 50 characters."
            )

        return value

    def validate_student_name(self, value):
        value = value.strip()

        if not 2 <= len(value) <= 100:
            raise serializers.ValidationError(
                "Student name must contain between 2 and 100 characters."
            )

        return value

    def validate_parent_name(self, value):
        value = value.strip()

        if not 2 <= len(value) <= 100:
            raise serializers.ValidationError(
                "Parent name must contain between 2 and 100 characters."
            )

        return value

    def validate_age(self, value):
        if not 3 <= value <= 25:
            raise serializers.ValidationError(
                "Age must be between 3 and 25."
            )

        return value

    def validate_region(self, value):
        value = value.strip()

        if not 2 <= len(value) <= 50:
            raise serializers.ValidationError(
                "Region must contain between 2 and 50 characters."
            )

        return value

    def validate_parent_consent(self, value):
        if not isinstance(value, bool):
            raise serializers.ValidationError(
                "Parent consent must be YES or NO."
            )

        return value

    def validate_learning_support_required(self, value):
        if not isinstance(value, bool):
            raise serializers.ValidationError(
                "Learning support requirement must be YES or NO."
            )

        return value

    def validate(self, attrs):
        parent_consent = attrs.get("parent_consent")
        learning_support_required = attrs.get(
            "learning_support_required"
        )

        # DCYN decision
        if DCYN.is_no(parent_consent):
            raise serializers.ValidationError(
                {
                    "parent_consent": (
                        "Parent consent must be YES before onboarding."
                    )
                }
            )

        if learning_support_required is True:
            attrs["dcyn_decision"] = DCYN.YES
        else:
            attrs["dcyn_decision"] = DCYN.NO

        return attrs