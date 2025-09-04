# Конфігурація для тестування
# Базова інфраструктура + Kubernetes + База даних

modules_config = {
  s3_backend = true   # Необхідно для стейту
  vpc        = true   # Базова мережа
  ecr        = true   # Для контейнерів
  eks        = true   # Kubernetes для тестів
  jenkins    = true   # CI/CD пайплайни 
  argo_cd    = true   # GitOps 
  rds        = false  # База даних для тестів
}
