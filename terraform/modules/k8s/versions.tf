terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.87.0"
    }
  }
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket   = "std-031-05-tf"
    region   = "ru-central1-a"
    key      = "terraform.tfstate"
    
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}