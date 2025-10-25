"""
API Mock para Hackaton - Microinversiones
Este servidor Flask simula el backend para una app de "round-up".
Permite:
- Ver fondos de inversión/donación.
- "Invertir" (registrar) dinero en esos fondos.
- Consultar el portafolio de un usuario.
"""
from flask import Flask, jsonify, request
from flask_cors import CORS # Para permitir que tu app frontend llame a esta API
import random

# Configuración inicial
app = Flask(__name__)
CORS(app) 

# --- Base de Datos Mock en Memoria ---

# 1. Lista de fondos
funds = [
  {
    "id": "fondo-001",
    "nombre": "Fondo Verde (Replantar)",
    "descripcion": "Invierte en proyectos de reforestación global.",
    "tipo": "donacion",
    "riesgo": "bajo",
    "retorno_anual_estimado": "N/A"
  },
  {
    "id": "fondo-002",
    "nombre": "Océanos Limpios",
    "descripcion": "Apoya a ONGs que limpian plástico del mar.",
    "tipo": "donacion",
    "riesgo": "bajo",
    "retorno_anual_estimado": "N/A"
  },
  {
    "id": "fondo-003",
    "nombre": "Tech Global (Riesgo Alto)",
    "descripcion": "Fondo que sigue a las 10 empresas de tecnología más grandes.",
    "tipo": "inversion",
    "riesgo": "alto",
    "retorno_anual_estimado": "12.5%"
  },
  {
    "id": "fondo-004",
    "nombre": "S&P 500 (Riesgo Medio)",
    "descripcion": "Sigue el índice S&P 500 de EE.UU.",
    "tipo": "inversion",
    "riesgo": "medio",
    "retorno_anual_estimado": "8.0%"
  }
]

# 2. Portafolios de usuarios (datos de prueba)
# Estructura: { "userId": { "fundId": amount, ... } }
portafolios = {
  "user-123-test": {
    "fondo-003": 50.00,
    "fondo-001": 10.00
  }
}

# 2a. Precios base para simular el mercado
base_prices = {
    "fondo-003": 10.0,  # $10 por unidad
    "fondo-004": 25.0   # $25 por unidad
}

# 2b. unidades (para inversiones) o dinero (para donaciones)
portfolios = {
  "user-123-test": {
    "fondo-003": 5.0,  # 5 unidades
    "fondo-001": 10.0  # $10 donados
  }
}



# --- Simulación de Mercado ---
def get_current_price(fundId):
    """
    Simula un precio de mercado que fluctúa ligeramente.
    Para la demo, ¡hacemos que siempre suba un poquito!
    """
    if fundId not in base_prices:
        return 1.0 # Donaciones valen 1
        
    base = base_prices[fundId]
    fluctuacion = random.uniform(-0.015, 0.05)
    new_price = base * (1 + fluctuacion)
    return round(new_price, 4)



# --- Endpoints de la API ---
@app.route('/')
def home():
    """Ruta raíz simple para verificar que la API está viva."""
    return "¡API VIVA!"

# Endpoint A: Obtener todos los fondos
@app.route('/api/funds', methods=['GET'])
def get_funds():
    """
    DEVUELVE: La lista completa de fondos disponibles (catálogo).
    """
    print("Petición recibIDA en GET /api/funds")
    return jsonify(funds)

# Endpoint B: Invertir
@app.route('/api/invest', methods=['POST'])
def invest():
    """
    PROCESA: Una nueva inversión o donación.
    RECIBE (JSON): { "userId": string, "fundId": string, "amount": float }
    DEVUELVE: Un mensaje de confirmación.
    """
    data = request.json
    
    userId = data.get('userId')
    fundId = data.get('fundId')
    amount = data.get('amount')
    
    print(f"Petición POST /api/invest: User {userId}, Fund {fundId}, Amount {amount}")
    
    # Validación
    if not userId or not fundId or not amount:
        return jsonify({"message": "Faltan datos: userId, fundId, o amount"}), 400

    # Buscamos el fondo para saber su tipo
    fund_info = next((f for f in funds if f['id'] == fundId), None)
    if not fund_info:
        return jsonify({"message": "Fondo no encontrado"}), 404
        
    # Crear usuario si no existe
    if userId not in portfolios:
        portfolios[userId] = {}
        
    # Iniciar fondo en 0 si no se encuentra
    if fundId not in portfolios[userId]:
        portfolios[userId][fundId] = 0
        
    # Lógica de compra
    if fund_info['tipo'] == 'inversion':
        # Compramos unidades al precio actual
        current_price = get_current_price(fundId)
        units_bought = amount / current_price
        portfolios[userId][fundId] += units_bought
        print(f"Inversión: {amount} USD a ${current_price}/unidad. Compró {units_bought} unidades.")
    else:
        # Donaciones solo suman el dinero
        portfolios[userId][fundId] += amount
        print(f"Donación: {amount} USD.")
    
    print("Portafolios actualizados:", portfolios)
    
    return jsonify({
        "message": "Inversión registrada con éxito"
    }), 201


# Endpoint C: Obtener el portafolio de un usuario
@app.route('/api/portfolio/<string:userId>', methods=['GET'])
def get_portfolio(userId):
    """
    DEVUELVE: El portafolio detallado de un usuario, con valores
             calculados en tiempo real.
    """
    print(f"Petición GET /api/portfolio para el usuario: {userId}")
    
    user_portfolio = portfolios.get(userId)
    
    if not user_portfolio:
        # Si el usuario es nuevo y no tiene portafolio, regresamos uno vacío
        return jsonify({
            "userId": userId,
            "totalGeneral": 0,
            "totalInvertido": 0,
            "totalDonado": 0,
            "inversiones": [],
            "donaciones": []
        })
        
    # Procesamos el portafolio para dar un buen formato de respuesta
    total_invested = 0
    total_donated = 0
    investments = []
    donations = []
    
    # Iteramos sobre los fondos que el usuario posee
    for fundId, value in user_portfolio.items():
        # Buscamos la info del fondo
        fund_info = next((f for f in funds if f['id'] == fundId), None)
        
        if fund_info:
            current_value = 0
            
            if fund_info['tipo'] == 'inversion':
                # Calculamos el valor actual en tiempo real
                units_held = value
                current_price = get_current_price(fundId)
                current_value = units_held * current_price # Valor actual
                
                item = {
                    "fundId": fundId,
                    "nombre": fund_info['nombre'],
                    "amount": round(current_value, 2), # Valor en dinero
                    "units": round(units_held, 6)
                }
                investments.append(item)
                total_invested += current_value
                
            elif fund_info['tipo'] == 'donacion':
                current_value = value
                item = {
                    "fundId": fundId,
                    "nombre": fund_info['nombre'],
                    "amount": round(current_value, 2)
                }
                donations.append(item)
                total_donated += current_value

    # Enviamos la respuesta
    return jsonify({
        "userId": userId,
        "totalGeneral": round(total_invested + total_donated, 2),
        "totalInvertido": round(total_invested, 2),
        "totalDonado": round(total_donated, 2),
        "inversiones": investments,
        "donaciones": donations
    })

# --- Iniciar el servidor ---
if __name__ == '__main__':
    app.run(debug=True, port=5000)