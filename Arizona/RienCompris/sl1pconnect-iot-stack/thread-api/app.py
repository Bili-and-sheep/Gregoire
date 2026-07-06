import os
import time
from typing import Optional
from flask import Flask, request, jsonify
import psycopg2
import jwt
from pydantic import BaseModel, EmailStr, field_validator

app = Flask(__name__)

JWT_SECRET = os.environ.get("JWT_SECRET")
if not JWT_SECRET:
    raise RuntimeError("JWT_SECRET manquant — injecter via secret Docker/Vault")

DB = dict(
    host=os.environ.get("DB_HOST", "db-velvet"),
    dbname=os.environ.get("DB_NAME", "velvet"),
    user=os.environ.get("DB_USER", "velvet"),
    password=os.environ.get("DB_PASSWORD"),
    port=int(os.environ.get("DB_PORT", "5432")),
)


def get_db():
    last = None
    for _ in range(15):
        try:
            return psycopg2.connect(**DB)
        except psycopg2.OperationalError as e:
            last = e
            time.sleep(2)
    raise RuntimeError("base indisponible: %s" % last)


# --- Modèles de validation pydantic ---

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

    @field_validator("password")
    @classmethod
    def password_not_empty(cls, v: str) -> str:
        if not v or len(v) < 1:
            raise ValueError("password requis")
        return v


class SensorRequest(BaseModel):
    user_id: int
    heart_rate: Optional[int] = None
    fall_detected: bool = False
    posture: Optional[str] = None

    @field_validator("heart_rate")
    @classmethod
    def heart_rate_range(cls, v: Optional[int]) -> Optional[int]:
        if v is not None and not (0 < v < 300):
            raise ValueError("heart_rate hors plage")
        return v


# --- Routes ---

@app.route("/health")
def health():
    return jsonify(status="ok", service="thread-api")


@app.route("/api/login", methods=["POST"])
def login():
    try:
        data = LoginRequest.model_validate(request.get_json(force=True, silent=True) or {})
    except Exception as e:
        return jsonify(error="données invalides", detail=str(e)), 400

    conn = get_db()
    cur = conn.cursor()
    # requête paramétrée — aucune injection possible
    cur.execute(
        "SELECT id, role FROM users WHERE email = %s AND password = %s",
        (data.email, data.password),
    )
    row = cur.fetchone()
    cur.close()
    conn.close()

    if not row:
        return jsonify(error="identifiants invalides"), 401

    token = jwt.encode(
        {"user_id": row[0], "role": row[1]},
        JWT_SECRET,
        algorithm="HS256",
    )
    return jsonify(token=token, user_id=row[0], role=row[1])


@app.route("/api/sensors", methods=["POST"])
def add_sensor():
    try:
        data = SensorRequest.model_validate(request.get_json(force=True, silent=True) or {})
    except Exception as e:
        return jsonify(error="données invalides", detail=str(e)), 400

    conn = get_db()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO health_data (user_id, heart_rate, fall_detected, posture) "
        "VALUES (%s, %s, %s, %s) RETURNING id",
        (data.user_id, data.heart_rate, data.fall_detected, data.posture),
    )
    new_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()
    return jsonify(id=new_id, status="recorded")


@app.route("/api/sensors/<int:user_id>")
def get_sensors(user_id: int):
    conn = get_db()
    cur = conn.cursor()
    cur.execute(
        "SELECT id, heart_rate, fall_detected, posture, recorded_at "
        "FROM health_data WHERE user_id = %s ORDER BY id",
        (user_id,),
    )
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify([
        dict(id=r[0], heart_rate=r[1], fall_detected=r[2],
             posture=r[3], recorded_at=str(r[4]))
        for r in rows
    ])


if __name__ == "__main__":
    # debug=False obligatoire en production
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", "8080")), debug=False)
