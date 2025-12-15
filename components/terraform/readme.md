# Terraform Components

Reusable Terraform modules for GCP infrastructure. Each component is self-contained and manages a specific resource type.

## Components

### [gcp-project/](gcp-project/)
Creates and configures a GCP project with billing association and API enablement.

**Resources**: `google_project`, `google_project_service`

### [vpc/](vpc/)
Creates a custom VPC network with manual subnet creation.

**Resources**: `google_compute_network`

### [subnet/](subnet/)
Creates a subnet with configurable CIDR range and flow logs.

**Resources**: `google_compute_subnetwork`

### [firewall/](firewall/)
Creates firewall rules for HTTP traffic and IAP SSH access.

**Resources**: `google_compute_firewall`

### [vm/](vm/)
Creates a GCE VM instance with startup script support.

**Resources**: `google_compute_instance`

## Component Structure

Each component follows standard Terraform module structure:

```
component-name/
├── main.tf       # Resource definitions
├── variables.tf  # Input variables
└── outputs.tf    # Output values
```

## Usage

Components are referenced by stacks in the `stacks/` directory. Never deploy components directly - always use Atmos with a stack configuration:

```bash
atmos terraform apply <component-name> -s <stack-name>
```
