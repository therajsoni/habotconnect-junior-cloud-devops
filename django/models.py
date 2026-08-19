from django.db import models


class StudentOnboarding(models.Model):
    student_id = models.CharField(max_length=50, unique=True)
    student_name = models.CharField(max_length=100)
    parent_name = models.CharField(max_length=100)
    parent_email = models.EmailField()
    age = models.PositiveSmallIntegerField()
    learning_support_required = models.BooleanField()
    parent_consent = models.BooleanField()
    region = models.CharField(max_length=50)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.student_id