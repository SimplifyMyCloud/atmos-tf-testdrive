# VPC Component

Creates a custom VPC network with manual subnet management.

## Resources

- `google_compute_network` - VPC network

## Inputs

| Variable | Description | Type | Required |
|----------|-------------|------|----------|
| `project_id` | GCP project ID | string | yes |
| `network_name` | Name of the VPC | string | yes |
| `routing_mode` | Routing mode (REGIONAL or GLOBAL) | string | no |
| `description` | VPC description | string | no |

## Outputs

- `network_id` - The network ID
- `network_name` - The network name
- `network_self_link` - The network self-link

## Features

- Auto-create subnets disabled (manual control)
- Configurable routing mode
- Default routes preserved

## Usage

Referenced in stack configuration:

```yaml
components:
  terraform:
    vpc:
      vars:
        project_id: "my-project-id"
        network_name: "my-vpc"
        routing_mode: "REGIONAL"
```

Deploy with:
```bash
atmos terraform apply vpc -s dev
```
