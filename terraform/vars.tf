variable "gitlab_count" {
  default     = "2"
  description = "Number of gitlab runners"
}

variable "private_subnet_cidr_block" {
  default     = "172.16.100.0/24"
  description = "Private subnet cidr block"
}

variable "trusted_subnet_cidr_blocks" {
  default     = []
  description = "Trusted IP addresses"
}

variable "gitlab_token" {
  description = "PROJECT_REGISTRATION_TOKEN"
}

variable "webhook_secret" {
  description = "Shared secret for authenticating webhook calls"
}

variable "gitlab_api_token" {
  description = "Gitlab API key"
}
