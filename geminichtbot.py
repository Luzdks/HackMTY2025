import os
import requests
import time
from bs4 import BeautifulSoup
import google.generativeai as genai

# --- CONFIGURACIÓN GEMINI ---
GOOGLE_API_KEY = ""  # Reemplaza con tu API key de Google AI Studio

try:
    genai.configure(api_key=GOOGLE_API_KEY)
    if not GOOGLE_API_KEY or "TU_API_KEY" in GOOGLE_API_KEY:
        print("Error: La clave de API de Gemini no ha sido configurada correctamente.")
        print("Por favor, obtén una API key en: https://aistudio.google.com/")
        exit()
except Exception as e:
    print(f"Error al configurar la API de Google Gemini: {e}")
    exit()

def es_pregunta_valida(pregunta_usuario):
    """
    Usa la IA para clasificar si la pregunta del usuario pertenece a los temas permitidos.
    Devuelve True si es válida, False si no lo es.
    """
    print("🧠 Verificando si el tema es válido...")
    model = genai.GenerativeModel('gemini-2.5-pro')
    
    prompt_clasificador = f"""
    Eres un clasificador de temas estricto. Tu única función es decidir si la pregunta de un usuario pertenece a una de las siguientes categorías permitidas.
    
    Categorías Permitidas:
    1. Finanzas personales: CETES, inversiones seguras, ahorro, cajas de ahorro, Afores, planes de retiro.
    2. Educación financiera: Cómo funciona el dinero, inflación, tasas de interés, cómo empezar a invertir de forma segura.
    3. Gasto y finanzas de organizaciones ambientales: Presupuesto, ingresos, gastos o reportes financieros de organizaciones grandes y confiables como WWF, Greenpeace, UICN, The Nature Conservancy, etc.
    
    Analiza la siguiente pregunta del usuario. Responde ÚNICAMENTE con la palabra "SI" si la pregunta pertenece a alguna de las categorías permitidas, o "NO" si no pertenece. No des explicaciones.
    
    Pregunta del usuario: "{pregunta_usuario}"
    
    Tu respuesta (SI/NO):
    """
    
    try:
        response = model.generate_content(prompt_clasificador)
        respuesta_ia = response.text.strip().upper()
        
        if respuesta_ia == "SI":
            print("✅ Tema válido. Procediendo a investigar.")
            return True
        else:
            print("❌ Tema no válido.")
            return False
    except Exception as e:
        print(f"Error durante la clasificación del tema: {e}")
        return False

def buscar_en_google(query, num_results=5):
    """
    Función principal de búsqueda usando DuckDuckGo.
    Devuelve una lista de URLs.
    """
    print(f"🔎 Buscando: '{query}'")
    
    # Intentamos con scraping directo de DuckDuckGo
    resultados = buscar_con_duckduckgo_directo(query, num_results)
    
    # Si no funciona, intentamos con Bing como fallback
    if not resultados:
        print("⚠️  Intentando método alternativo...")
        resultados = buscar_con_bing(query, num_results)
    
    return resultados

def buscar_con_duckduckgo_directo(query, num_results=5):
    """Scraping directo de DuckDuckGo"""
    try:
        print("  🔄 Buscando en DuckDuckGo...")
        url = "https://html.duckduckgo.com/html/"
        params = {'q': query, 'kl': 'es-es'}
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Origin': 'https://html.duckduckgo.com',
            'Referer': 'https://html.duckduckgo.com/',
        }
        
        response = requests.post(url, data=params, headers=headers, timeout=15)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.text, 'html.parser')
        resultados = []
        
        # Buscar enlaces de resultados
        links = soup.find_all('a', class_='result__a')
        
        for link in links:
            href = link.get('href')
            if href:
                # DuckDuckGo usa redirecciones, extraemos la URL real
                if 'uddg=' in href:
                    from urllib.parse import parse_qs, urlparse
                    parsed = urlparse(href)
                    query_params = parse_qs(parsed.query)
                    if 'uddg' in query_params:
                        real_url = query_params['uddg'][0]
                        resultados.append(real_url)
                elif href.startswith('http') and 'duckduckgo.com' not in href:
                    resultados.append(href)
            
            if len(resultados) >= num_results:
                break
        
        print(f"  ✅ Encontrados {len(resultados)} resultados")
        return resultados
        
    except Exception as e:
        print(f"❌ Error en DuckDuckGo: {e}")
        return []

def buscar_con_bing(query, num_results=5):
    """Búsqueda alternativa en Bing"""
    try:
        print("  🔄 Buscando en Bing...")
        url = "https://www.bing.com/search"
        params = {'q': query, 'count': num_results}
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        }
        
        response = requests.get(url, params=params, headers=headers, timeout=15)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.text, 'html.parser')
        resultados = []
        
        # Buscar resultados en Bing
        links = soup.find_all('li', class_='b_algo')
        
        for link in links:
            a_tag = link.find('a')
            if a_tag and a_tag.get('href'):
                resultados.append(a_tag['href'])
            if len(resultados) >= num_results:
                break
        
        print(f"  ✅ Encontrados {len(resultados)} resultados en Bing")
        return resultados
        
    except Exception as e:
        print(f"❌ Error en Bing: {e}")
        return []

def extraer_texto_de_url(url):
    """Extrae el texto principal de una página web."""
    print(f"  📄 Leyendo: {url[:80]}...")
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3',
        }
        response = requests.get(url, headers=headers, timeout=15)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Eliminar elementos no deseados
        for element in soup(['script', 'style', 'nav', 'header', 'footer', 'aside']):
            element.decompose()
        
        # Extraer texto de párrafos y elementos de texto
        textos = []
        
        # Intentar encontrar el contenido principal
        main_content = soup.find('main') or soup.find('article') or soup.find('div', class_=lambda x: x and ('content' in x or 'main' in x or 'post' in x))
        
        if main_content:
            parrafos = main_content.find_all(['p', 'h1', 'h2', 'h3', 'li'])
        else:
            parrafos = soup.find_all(['p', 'h1', 'h2', 'h3'])
        
        for elemento in parrafos:
            texto = elemento.get_text().strip()
            if len(texto) > 30:  # Filtrar textos muy cortos
                textos.append(texto)
        
        texto_completo = ' '.join(textos)
        
        if len(texto_completo) < 100:
            return None
            
        return texto_completo
        
    except Exception as e:
        print(f"  ❌ No se pudo extraer texto. Error: {e}")
        return None

def generar_respuesta_con_gemini(contexto, pregunta, fuentes):
    """Usa el modelo Gemini para generar una respuesta basada en el contexto."""
    print("🤖 Generando respuesta final con Gemini...")
    model = genai.GenerativeModel('gemini-2.5-pro')
    
    prompt = f"""
    Eres un asistente especializado en finanzas y medio ambiente. Basado EXCLUSIVAMENTE en el contexto proporcionado, responde la pregunta del usuario de forma clara, concisa y bien estructurada.

    INSTRUCCIONES:
    1. Resume la información más relevante del contexto
    2. Sé objetivo y basado en hechos
    3. No inventes información que no esté en el contexto
    4. Si la información es contradictoria entre fuentes, menciónalo
    5. Estructura la respuesta de forma fácil de leer

    --- CONTEXTO EXTRAÍDO DE INTERNET ---
    {contexto}
    --- FIN DEL CONTEXTO ---

    PREGUNTA DEL USUARIO: "{pregunta}"

    Proporciona una respuesta bien estructurada que incluya:
    - Un resumen ejecutivo
    - Puntos clave
    - Conclusiones principales

    RESPUESTA:
    """
    
    try:
        response = model.generate_content(prompt)
        respuesta = response.text
        
        # Añadir sección de fuentes
        respuesta += f"\n\n---\n**Fuentes consultadas:**\n"
        for i, fuente in enumerate(fuentes, 1):
            respuesta += f"{i}. {fuente}\n"
            
        return respuesta
        
    except Exception as e:
        return f"❌ Error al generar la respuesta con Gemini: {e}"

def chatbot_especializado():
    """Función principal del chatbot temático."""
    print("\n" + "="*60)
    print("           🤖 CHATBOT ESPECIALIZADO")
    print("="*60)
    print("\nPuedo responder preguntas sobre:")
    print("  • 📊 Finanzas personales: CETES, inversiones, ahorro, Afores")
    print("  • 🎓 Educación financiera: inflación, tasas de interés")
    print("  • 🌍 Finanzas de organizaciones ambientales: WWF, Greenpeace, etc.")
    print("\nEscribe 'salir' para terminar la conversación.")
    print("="*60)
    
    while True:
        pregunta_usuario = input("\n🧐 ¿Cuál es tu duda financiera o ambiental?: ").strip()
        
        if pregunta_usuario.lower() in ['salir', 'exit', 'quit']:
            print("\n¡Gracias por usar el chatbot! Hasta luego 👋")
            break
            
        if not pregunta_usuario:
            print("❌ Por favor, escribe una pregunta.")
            continue

        # Validar tema
        if not es_pregunta_valida(pregunta_usuario):
            print("\n" + "="*50)
            print("❌ Lo siento, solo puedo responder preguntas sobre:")
            print("   • Finanzas personales y educación financiera")
            print("   • Finanzas de organizaciones ambientales")
            print("="*50)
            continue

        # Buscar información
        print("\n🔄 Procesando tu pregunta...")
        urls = buscar_en_google(pregunta_usuario)
        
        if not urls:
            print("❌ No se encontraron resultados relevantes para tu búsqueda.")
            continue

        # Extraer y procesar contenido
        print(f"\n📖 Analizando {len(urls)} fuentes encontradas...")
        contexto_total = ""
        fuentes_usadas = []
        
        for i, url in enumerate(urls, 1):
            print(f"  {i}/{len(urls)} Extrayendo contenido...")
            texto = extraer_texto_de_url(url)
            if texto:
                contexto_total += f"--- FUENTE {i} ---\n{texto}\n\n"
                fuentes_usadas.append(url)
            time.sleep(1)  # Delay para ser respetuoso con los servidores

        if not contexto_total.strip():
            print("❌ No se pudo extraer contenido útil de las fuentes encontradas.")
            continue

        # Generar respuesta
        print(f"✅ Contenido extraído de {len(fuentes_usadas)} fuentes")
        respuesta_final = generar_respuesta_con_gemini(contexto_total, pregunta_usuario, fuentes_usadas)
        
        # Mostrar resultados
        print("\n" + "="*60)
        print("💡 RESPUESTA")
        print("="*60)
        print(respuesta_final)
        print("="*60)

# --- Iniciar el chatbot ---
if __name__ == "__main__":
    try:
        chatbot_especializado()
    except KeyboardInterrupt:
        print("\n\n👋 Programa interrumpido por el usuario. ¡Hasta luego!")
    except Exception as e:
        print(f"\n❌ Error inesperado: {e}")