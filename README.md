# pd-az-task – Azure-Umgebung mit Terraform

Terraform-Projekt für eine kleine Azure-Umgebung: VNet, AKS (1 Node), Key Vault und Storage Account.
Key Vault und Storage sind über **Private Endpoints** aus dem VNet privat erreichbar.
Deployed wird über **GitHub Actions** ohne gespeicherte Secrets (OIDC), Apply nur nach manueller Freigabe.

Rollenspezifische Erweiterung: **Variante B – Cloud Engineer** (siehe [Konzept](#konzept-variante-b)).

## Projektstruktur

```
.
├── bootstrap/          # Einmalig: zentraler State-Storage + Identität für GitHub Actions
├── modules/
│   ├── network/        # VNet, AKS-Subnet, Private-Endpoint-Subnet + NSG, Private DNS Zones
│   ├── key-vault/      # Key Vault (RBAC) + Private Endpoint
│   ├── storage/        # Storage Account + Container + Private Endpoint
│   └── aks/            # AKS Cluster + Cluster-Identität
├── infra/              # Root-Modul: ruft die Module auf (State im Container infra)
├── k8s/                # Demo-Pod für Workload Identity
└── .github/workflows/  # Pipeline: plan → Freigabe → apply, täglicher Drift-Check
```

### Begründung der Modul-Aufteilung

- **Ein Modul pro Baustein** (Netzwerk, Key Vault, Storage, AKS). Jedes Modul ist für sich verständlich
  und testbar. Key Vault und Storage bringen ihren Private Endpoint selbst mit.
- **`infra/` setzt die Module zusammen** und enthält alle Werte (`terraform.auto.tfvars`).
  Die Aufgabe verlangt eine Umgebung (dev), daher gibt es bewusst nur ein Root-Modul. Weitere Umgebungen
  ließen sich mit denselben Modulen und eigenem State ergänzen.
- **`bootstrap/` ist getrennt**, weil der State-Storage nicht von der Infrastruktur verwaltet werden darf,
  deren State er speichert. Ein `destroy` in `infra/` darf den State-Storage nicht löschen.

### Wichtige Entscheidungen

| Anforderung | Umsetzung |
|---|---|
| Remote Backend | Azure Storage Account mit je einem Container für `bootstrap` und `infra` (Pipeline hat nur Zugriff auf `infra`), Login per Entra ID (`use_azuread_auth`), keine Access Keys, Versionierung aktiv |
| Konfigurierbarkeit | Alle Werte über `variables.tf` / `terraform.auto.tfvars` |
| Keine Secrets im Code | Passwort als `ephemeral` `random_password` erzeugt und per write-only `value_wo` in den Key Vault geschrieben: steht weder im Code noch im Plan oder State. Pipeline-Login über OIDC, in GitHub liegen nur IDs |
| Private Kommunikation | Private Endpoints im eigenen Subnet, Private DNS Zones mit VNet-Link: Im VNet löst `<name>.vault.azure.net` auf eine private IP auf |
| NSG | Auf dem Private-Endpoint-Subnet: nur HTTPS aus dem AKS-Subnet erlaubt |
| RBAC | Key Vault im RBAC-Modus, AKS-Login nur über Entra ID, Pods über Workload Identity mit minimalen Rollen |

Der öffentliche Endpunkt des **Key Vaults** bleibt an, weil die GitHub-Runner dort das Secret schreiben
(laut Aufgabe erlaubt). Zugriff gibt es trotzdem nur mit Entra-Login und passender Rolle.
Der **Storage Account** ist ausschließlich über seinen Private Endpoint erreichbar.

## Ausführungsanleitung

**Voraussetzungen:** Terraform ≥ 1.11, Azure CLI, kubectl, kubelogin, `az login`

### 1. Bootstrap (einmalig, lokal)

```bash
cd bootstrap
terraform init
terraform apply
terraform output
```

Danach den State in den neuen Storage migrieren: In `bootstrap/versions.tf` den `backend`-Block
einkommentieren, den Storage-Namen eintragen und `terraform init -migrate-state` ausführen.

### 2. Backend für `infra/` eintragen

Den Output `tfstate_storage_account_name` in `infra/versions.tf` bei `storage_account_name` eintragen.

### 3. GitHub einrichten

- **Settings → Secrets and variables → Actions → Variables:** `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`,
  `AZURE_SUBSCRIPTION_ID` (Werte aus dem Bootstrap-Output)
- **Settings → Environments → `dev` anlegen:** *Required reviewers* = du selbst.
  **Vor dem ersten Push anlegen:** Sonst erstellt GitHub das Environment beim ersten Lauf automatisch
  ohne Freigabe-Regel, und der Apply läuft ungeprüft durch.

### 4. Deployen

Push auf `main` → Job `plan` läuft → Job `apply` wartet auf Freigabe (*Review deployments*) → Apply.

Alternativ lokal:

```bash
cd infra
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 5. Prüfen: privater Zugriff aus dem Cluster

```bash
cd infra
$(terraform output -raw kubectl_config_command)
export WORKLOAD_CLIENT_ID=$(terraform output -raw workload_client_id)
KV=$(terraform output -raw key_vault_name)
ST=$(terraform output -raw storage_account_name)
envsubst < ../k8s/workload-identity-demo.yaml | kubectl apply -f -
kubectl -n demo wait --for=condition=Ready pod/demo-app --timeout=180s

# DNS: vom Laptop öffentliche IP, im Cluster private IP (10.0.2.x)
nslookup $KV.vault.azure.net
kubectl -n demo exec demo-app -- getent hosts $KV.vault.azure.net $ST.blob.core.windows.net

# Login ohne Secret (Workload Identity)
kubectl -n demo exec demo-app -- sh -c 'az login --service-principal -u $AZURE_CLIENT_ID -t $AZURE_TENANT_ID --federated-token "$(cat $AZURE_FEDERATED_TOKEN_FILE)" -o none'

# Secret lesen (über den Private Endpoint)
kubectl -n demo exec demo-app -- az keyvault secret show --vault-name $KV -n demo-db-password --query name -o tsv

# Blob hochladen: klappt nur aus dem VNet, da der Storage keinen öffentlichen Zugriff erlaubt
kubectl -n demo exec demo-app -- sh -c "echo hello > /tmp/hello.txt && az storage blob upload --auth-mode login --account-name $ST -c data -n hello.txt -f /tmp/hello.txt --overwrite -o none"
kubectl -n demo exec demo-app -- az storage blob list --auth-mode login --account-name $ST -c data --query "[].name" -o tsv
```

**Kosten sparen:** `az aks stop -g RG-Fatih-Akkoc -n aks-pdaz-dev` (vor der Demo `az aks start`).

## Konzept Variante B

### 1. Drift erkennen und beheben

**Drift** heißt: Die echte Infrastruktur weicht vom Terraform-Code ab, z.B. durch eine manuelle Änderung im Portal.

- **Vorbeugen:** Änderungen laufen nur über die Pipeline. Menschen haben in prod nur Leserechte.
  Für Notfälle gibt es zeitlich begrenzte Admin-Rechte (Entra PIM).
- **Erkennen:** Ein täglicher Cron-Job in der Pipeline führt `terraform plan -detailed-exitcode` aus
  (**umgesetzt**). Exit-Code `2` heißt Abweichung: Der Job schlägt fehl und das Team wird benachrichtigt.
  Ergänzend können Azure-Activity-Log-Alerts Änderungen melden, die nicht von der Pipeline-Identität kommen.
- **Beheben:** Zuerst prüfen, ob die Änderung gewollt war.
  - Nicht gewollt: Pipeline erneut ausführen. `apply` stellt den Zustand aus dem Code wieder her.
  - Gewollt (z.B. Hotfix): Änderung in den Code übernehmen. Der Code bleibt die einzige Wahrheit.
  - Manuell angelegte Ressource: per `import` in Terraform übernehmen oder löschen.

### 2. Secretless Automation in der Pipeline

Ziel: Es gibt kein langlebiges Passwort oder Client Secret, das geleakt werden oder ablaufen kann.

- **Workload Identity Federation (umgesetzt):** GitHub stellt pro Job ein kurzlebiges OIDC-Token aus.
  Azure vertraut diesem Token über ein *Federated Credential* auf einer Managed Identity und gibt
  dafür ein Azure-Token aus, das etwa 1 Stunde gilt. In GitHub stehen nur Client-, Tenant- und Subscription-ID.
- **Eng begrenzt:** Das Federated Credential gilt nur für dieses Repo und nur für den `main`-Branch bzw.
  das Environment `dev`. Das Environment verlangt eine manuelle Freigabe.
- **Least Privilege:** Die Pipeline-Identität hat Rechte nur auf der Resource Group. Pro Umgebung gäbe es
  eine eigene Identität, prod-Rechte also nur im prod-Workflow.
- **Keine Secrets:** Der State-Zugriff läuft über Entra ID statt Storage Keys. Pods im Cluster
  nutzen ebenfalls Workload Identity statt gespeicherter Credentials.
