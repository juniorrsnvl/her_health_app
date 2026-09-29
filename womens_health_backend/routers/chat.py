"""
routers/chat.py

Backs chatbot_screen.dart. Every message the patient sends is saved,
answered, and the answer is saved too -- so the conversation survives
logging out and back in.

Replies are rule-based (keyword matching), not a real AI. See
generate_reply() below for exactly what to change when that's swapped
out for a real provider -- it's the only function in this file that
would need to change; the endpoints, the database, and the frontend all
stay exactly the same shape.
"""

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from config.database import get_database_connection
from utils.dependencies import get_current_user

router = APIRouter(prefix="/chat", tags=["Chat"])


class ChatMessageRequest(BaseModel):
    message: str


class ChatMessageResponse(BaseModel):
    id: int
    sender: str
    message: str
    created_at: str


def _get_patient_id(cursor, user_id: int) -> int:
    cursor.execute("SELECT id FROM patients WHERE user_id = %s", (user_id,))
    row = cursor.fetchone()
    if not row:
        raise HTTPException(
            status_code=404,
            detail="No patient profile found for this account. Complete your patient profile first.",
        )
    return row["id"]


# keyword -> response. Checked in order; the first match wins, so put more
# specific topics before general ones if that ever matters.
_RULES = [
    (["period", "menstru", "cycle", "cramp"],
     "Tracking your cycle is a great step \U0001F338. Irregular periods, "
     "heavy flow, or severe cramps are worth mentioning to your doctor, "
     "especially if they're new or getting worse. Want to book an "
     "appointment to talk it through?"),
    (["pregnan", "due date", "trimester", "antenatal"],
     "Congratulations on your pregnancy journey \U0001F930. Regular "
     "antenatal visits really matter for you and your baby. If you're "
     "experiencing any pain, bleeding, or symptoms that worry you, please "
     "reach out to your doctor directly rather than waiting."),
    (["postpartum", "breastfeed", "newborn"],
     "The postpartum period can be a lot to navigate \U0001F476. Be gentle "
     "with yourself, physically and emotionally. If your mood, sleep, or "
     "recovery feels off, that's worth raising with your doctor at your "
     "next check-up."),
    (["nausea", "nauseous", "vomit", "throwing up", "sick to my stomach"],
     "Nausea can come from a lot of different things -- your cycle, "
     "pregnancy, or something unrelated entirely. If it's persistent, "
     "sudden, or paired with other symptoms, it's worth getting checked "
     "rather than waiting it out. Want to book an appointment?"),
    (["tired", "fatigue", "exhaust", "no energy", "low energy"],
     "Fatigue that doesn't let up is worth paying attention to \U0001F33F "
     "-- it can be tied to sleep, stress, your cycle, or something else "
     "entirely. If it's been going on for a while, mention it to your "
     "doctor at your next visit."),
    (["headache", "migraine"],
     "Headaches can have a lot of different causes. If they're frequent, "
     "severe, or new for you, that's worth flagging to your doctor rather "
     "than just pushing through them."),
    (["fever", "temperature", "chills"],
     "A fever is your body telling you something's going on. If it's "
     "high, doesn't come down, or comes with other symptoms, please "
     "don't wait -- reach out to your doctor or urgent care."),
    (["bleed", "spotting", "discharge"],
     "Any bleeding or discharge that's unusual for you, whether the "
     "amount, color, or timing, is worth having a doctor take a look at "
     "directly rather than guessing over chat."),
    (["dizzy", "dizziness", "faint", "lightheaded"],
     "Feeling dizzy or lightheaded is worth taking seriously, especially "
     "if it happens more than once. If you can, sit or lie down when it "
     "happens, and let your doctor know."),
    (["sleep", "insomnia", "can't sleep", "trouble sleeping"],
     "Sleep affects pretty much everything else \U0001F33F. If it's been "
     "hard to get good rest for a while, that's a real thing worth "
     "mentioning at your next check-up, not something to just push "
     "through."),
    (["pain", "hurt", "ache", "sore"],
     "I'm sorry you're dealing with pain. I can't diagnose what's causing "
     "it, but persistent or severe pain is always worth having checked. "
     "Would you like help booking an appointment?"),
    (["appointment", "book", "doctor", "visit", "reschedule"],
     "You can request an appointment any time from the Appointments menu "
     "-- just pick a date and time and your doctor's office will confirm "
     "it."),
    (["sad", "anxious", "anxiety", "mood", "stress", "depress", "overwhelm"],
     "Thank you for sharing how you're feeling \U0001F33F. Your mental "
     "health matters just as much as your physical health. If this "
     "feeling has been sticking around, it's worth talking to your "
     "doctor about."),
    (["thank", "thanks", "thank you"],
     "You're so welcome \U0001F338. I'm always here if you want to talk "
     "through anything else."),
    (["hello", "hi", "hey", "morning", "evening"],
     "Hi there \U0001F338! I'm here to support your wellness journey. You "
     "can ask me about your cycle, pregnancy, postpartum recovery, or "
     "general wellness, or just tell me what's on your mind."),
    (["what can you", "help me", "what do you do"],
     "I can chat with you about your cycle, pregnancy, postpartum "
     "recovery, and general wellness, and point you toward booking an "
     "appointment when something's worth a doctor's opinion. I'm not a "
     "replacement for medical care, just a starting point \U0001F33F."),
]

_FALLBACK = (
    "Thank you for sharing that with me \U0001F33F. I'm still learning, "
    "so I might not have the perfect answer for everything -- but if "
    "this is something you'd like a professional opinion on, I'd "
    "recommend booking an appointment."
)


def generate_reply(message: str) -> str:
    """
    Rule-based reply, matched by keyword. THIS is the entire surface that
    needs to change to swap in a real AI provider (e.g. the Claude API)
    later -- replace this function's body with a call to that provider,
    and nothing else in this file needs to move.
    """
    lowered = message.lower()
    for keywords, response in _RULES:
        if any(keyword in lowered for keyword in keywords):
            return response
    return _FALLBACK


@router.post("/message", response_model=list[ChatMessageResponse])
def send_message(
    request: ChatMessageRequest,
    current_user: dict = Depends(get_current_user),
):
    """
    Saves the user's message, generates a reply, saves that too, and
    returns both as a pair -- so the frontend can append them in order
    without a second round trip.
    """
    connection = get_database_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        patient_id = _get_patient_id(cursor, current_user["user_id"])

        cursor.execute(
            """
            INSERT INTO chat_messages (patient_id, sender, message)
            VALUES (%s, 'user', %s)
            RETURNING id, sender, message, created_at
            """,
            (patient_id, request.message),
        )
        user_row = cursor.fetchone()

        reply_text = generate_reply(request.message)

        cursor.execute(
            """
            INSERT INTO chat_messages (patient_id, sender, message)
            VALUES (%s, 'ai', %s)
            RETURNING id, sender, message, created_at
            """,
            (patient_id, reply_text),
        )
        ai_row = cursor.fetchone()

        connection.commit()

        return [
            {
                "id": user_row["id"],
                "sender": user_row["sender"],
                "message": user_row["message"],
                "created_at": str(user_row["created_at"]),
            },
            {
                "id": ai_row["id"],
                "sender": ai_row["sender"],
                "message": ai_row["message"],
                "created_at": str(ai_row["created_at"]),
            },
        ]
    finally:
        connection.close()


@router.get("/messages", response_model=list[ChatMessageResponse])
def get_messages(current_user: dict = Depends(get_current_user)):
    """Full conversation history, oldest first."""
    connection = get_database_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        patient_id = _get_patient_id(cursor, current_user["user_id"])

        cursor.execute(
            """
            SELECT id, sender, message, created_at
            FROM chat_messages
            WHERE patient_id = %s
            ORDER BY created_at ASC, id ASC
            """,
            (patient_id,),
        )
        rows = cursor.fetchall()

        return [
            {
                "id": r["id"],
                "sender": r["sender"],
                "message": r["message"],
                "created_at": str(r["created_at"]),
            }
            for r in rows
        ]
    finally:
        connection.close()
