import os
import json
import datetime
import threading
import logging
import requests
from flask import Flask, request, jsonify, g, has_request_context
from google.cloud import pubsub_v1, storage
from werkzeug.utils import secure_filename

# Logging con request_id
# Configuración del logger
class RequestIdFilter(logging.Filter):
    def filter(self, record):
        if has_request_context():
            record.request_id = getattr(g, "request_id", "-")
        else:
            record.request_id = "-"
        return True
logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s [%(threadName)s] [ID:%(request_id)s] %(message)s"
)
logger = logging.getLogger(__name__)
logger.addFilter(RequestIdFilter())

app = Flask(__name__)

# Variables de entorno
SUBSCRIPTION_ID = os.environ.get("GCP_SUBSCRIPTION")
BUCKET_NAME = os.environ.get("BUCKET_NAME")
CREDENTIALS_PATH = "/secrets/credentials.json"
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = CREDENTIALS_PATH

# Middleware para trazabilidad con X-Request-ID
@app.before_request
def inject_request_id():
    g.request_id = request.headers.get("X-Request-ID", os.urandom(6).hex())

    # Evitar log de healthcheck GET /
    if request.method == "GET" and request.path == "/":
        return

    logger.info(f"➡️ Nueva petición: {request.method} {request.path}")


# HelloWorld / Healthcheck XD
@app.route("/")
def hello():
    return "¡Hola Mundo desde GCP Kubernetes!"

# Endpoint para generar una URL firmada de subida a Cloud Storage
@app.route("/upload-url", methods=["POST"])
def generate_upload_url():
    try:
        data = request.get_json()
        filename = data.get("filename")
        content_type = data.get("content_type", "application/octet-stream")

        if not filename:
            logger.warning("❌ Se intentó generar URL sin filename.")
            return jsonify({"error": "filename is required"}), 400

        storage_client = storage.Client()
        bucket = storage_client.bucket(BUCKET_NAME)
        blob = bucket.blob(filename)

        url = blob.generate_signed_url(
            version="v4",
            expiration=datetime.timedelta(minutes=15),
            method="PUT",
            content_type=content_type
        )

        logger.info(f"🔗 URL de subida generada para: {filename}")
        return jsonify({"upload_url": url}), 200

    except Exception as e:
        logger.exception("❌ Error al generar signed URL")
        return jsonify({"error": str(e)}), 500


# Endpoint para subir un archivo a la URL firmada
@app.route("/upload-file", methods=["POST"])
def upload_file_to_signed_url():
    try:
        upload_url = request.form.get("upload_url")
        file = request.files.get("file")

        if not upload_url or not file:
            logger.warning("❌ Faltan 'upload_url' o 'file'")
            return jsonify({"error": "upload_url and file are required"}), 400

        # Nombre seguro para el archivo
        filename = secure_filename(file.filename)

        headers = {"Content-Type": "application/octet-stream"}
        response = requests.put(upload_url, data=file.read(), headers=headers)

        if response.status_code == 200:
            logger.info(f"✅ Archivo '{filename}' subido correctamente.")
            return jsonify({"message": "File uploaded successfully"}), 200
        else:
            logger.error(f"❌ Falló la subida. Código: {response.status_code}")
            logger.error(f"Respuesta: {response.text}")
            return jsonify({"error": "Upload failed", "details": response.text}), 500

    except Exception as e:
        logger.exception("⚠️ Error subiendo archivo")
        return jsonify({"error": str(e)}), 500
    
# Listener de Pub/Sub para recibir notificaciones de subida
def callback(message):
    try:
        data = json.loads(message.data.decode("utf-8"))
        file_name = data.get("name", "(sin nombre)")
        logger.info(f"📁 Evento recibido: archivo subido '{file_name}'")
        message.ack()
    except Exception as e:
        logger.error(f"⚠️ Error procesando mensaje de Pub/Sub: {e}")
        message.nack()

# Iniciar el listener de Pub/Sub en un hilo separado
def start_pubsub_listener():
    try:
        subscriber = pubsub_v1.SubscriberClient()
        future = subscriber.subscribe(SUBSCRIPTION_ID, callback=callback)
        logger.info(f"🔊 Escuchando Pub/Sub en: {SUBSCRIPTION_ID}")
        future.result()
    except Exception as e:
        logger.exception("❌ Listener de Pub/Sub detenido inesperadamente")

# Iniciar el listener de Pub/Sub en un hilo
listener_thread = threading.Thread(
    target=start_pubsub_listener, name="PubSubListener", daemon=True
)
listener_thread.start()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
