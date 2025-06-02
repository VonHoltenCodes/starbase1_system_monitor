#!/usr/bin/env python3
from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Starbase1 Test</title>
        <style>
            body { 
                background: #008080; 
                font-family: Arial; 
                color: white; 
                text-align: center; 
                padding: 50px; 
            }
            .window { 
                background: #c0c0c0; 
                color: black; 
                border: 2px outset #c0c0c0; 
                padding: 20px; 
                margin: 20px auto; 
                width: 500px;
            }
        </style>
    </head>
    <body>
        <div class="window">
            <h1>🖥️ Starbase1 System Monitor</h1>
            <p>Windows 95 Style - Container Test</p>
            <p>If you see this, the container is working!</p>
        </div>
    </body>
    </html>
    '''

@app.route('/health')
def health():
    return {'status': 'healthy'}

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)