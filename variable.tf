
variable "enable_s3" {
  description = "Enable ACK s3 add-on"
  type        = bool
  default     = true
}

variable "s3_helm_config" {
  description = "ACK s3 Helm Chart config"
  type        = any
  default     = {}
}


variable "irsa_iam_role_path" {
  description = "IAM role path for IRSA roles"
  type        = string
  default     = "/"
}

variable "irsa_iam_permissions_boundary" {
  description = "IAM permissions boundary for IRSA roles"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "eks cluster information"
  type        = string
  default     = "i2"
}