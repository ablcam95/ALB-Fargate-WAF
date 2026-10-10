# AWS Containerized Microservice Infrastructure (Terraform)

Este repositorio contiene la definición de Infraestructura como Código (IaC) para desplegar una arquitectura base serverless en **Amazon Web Services (AWS)**, diseñada bajo patrones de alta disponibilidad y mitigación perimetral de tráfico abusivo.

---

## Resumen Arquitectónico

La solución implementa un desacoplamiento entre la capa de balanceo y la capa de cómputo, aplicando políticas de seguridad en el borde:

* **Edge Protection (AWS WAFv2):** Implementación de un Web Application Firewall con scope regional asociado directamente al balanceador. Incorpora una regla *Rate-Based* configurada con un umbral de **2,000 peticiones por IP** en una ventana móvil de 5 minutos, bloqueando automáticamente el tráfico anómalo y registrando telemetría en **Amazon CloudWatch**.
* **Traffic Ingress (AWS ALB):** Application Load Balancer aprovisionado sobre subredes públicas para la gestión y distribución uniforme del tráfico entrante.
* **Compute Layer (Amazon ECS & AWS Fargate):** Clúster y servicio gestionado en modalidad serverless con una capacidad base de 2 réplicas (`desired_count = 2`), abstrayendo la administración de la infraestructura subyacente y optimizando el aprovisionamiento de tareas de contenedor.

---

## Especificaciones Técnicas

| Componente | Tipo / Recurso | Configuración Clave |
| :--- | :--- | :--- |
| **Edge Security** | `aws_wafv2_web_acl` | Acción por defecto: `ALLOW` \| Regla: Rate-Limit (2000 req/IP) con acción `BLOCK` |
| **Load Balancing** | `aws_lb` | Tipo: `application` \| Alta disponibilidad Multi-AZ |
| **Compute Engine** | `aws_ecs_cluster` / `aws_ecs_service` | Launch Type: `FARGATE` \| Replicación: 2 tareas |
| **Monitoring** | Amazon CloudWatch Metrics | Muestreo y métricas activas para `rate` y `rate-acl` |
