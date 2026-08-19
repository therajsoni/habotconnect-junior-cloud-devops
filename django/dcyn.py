"""
DCYN - Deterministic Compliance Yes/No validation library.

All business decisions are represented as explicit binary outcomes.
"""


class DCYN:
    YES = "YES"
    NO = "NO"

    @staticmethod
    def is_yes(value: bool) -> bool:
        return value is True

    @staticmethod
    def is_no(value: bool) -> bool:
        return value is False

    @staticmethod
    def require_yes(value: bool) -> bool:
        if value is not True:
            raise ValueError("Value must be YES.")
        return True

    @staticmethod
    def require_no(value: bool) -> bool:
        if value is not False:
            raise ValueError("Value must be NO.")
        return True