# ☁️ Sterling POC - GCP Infraestructura y Aplicación

Este proyecto despliega una aplicación de prueba ("Sterling") sobre GCP utilizando:

- **GKE (Google Kubernetes Engine)** para la carga principal
- **Cloud Storage** para almacenamiento de archivos
- **Pub/Sub** para eventos de subida
- **Cloud SQL (MySQL)** para persistencia de datos
- **Secret Manager** para manejo seguro de credenciales
- **Terraform** para IaC
- **Flask** para exponer endpoints y listeners de Pub/Sub

---