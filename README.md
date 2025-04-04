# Évaluation de cours DevOps

Cette application permet de réaliser une évaluation de cours de DevOps en mettant en scène AWS, GitHub Actions, Terraform et Node.js. Elle déploie une fonction Lambda via Terraform, expose cette fonction via une API Gateway, et fournit un tableau de bord CloudWatch pour surveiller les métriques et les logs.

## Fonctionnalités

- Déploiement d'une fonction Lambda sur AWS via Terraform
- Intégration avec API Gateway pour exposer l'API
- Automatisation du déploiement avec GitHub Actions
- Surveillance des métriques et logs avec CloudWatch

## Déploiement et Suppression

Le workflow GitHub Actions automatiquement déploie l'infrastructure sur chaque push vers la branche `main`. Un workflow supplémentaire est disponible pour supprimer l'infrastructure.

