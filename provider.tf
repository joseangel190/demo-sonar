terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.48.0"
    }
  }
}

provider "google" {
  project = "compelling-weft-374317"
  credentials = file("~/Descargas/key.json")
  region = "us-east1"
  zone = "us-east1-b"
}
