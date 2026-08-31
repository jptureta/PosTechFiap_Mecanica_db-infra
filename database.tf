# ─────────────────────────────────────────────────────────────
# Banco de dados PostgreSQL 16 provisionado dentro do cluster
# Recursos: Namespace, Secret, StatefulSet (com volume
# persistente) e Service.
# ─────────────────────────────────────────────────────────────

resource "kubernetes_namespace" "oficina" {
  metadata {
    name = var.namespace
  }
}

# Credenciais do banco — o valor da senha vem de variável Terraform
# (nunca commitada; ver terraform.tfvars.example e o README).
resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = kubernetes_namespace.oficina.metadata[0].name
  }

  # Consumido apenas pelo pod do Postgres. A aplicação usa o Secret
  # oficina-secret (em /k8s) — DB_USER/DB_PASSWORD de lá devem bater com
  # os valores definidos aqui (terraform.tfvars).
  data = {
    POSTGRES_DB       = var.db_name
    POSTGRES_USER     = var.db_user
    POSTGRES_PASSWORD = var.db_password
  }

  type = "Opaque"
}

# StatefulSet garante identidade estável e volume persistente por pod —
# o padrão recomendado para bancos de dados em Kubernetes.
resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.oficina.metadata[0].name
    labels = {
      app = "postgres"
    }
  }

  spec {
    service_name = "db"
    replicas     = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:16-alpine"

          port {
            container_port = 5432
            name           = "postgres"
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.db_credentials.metadata[0].name
            }
          }

          # PGDATA em subdiretório evita conflito com lost+found do volume
          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
          }

          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          readiness_probe {
            exec {
              command = ["pg_isready", "-U", var.db_user, "-d", var.db_name]
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          liveness_probe {
            exec {
              command = ["pg_isready", "-U", var.db_user, "-d", var.db_name]
            }
            initial_delay_seconds = 30
            period_seconds        = 15
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "postgres-data"
      }

      spec {
        access_modes = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = var.db_storage_size
          }
        }
      }
    }
  }
}

# Service interno chamado "db" — mesmo nome usado no ConfigMap da aplicação
# (DB_HOST: "db"), então a API conecta sem nenhuma alteração nos manifestos.
resource "kubernetes_service" "postgres" {
  metadata {
    name      = "db"
    namespace = kubernetes_namespace.oficina.metadata[0].name
    labels = {
      app = "postgres"
    }
  }

  spec {
    selector = {
      app = "postgres"
    }

    port {
      port        = 5432
      target_port = 5432
    }

    type = "ClusterIP"
  }
}
