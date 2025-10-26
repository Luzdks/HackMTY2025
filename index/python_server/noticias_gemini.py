import google.generativeai as genai
import feedparser
import json
import os

# --- Configuración ---
# 1. Pega tu API Key de Gemini aquí
# ¡IMPORTANTE! Nunca compartas esta clave. 
# Mejor usar una variable de entorno (os.environ.get)
GEMINI_API_KEY = "AIzaSyDOVJ4gVXW2Zk_S42Q7cUKI5InwUSj1UzI"

# 2. Configura el modelo de Gemini
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel('gemini-2.5-pro')

# 3. URL del Feed RSS de Google News
# Buscamos "buenas noticias medio ambiente" o "soluciones cambio climatico"
# hl=es (español), gl=MX (México). Puedes cambiar 'gl' a tu país (US, CO, ES, AR)
RSS_URL = "https://news.google.com/rss/search?q=medio+ambiente&hl=es-419&gl=MX&ceid=US:es-419"

# --- Funciones ---

def fetch_google_news():
    """Obtiene las noticias del feed RSS de Google."""
    print(f"Buscando noticias en Google News RSS...")
    feed = feedparser.parse(RSS_URL)
    
    if not feed.entries:
        print("No se encontraron noticias en el feed.")
        return []
        
    print(f"Se encontraron {len(feed.entries)} artículos. Analizando...")
    return feed.entries

def analyze_and_summarize_with_gemini(title, summary_snippet):
    """
    Usa Gemini para analizar si una noticia es positiva y crear un nuevo resumen.
    """
    
    # 1. El prompt es clave. Le pedimos a Gemini que actúe como un filtro
    # y que responda en formato JSON para poder leerlo fácilmente.
    prompt = f"""
    Analiza el siguiente artículo de noticias (basado en su título y resumen).
    Tu tarea es doble:
    1. Determina si la noticia es GENUINAMENTE POSITIVA o constructiva sobre el medio ambiente (ej. habla de soluciones, recuperación, nuevas tecnologías limpias, etc.).
    2. Que sean del 2025 en adelante
    3. Si ES positiva, crea un nuevo resumen corto y atractivo (máximo 2 frases).
    
    Responde SÓLO con un objeto JSON.
    - Si es positiva o neutral, usa esta estructura: 
    {{"es_positiva": true, "nuevo_resumen": "Tu resumen aquí..."}}
    
    - Si NO es positiva ( negativa, o un 'greenwashing' vago), usa esta estructura:
    {{"es_positiva": false, "nuevo_resumen": null}}
    
    Artículo:
    Título: "{title}"
    Resumen: "{summary_snippet}"
    """
    
    try:
        # 2. Hacemos la llamada a la API
        response = model.generate_content(prompt)
        
        # 3. Limpiamos la respuesta y la convertimos de texto a JSON
        # A veces Gemini envuelve el JSON en ```json ... ```
        cleaned_response = response.text.strip().replace("```json", "").replace("```", "").strip()
        
        result_json = json.loads(cleaned_response)
        return result_json

    except Exception as e:
        print(f"  Error al procesar con Gemini: {e}")
        return {"es_positiva": False, "nuevo_resumen": None}

# --- Función Principal ---

def main():
    # 1. Obtenemos todas las noticias
    articles = fetch_google_news()
    
    positive_news_list = []
    
    for entry in articles:
        title = entry.title
        link = entry.link
        # El 'summary' de RSS suele ser un snippet HTML, lo usamos tal cual
        summary_snippet = entry.summary
        
        print(f"\nAnalizando: {title}")
        
        # 2. Enviamos a Gemini para filtrar y resumir
        analysis = analyze_and_summarize_with_gemini(title, summary_snippet)
        
        # 3. Si Gemini dice que es positiva, la guardamos
        if analysis and analysis.get("es_positiva"):
            print(f"  -> ¡Noticia positiva encontrada!")
            
            
            # 4. Guardamos los datos limpios
            positive_news_list.append({
                "titulo": title,
                "descripcion": analysis.get("nuevo_resumen"),
                "link": link,
            })
        else:
            print(f"  -> Noticia descartada (neutral o negativa).")

    # 4. Imprimimos el resultado final
    print("\n--- RESULTADO FINAL: NOTICIAS POSITIVAS DE MEDIO AMBIENTE ---")
    if not positive_news_list:
        print("No se encontraron noticias positivas en esta búsqueda.")
    
    for i, news in enumerate(positive_news_list, 1):
        print(f"\nNoticia #{i}")
        print(f"  Título: {news['titulo']}")
        print(f"  Descripción: {news['descripcion']}")
        print(f"  Link: {news['link']}")

if __name__ == "__main__":
    main()