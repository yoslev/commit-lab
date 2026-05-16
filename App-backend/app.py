from flask import Flask, jsonify
import os
import psycopg2

app = Flask(__name__)

##
def get_db_connection():
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        port=os.environ.get("DB_PORT", "5432"),
        database=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
    )
##

@app.route("/")
def home():
    print("111111111")
    
    be_ver_no = os.environ.get("BE_VER_NO", '777')
    with get_db_connection() as conn:
        print("22222222")
        with conn.cursor() as cur:
            print("33333333")
            cur.execute("SELECT NOW();")
            row = cur.fetchone()

            return jsonify({
                "message": "Hello Lab-commit ",
                "db_time": str(row[0]),
                "be_ver_no" : be_ver_no
            })            
    return {
        "message": "NO DB CONN"
    }

@app.route("/health")
def health():
    return {
        "status": "ok"
    }

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)