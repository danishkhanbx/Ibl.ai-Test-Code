# OpenEdX/tutor_integration/api_client.py
import requests
import websocket
import json

API_URL = "http://django:8000/api"
WS_URL = "ws://django:8000/ws/chat/"

def get_token(username, password):
    response = requests.post(f"{API_URL}/token/", data={"username": username, "password": password})
    return response.json()['access']

def connect_websocket(token):
    ws = websocket.WebSocketApp(
        WS_URL,
        on_message=on_message,
        header={"Authorization": f"Bearer {token}"}
    )
    ws.run_forever()

def on_message(ws, message):
    print(f"Received: {message}")

def send_message(ws, message):
    ws.send(json.dumps({"message": message}))

if __name__ == "__main__":
    token = get_token("your_username", "your_password")
    connect_websocket(token)