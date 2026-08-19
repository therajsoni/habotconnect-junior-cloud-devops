# HabotConnect — Junior Cloud & DevOps Engineer Hiring Project

**Candidate:** Raj Soni
**Position:** Junior Cloud & DevOps Engineer (GCP / Django / React)

---

## 1. Project Overview

This project simulates a production staging scenario for HabotConnect's
Django REST Framework and React platform running on Google Cloud Platform.

The solution focuses on:

1. Secure Infrastructure-as-Code using Terraform
2. Fail-Closed CI/CD quality and security gates
3. Deterministic student onboarding validation
4. Schema mapping for downstream analytics
5. Data protection and least-privilege access

---

## 2. Architecture

```text
                    Developer
                        |
                        v
                 GitHub Repository
                        |
                        v
              GitHub Actions Pipeline
                        |
          +-------------+-------------+
          |             |             |
       Format         Lint       Secret Scan
          |             |             |
          +-------------+-------------+
                        |
                        v
                 Terraform Validate
                        |
                        v
                  Trivy Security
                        |
              +---------+---------+
              |                   |
             FAIL                PASS
              |                   |
              v                   v
        Deployment STOP       Build Allowed


Incoming Student JSON
          |
          v
    Django REST Framework
          |
          v
      Serializer
          |
          v
   Strict Validation
          |
          v
     DCYN Decision
          |
          v
    D0 / D1 Data Flow
          |
     +----+----+
     |         |
    GCS    BigQuery
    D0        D1
              |
              v
       Row-Level Security
```
