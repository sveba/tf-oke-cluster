variable "budget_alarm_email" {
  description = "Email for budget cost alarms"
  type        = string
}

variable "compartment_id" {
  type        = string
  description = "The compartment to create the resources in"
}

variable "ssh_public_key" {
  description = "SSH Public Key used to access all instances"
  type        = string
}

variable "oci_profile_name" {
  description = "Profile name in oci-config file (~/.oci/config)"
  type        = string
  default     = "DEFAULT"
}

variable "region" {
  description = "OCI region"
  type        = string
  default     = "eu-frankfurt-1"
}

variable "k8s_node_pool_size" {
  description = "Number of Kubernetes Worker Nodes"
  type        = number
  default     = 2
}

variable "k8s_cluster_name" {
  description = "Kubernetes Cluster Name"
  type        = string
  default     = "k8s-cluster"
}
  
variable "k8s_node_pool_name" {
  description = "Kubernetes Node Pool Name"
  type        = string
  default     = "k8s-node-pool"
}

variable "k8s_pods_cidr" {
  description = "Kubernetes Pods CIDR"
  type        = string
  default     = "10.244.0.0/16"
}

variable "k8s_services_cidr" {
  description = "Kubernetes Services CIDR"
  type        = string
  default     = "10.96.0.0/16"
}

variable "k8s_node_shape" {
  description = "OCI Compute Shape for the Kubernetes Worker Nodes"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "vcn_private_subnet_cidr" {
  description = "VCN Private Subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vcn_public_subnet_cidr" {
  description = "VCN Public Subnet CIDR"
  type        = string
  default     = "10.0.0.0/24"
}