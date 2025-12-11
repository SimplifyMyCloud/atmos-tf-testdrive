# Firewall Component

Creates firewall rules for HTTP access and IAP SSH access.

## Resources

- `google_compute_firewall` (allow_http) - HTTP traffic from internet
- `google_compute_firewall` (allow_iap_ssh) - SSH via Identity-Aware Proxy

## Inputs

| Variable | Description | Type | Required |
|----------|-------------|------|----------|
| `project_id` | GCP project ID | string | yes |
| `network_name` | VPC network name | string | yes |
| `name_prefix` | Prefix for firewall names | string | no |

## Outputs

- `allow_http_rule_id` - HTTP rule ID
- `allow_http_rule_name` - HTTP rule name
- `allow_iap_ssh_rule_id` - IAP SSH rule ID
- `allow_iap_ssh_rule_name` - IAP SSH rule name

## Rules Created

### HTTP Rule
- **Name**: `{prefix}-allow-http`
- **Direction**: INGRESS
- **Source**: `0.0.0.0/0` (internet)
- **Target**: VMs with tag `http-server`
- **Ports**: TCP/80
- **Logging**: Enabled with full metadata

### IAP SSH Rule
- **Name**: `{prefix}-allow-iap-ssh`
- **Direction**: INGRESS
- **Source**: `35.235.240.0/20` (GCP IAP range)
- **Target**: All VMs in network
- **Ports**: TCP/22
- **Logging**: Enabled with full metadata

## Usage

Referenced in stack configuration:

```yaml
components:
  terraform:
    firewall:
      vars:
        project_id: "my-project-id"
        network_name: "my-vpc"
        name_prefix: "my-fw"
```

Deploy with:
```bash
atmos terraform apply firewall -s dev-us-west1
```

## Security Notes

- HTTP is open to internet for demo purposes
- SSH is restricted to GCP IAP only (no public SSH)
- All rules have verbose logging enabled
