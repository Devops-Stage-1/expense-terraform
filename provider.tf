provider "vault" {
  address         = "https://vault-internal.dkdevops.online:8200"
  token           = var.vault_token
  skip_tls_verify = true
}