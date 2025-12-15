# Subnet Component

Creates a subnet within a VPC network with flow logs enabled.

## Resources

- `google_compute_subnetwork` - Subnet with flow logging

## Inputs

| Variable | Description | Type | Required |
|----------|-------------|------|----------|
| `project_id` | GCP project ID | string | yes |
| `subnet_name` | Name of the subnet | string | yes |
| `region` | Region for the subnet | string | yes |
| `network_name` | VPC network name | string | yes |
| `ip_cidr_range` | IP CIDR range | string | yes |
| `private_ip_google_access` | Enable private Google access | bool | no |
| `flow_logs_interval` | Flow logs interval | string | no |
| `flow_logs_sampling` | Flow logs sampling rate | number | no |
| `flow_logs_metadata` | Flow logs metadata level | string | no |

## Outputs

- `subnet_id` - The subnet ID
- `subnet_name` - The subnet name
- `subnet_self_link` - The subnet self-link
- `ip_cidr_range` - The IP CIDR range
- `gateway_address` - The gateway address

## Features

- VPC flow logs enabled by default
- Configurable sampling and metadata
- Private Google Access support

## Usage

Referenced in stack configuration:

```yaml
components:
  terraform:
    subnet:
      vars:
        project_id: "my-project-id"
        subnet_name: "my-subnet"
        region: "us-west1"
        network_name: "my-vpc"
        ip_cidr_range: "10.0.0.0/24"
```

Deploy with:
```bash
atmos terraform apply subnet -s dev
```
