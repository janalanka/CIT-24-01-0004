import os
import time
from flask import Flask, request, redirect, url_for, render_template
import psycopg2

app = Flask(__name__)

DB_HOST = os.environ.get("DB_HOST", "notesapp-db")
DB_PORT = os.environ.get("DB_PORT", "5432")
DB_NAME = os.environ.get("DB_NAME", "notesapp")
DB_USER = os.environ.get("DB_USER", "notesapp")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "notesapp")


def get_connection():
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
    )


def init_db():
    for attempt in range(1, 16):
        try:
            conn = get_connection()
            cur = conn.cursor()
            cur.execute(
                """
                CREATE TABLE IF NOT EXISTS notes (
                    id SERIAL PRIMARY KEY,
                    content TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT NOW()
                )
                """
            )
            conn.commit()
            cur.close()
            conn.close()
            print("Database ready.")
            return
        except Exception as e:
            print(f"[{attempt}/15] Waiting for database... ({e})")
            time.sleep(2)
    raise RuntimeError("Could not connect to database after multiple retries")


@app.route("/")
def index():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, content, created_at FROM notes ORDER BY created_at DESC")
    notes = cur.fetchall()
    cur.close()
    conn.close()
    return render_template("index.html", notes=notes, db_host=DB_HOST)


@app.route("/add", methods=["POST"])
def add_note():
    content = request.form.get("content", "").strip()
    if content:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("INSERT INTO notes (content) VALUES (%s)", (content,))
        conn.commit()
        cur.close()
        conn.close()
    return redirect(url_for("index"))


@app.route("/delete/<int:note_id>", methods=["POST"])
def delete_note(note_id):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM notes WHERE id = %s", (note_id,))
    conn.commit()
    cur.close()
    conn.close()
    return redirect(url_for("index"))


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000)
    