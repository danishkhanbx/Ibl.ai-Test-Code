# api/consumers.py
import json
from channels.generic.websocket import AsyncWebsocketConsumer
from langflow import load_flow_from_json
from .custom_tool import CustomTool

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        # Authenticate the connection here
        await self.accept()

    async def disconnect(self, close_code):
        pass

    async def receive(self, text_data):
        text_data_json = json.loads(text_data)
        message = text_data_json['message']

        # Load Langflow
        flow = load_flow_from_json("path_to_your_langflow_json")
        
        # Add custom tool
        flow.add_tool(CustomTool())

        # Process the message
        response = flow.run(message)

        await self.send(text_data=json.dumps({
            'message': response
        }))