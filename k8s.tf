locals {
  k8s_available_versions = jsonencode(data.oci_containerengine_node_pool_option.node_pool_options.kubernetes_versions)
  available_oke_images = jsonencode(data.oci_containerengine_node_pool_option.node_pool_options.sources)
  k8s_version=jsondecode(data.jq_query.latest_k8s_version.result)
  node_pool_image_id=jsondecode(data.jq_query.latest_image.result)
}

resource "oci_containerengine_cluster" "k8s_cluster" {
  compartment_id     = var.compartment_id
  kubernetes_version = local.k8s_version
  name               = var.k8s_cluster_name
  vcn_id             = module.vcn.vcn_id
  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.vcn_public_subnet.id
  }
  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }
    kubernetes_network_config {
      pods_cidr     = var.k8s_pods_cidr
      services_cidr = var.k8s_services_cidr
    }
    service_lb_subnet_ids = [oci_core_subnet.vcn_public_subnet.id]
  }
}

data "oci_containerengine_node_pool_option" "node_pool_options" {
  node_pool_option_id = "all"
  compartment_id      = var.compartment_id
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengaboutk8sversions.htm
data "jq_query" "latest_k8s_version" {
    data = local.k8s_available_versions
    query = ". | last"
}

data "jq_query" "latest_image" {
    data = local.available_oke_images
    query = "[.[] | select(.source_name | test(\".*aarch.*OKE-${replace(local.k8s_version,"v","")}.*\")?) .image_id] | first"
}

resource "oci_containerengine_node_pool" "k8s_node_pool" {
  cluster_id         = oci_containerengine_cluster.k8s_cluster.id
  compartment_id     = var.compartment_id
  kubernetes_version = local.k8s_version
  name               = var.k8s_node_pool_name

  node_metadata = {
    user_data = base64encode(file("${path.module}/files/node-pool-init.sh"))
  }

  node_config_details {
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.vcn_private_subnet.id
    }

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
      subnet_id           = oci_core_subnet.vcn_private_subnet.id
    }

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2].name
      subnet_id           = oci_core_subnet.vcn_private_subnet.id
    }

    size = var.k8s_node_pool_size
  }

  node_shape = var.k8s_node_shape

  node_shape_config {
    memory_in_gbs = 12
    ocpus         = 2
  }

  node_source_details {
    image_id    = local.node_pool_image_id
    source_type = "image"
    boot_volume_size_in_gbs = 100
  }
  initial_node_labels {
    key   = "name"
    value = var.k8s_cluster_name
  }

  ssh_public_key = var.ssh_public_key
}

data "oci_containerengine_cluster_kube_config" "kube_config" {
  cluster_id = oci_containerengine_cluster.k8s_cluster.id
}

# Store kubeconfig in file.
output "kube_config_content" {
  value = data.oci_containerengine_cluster_kube_config.kube_config.content
}
