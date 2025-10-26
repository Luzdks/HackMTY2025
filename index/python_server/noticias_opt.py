from fastapi import FastAPI
import google.generativeai as genai
import feedparser
import json

# --- Configuración ---
GEMINI_API_KEY = "AIzaSyDOVJ4gVXW2Zk_S42Q7cUKI5InwUSj1UzI"
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel('gemini-2.5-flash')

RSS_URL = "https://news.google.com/rss/search?q=medio+ambiente&hl=es-419&gl=MX&ceid=US:es-419"

app = FastAPI(title="Noticias Positivas API")


def fetch_google_news():
    feed = feedparser.parse(RSS_URL)
    return feed.entries if feed.entries else []


def select_top_3_positive_titles_with_gemini(titles_with_dates):
    prompt = f"""
    Recibirás una lista de títulos de noticias sobre medio ambiente con su fecha.
    Tarea:
    1. Identifica las 3 noticias más recientes que sean positivas o constructivas
       (soluciones, recuperación ambiental, tecnologías limpias, etc.).
    2. Devuelve solo un JSON con:
       - "indice": posición en la lista original
       - "titulo": texto del título

    Ejemplo:
    {{
      "noticias_positivas": [
        {{"indice": 2, "titulo": "Nueva tecnología limpia reduce emisiones"}},
        {{"indice": 5, "titulo": "México reforesta zonas afectadas"}},
        {{"indice": 7, "titulo": "Energía solar gana impulso en Latinoamérica"}}
      ]
    }}

    Lista:
    {json.dumps(titles_with_dates, ensure_ascii=False)}
    """

    try:
        response = model.generate_content(prompt)
        cleaned = response.text.strip().replace("```json", "").replace("```", "").strip()
        result = json.loads(cleaned)
        return result.get("noticias_positivas", [])
    except Exception:
        return []


def summarize_article_with_gemini(title, summary_snippet):
    prompt = f"""
    Resume esta noticia sobre el medio ambiente en máximo 2 frases, destacando lo positivo.
    Título: "{title}"
    Resumen: "{summary_snippet}"
    """
    try:
        response = model.generate_content(prompt)
        return response.text.strip().replace("\n", " ")
    except Exception:
        return "Resumen no disponible."


@app.get("/noticias_positivas")
def get_positive_news():
    articles = fetch_google_news()
    if not articles:
        return {"noticias": [], "mensaje": "No se encontraron artículos."}

    titles_with_dates = [
        {
            "indice": i,
            "titulo": entry.title,
            "fecha": getattr(entry, "published", "Desconocida")
        }
        for i, entry in enumerate(articles)
    ]

    selected = select_top_3_positive_titles_with_gemini(titles_with_dates)
    if not selected:
        return {"noticias": [], "mensaje": "No se pudieron identificar noticias positivas."}

    positive_news_list = []
    for s in selected:
        idx = s["indice"]
        entry = articles[idx]
        resumen = summarize_article_with_gemini(entry.title, entry.summary)
        positive_news_list.append({
            "titulo": entry.title,
            "descripcion": resumen,
            "link": entry.link
        })

    return {"noticias": positive_news_list}
