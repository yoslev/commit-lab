import os
import time
import threading
import requests
from flask import Flask
import traceback, json

app = Flask(__name__)

BACKEND_URL = os.getenv("BACKEND_URL", "http://flask-app-service.default.svc.cluster.local/")
POLL_SECONDS = int(os.getenv("POLL_SECONDS", "5"))

latest_value = "No value yet"


def poll_backend():
    global latest_value

    while True:
        try:
            response = requests.get(BACKEND_URL, timeout=3)
            latest_value = response.text
            # latest_value_obj = json.loads(latest_value)
        except Exception as e:
            latest_value = f"Backend error: {e}"

        time.sleep(POLL_SECONDS)

@app.route("/")
def home():
    try:
      print(f'calling ${BACKEND_URL}')
      response = requests.get(BACKEND_URL, timeout=3)
      print(f'got ${response.text}')
      latest_value = response.text
      latest_value_obj = json.loads(latest_value)
      be_ver_no = latest_value_obj['be_ver_no']
      db_time = latest_value_obj['db_time']
      message = latest_value_obj['message']
    
      return f"""
      <html>
        <body>
          <h1>Frontend Service</h1>
          <p>be_ver_no: {be_ver_no}</p>
          <p>db_time: {db_time}</p>
          <p>message: {message}</p>
        </body>
      </html>
      """
    except Exception as e:
      traceback.print_exc()
      latest_value = f"Backend error: {e}"

@app.route("/health")
def health():
    return {"status": "ok"}


if __name__ == "__main__":
    # threading.Thread(target=poll_backend, daemon=True).start()
    app.run(host="0.0.0.0", port=5000)