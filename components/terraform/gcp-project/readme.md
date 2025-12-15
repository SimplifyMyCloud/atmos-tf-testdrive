# GCP Project Component

Creates a GCP project, associates it with billing, and enables required APIs.

## Resources

- `google_project` - The GCP project
- `google_project_service` - Enabled APIs (compute, logging, monitoring, etc.)

## Inputs

| Variable | Description | Type | Required |
|----------|-------------|------|----------|
| `project_name` | Display name of the project | string | yes |
| `project_id` | Unique project ID | string | yes |
| `org_id` | Organization ID | string | yes |
| `billing_account` | Billing account ID | string | yes |
| `labels` | Labels to apply | map(string) | no |
| `enabled_apis` | APIs to enable | list(string) | no |

## Outputs

- `project_id` - The project ID
- `project_number` - The project number
- `project_name` - The project display name

## Usage

Referenced in stack configuration:

```yaml
components:
  terraform:
    gcp-project:
      vars:
        project_name: "My Project"
        project_id: "my-project-id"
        org_id: "123456789"
        billing_account: "ABCDEF-123456-789012"
```

Deploy with:
```bash
atmos terraform apply gcp-project -s dev
```
