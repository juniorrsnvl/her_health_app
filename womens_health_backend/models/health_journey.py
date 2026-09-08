"""
models/health_journey.py

Pydantic request/response models for the health journey feature.
Matches the fields collected in health_setup_screen.dart and
journey_questions_screen.dart exactly, per journey type.

Each journey type gets its own typed "answers" model so the API actually
validates what comes in (rather than accepting an arbitrary dict), while
still storing as JSONB underneath -- see health_journey_schema.sql.
"""

from datetime import date
from typing import Literal, Optional, Union
from pydantic import BaseModel, Field



JourneyType = Literal[
    "pregnancy_care",
    "menstrual_health",
    "postpartum_recovery",
    "general_health",
    "cosmetic_gynecology",
]


class PregnancyCareAnswers(BaseModel):
    due_date: Optional[date] = None
    trimester: Optional[str] = None
    risk_level: Optional[str] = None
    doctor: Optional[str] = None
    weeks_pregnant: Optional[str] = None
    symptoms: Optional[str] = None
    concerns: Optional[str] = None
    notes: Optional[str] = None


class MenstrualHealthAnswers(BaseModel):
    last_period: Optional[date] = None
    cycle_length: int = 28
    period_length: int = 5
    irregular_periods: bool = False
    severe_pain: bool = False
    symptoms: Optional[str] = None
    flow: Optional[str] = None


class PostpartumRecoveryAnswers(BaseModel):
    baby_birth_date: Optional[date] = None
    baby_age: Optional[str] = None
    delivery_type: Optional[str] = None
    breastfeeding: bool = False
    recovery_concerns: Optional[str] = None
    notes: Optional[str] = None


class GeneralHealthAnswers(BaseModel):
    yearly_checkup: bool = False
    pap_smear: bool = False
    breast_exam: bool = False
    health_goals: Optional[str] = None
    health_concern: Optional[str] = None
    height: Optional[str] = None
    weight: Optional[str] = None
    exercise: Optional[str] = None
    water: Optional[str] = None


class CosmeticGynecologyAnswers(BaseModel):
    interest: Optional[str] = None
    goal: Optional[str] = None
    previous_procedure: Optional[str] = None
    specialist: Optional[str] = None
    expected_outcome: Optional[str] = None
    questions: Optional[str] = None


AnswersUnion = Union[
    PregnancyCareAnswers,
    MenstrualHealthAnswers,
    PostpartumRecoveryAnswers,
    GeneralHealthAnswers,
    CosmeticGynecologyAnswers,
]


class HealthJourneySetupRequest(BaseModel):
    journey_type: JourneyType
    answers: AnswersUnion


class HealthJourneyResponse(BaseModel):
    id: int
    patient_id: int
    journey_type: JourneyType
    answers: dict
    created_at: str
    updated_at: str


class HealthJourneyEntryRequest(BaseModel):
    entry_date: Optional[date] = None  # defaults to today if omitted
    pain_level: Optional[str] = None
    mood: Optional[str] = None
    data: dict = Field(default_factory=dict)


class HealthJourneyEntryResponse(BaseModel):
    id: int
    journey_id: int
    patient_id: int
    entry_date: str
    pain_level: Optional[str] = None
    mood: Optional[str] = None
    data: dict
    created_at: str