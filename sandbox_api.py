from flask import Flask, request, jsonify
from flask_cors import CORS # Para permitir que tu app frontend llame a esta API
import random

app = Flask(__name__)
CORS(app) 

# Simulación de la base de datos (simple diccionario)
TRANSACCIONES = {}
CONTEO_TRANSACCIONES = 1000

# Claves de prueba (como si fueran las llaves del sandbox de una pasarela real)
CLAVE_PUBLICA_SANDBOX = "pk_test_abc123"
CLAVE_SECRETA_SANDBOX = "sk_test_xyz456"

# --- Lógica de Simulación ---

def simular_pago(monto, token_tarjeta):
    """Simula la lógica de procesamiento de un pago."""
    global CONTEO_TRANSACCIONES
    CONTEO_TRANSACCIONES += 1
    
    id_transaccion = f"tx_{CONTEO_TRANSACCIONES}"
    
    # Lógica de prueba: Éxito si el token no es 'fallido' y el monto es positivo
    if token_tarjeta == "tok_fallido":
        estado = "rechazado"
        mensaje = "Tarjeta de prueba rechazada intencionalmente."
        codigo = "402"
    elif monto <= 0:
        estado = "fallido"
        mensaje = "El monto debe ser positivo."
        codigo = "400"
    else:
        estado = "aprobado"
        mensaje = "Pago simulado exitoso."
        codigo = "200"

    # Almacenar el resultado simulado
    TRANSACCIONES[id_transaccion] = {
        "id": id_transaccion,
        "monto": monto,
        "estado": estado,
        "token": token_tarjeta,
        "mensaje": mensaje,
        "codigo_respuesta": codigo
    }
    
    return TRANSACCIONES[id_transaccion], codigo

# --- Endpoints de la API ---

@app.route('/')
def home():
    """Ruta raíz simple para verificar que la API está viva."""
    return "¡API VIVA!"

@app.route('/api/v1/sandbox/charge', methods=['POST'])
def crear_cargo():
    """Endpoint para simular la entrada de dinero (cargo)."""
    
    data = request.get_json()
    
    # 1. Validación de Autenticación (con la clave de prueba secreta)
    auth_header = request.headers.get('Authorization')
    if auth_header != f'Bearer {CLAVE_SECRETA_SANDBOX}':
        return jsonify({"error": "Autenticación fallida o clave secreta incorrecta."}), 401
    
    # 2. Extracción y Validación de Datos
    try:
        monto = data['amount']
        token_tarjeta = data['source_token'] # El token que representa la tarjeta (ficticio)
    except KeyError:
        return jsonify({"error": "Faltan parámetros requeridos (amount o source_token)."}), 400

    # 3. Simulación del Pago
    resultado, codigo_http = simular_pago(monto, token_tarjeta)
    
    # Devolver la respuesta como si fuera la pasarela real
    return jsonify(resultado), int(codigo_http)

@app.route('/api/v1/sandbox/charges/<id_transaccion>', methods=['GET'])
def obtener_cargo(id_transaccion):
    """Endpoint para consultar el estado de una transacción simulada."""
    
    # Validación de Autenticación
    auth_header = request.headers.get('Authorization')
    if auth_header != f'Bearer {CLAVE_SECRETA_SANDBOX}':
        return jsonify({"error": "Autenticación fallida."}), 401

    # Búsqueda de la transacción
    transaccion = TRANSACCIONES.get(id_transaccion)
    if transaccion:
        return jsonify(transaccion), 200
    else:
        return jsonify({"error": "Transacción no encontrada."}), 404


if __name__ == '__main__':
    # Usar el puerto 5000 por defecto para Flask
    print(f"Sandbox iniciado. Clave Pública: {CLAVE_PUBLICA_SANDBOX}")
    app.run(debug=True, port=5000)