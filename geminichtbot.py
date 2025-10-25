import google.generativeai as genai
import os

API_KEY = "" 
genai.configure(api_key=API_KEY)

# --- Creación del Modelo ---
model = genai.GenerativeModel('gemini-2.5-pro')

# --- Iniciar el Chat ---
chat = model.start_chat(history=[])

print("🤖 ¡Hola! Soy Gemini. Puedes empezar a chatear conmigo.")
print("   Escribe 'salir' o 'exit' para terminar la conversación.\n")

# --- Bucle de Conversación ---
while True:
    # Obtener la entrada del usuario
    user_input = input("Tú: ")

    if user_input.lower() in ['salir', 'exit']:
        print("🤖 ¡Adiós! Que tengas un buen día.")
        break

    try:
        # Enviar el mensaje al modelo
        response = chat.send_message(user_input)

        # Imprimir la respuesta del modelo
        print(f"Gemini: {response.text}\n")

    except Exception as e:
        print(f"Error al enviar el mensaje: {e}")
        print("Intenta de nuevo.")