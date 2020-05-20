provider "google" {
  project         = var.project_id
  region          = var.region
  batching {enable_batching = false}
}

provider "google-beta" {
  project         = var.project_id
  region          = var.region
  batching {enable_batching = false}
}

provider "kubernetes" {
  load_config_file = true
}