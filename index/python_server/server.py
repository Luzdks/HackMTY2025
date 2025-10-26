# server.py (para conectar Python con Flutter)
from flask import Flask, jsonify
from flask_cors import CORS
from noticias_opt import get_positive_news


app = Flask(__name__)
CORS(app)  # Esto permite que Flutter se conecte

@app.route('/api/news', methods=['GET'])
def get_news():
    try:
        result = get_positive_news()
        return jsonify(result)
    except Exception as e:
        print("❌ Error en /api/news:", e)
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # inicia servidor Flask accesible en tu red local
    app.run(host='0.0.0.0', port=5000, debug=True)