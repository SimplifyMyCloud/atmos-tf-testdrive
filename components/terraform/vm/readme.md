# VM Component

Creates a GCE VM instance with configurable specifications and startup script support.

## Resources

- `google_compute_instance` - GCE VM instance

## Inputs

| Variable | Description | Type | Required |
|----------|-------------|------|----------|
| `project_id` | GCP project ID | string | yes |
| `instance_name` | VM instance name | string | yes |
| `zone` | Zone for the VM | string | yes |
| `machine_type` | Machine type | string | no |
| `network_name` | VPC network name | string | yes |
| `subnet_name` | Subnet name | string | yes |
| `network_tags` | Network tags | list(string) | no |
| `boot_disk_image` | Boot disk image | string | no |
| `boot_disk_size` | Boot disk size (GB) | number | no |
| `boot_disk_type` | Boot disk type | string | no |
| `startup_script` | Startup script content | string | no |
| `service_account_email` | Service account email | string | no |
| `service_account_scopes` | Service account scopes | list(string) | no |
| `labels` | VM labels | map(string) | no |

## Outputs

- `instance_id` - VM instance ID
- `instance_name` - VM instance name
- `instance_self_link` - VM self-link
- `internal_ip` - Internal IP address
- `external_ip` - External IP address
- `zone` - Deployment zone

## Features

- Configurable machine type and disk
- Startup script support
- External IP assignment
- Service account configuration
- Network tagging

## Default Values

- **Machine Type**: e2-micro
- **Boot Disk**: Debian 12, 10GB, pd-standard
- **Scopes**: cloud-platform

## Usage

Referenced in stack configuration:

```yaml
components:
  terraform:
    vm:
      vars:
        project_id: "my-project-id"
        instance_name: "my-vm"
        zone: "us-west1-a"
        network_name: "my-vpc"
        subnet_name: "my-subnet"
        network_tags: ["http-server"]
        startup_script: |
          #!/bin/bash
          echo "Hello World"
```

Deploy with:
```bash
atmos terraform apply vm -s dev
```

## Notes

- Startup script runs on first boot and after metadata changes
- External IP uses STANDARD network tier
- Service account defaults to compute default account if not specified
