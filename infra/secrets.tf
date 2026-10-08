# Beispiel-Secret, das weder im Code noch im Plan oder State steht:
# - ephemeral: Passwort existiert nur während des Terraform-Laufs im Speicher
# - value_wo (write-only): wird an den Key Vault gesendet, aber nie gespeichert
# - value_wo_version: nur wenn sich die Version ändert, wird ein neues
#   Passwort geschrieben (Rotation = inkrementierte Versionsnummer)
ephemeral "random_password" "demo_db" {
  length  = 32
  special = true
}

resource "azurerm_key_vault_secret" "demo_db_password" {
  name             = "demo-db-password"
  value_wo         = ephemeral.random_password.demo_db.result
  value_wo_version = var.demo_secret_version
  key_vault_id     = module.key_vault.id
}
