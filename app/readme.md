# Application

Go web application that displays GCE instance metadata.

## Files

### [main.go](main.go)
Go HTTP server that fetches and displays VM metadata from the GCP Metadata API.

## Features

The application provides three endpoints:

### `/` - Web Interface
Beautiful HTML page displaying:
- Instance Name
- Instance ID
- Zone
- Project ID
- Machine Type
- Internal IP Address
- External IP Address
- Hostname

### `/json` - JSON API
Returns all VM metadata in JSON format:
```json
{
  "InstanceName": "smc-atmos-vm-00",
  "InstanceID": "1234567890",
  "Zone": "projects/123456/zones/us-west1-a",
  "ProjectID": "smc-atmos-test-00",
  "MachineType": "projects/123456/machineTypes/e2-micro",
  "InternalIP": "10.0.0.2",
  "ExternalIP": "34.82.xxx.xxx",
  "Hostname": "smc-atmos-vm-00.c.smc-atmos-test-00.internal"
}
```

### `/health` - Health Check
Simple health check endpoint that returns `OK` with HTTP 200 status.

## How It Works

The application:
1. Queries the GCP Metadata API at `http://metadata.google.internal/computeMetadata/v1`
2. Fetches various metadata attributes
3. Formats and displays the data via web interface or JSON API
4. Listens on port 80 (configurable via `PORT` environment variable)

## Deployment

The application is automatically deployed via the VM startup script:
1. Source code is embedded in the startup script
2. Compiled during VM initialization
3. Run as a systemd service (`webapp.service`)
4. Automatically starts on boot and restarts on failure

## Development

To modify the application:

1. Edit `app/main.go` locally
2. Test locally (requires GCE VM or metadata emulator)
3. Update the embedded Go code in `stacks/dev/us-west1.yaml` under `startup_script`
4. Redeploy the VM

## Local Testing

To test locally (requires GCE environment):
```bash
go mod init webapp
go build -o webapp main.go
sudo ./webapp  # Requires sudo for port 80
```

Access at `http://localhost/`

**Note:** The metadata API is only available on GCE instances, so local testing outside GCP won't fetch real metadata.

## Logs

Application logs are available at:
- **stdout/stderr**: `/var/log/webapp.log` and `/var/log/webapp-error.log`
- **systemd**: `sudo journalctl -u webapp.service -f`

## Dependencies

- Go standard library only (no external dependencies)
- Requires GCE metadata API access
- Runs on port 80 (requires root or CAP_NET_BIND_SERVICE)

## Security

- No authentication (demo purposes only)
- Metadata is public information about the VM
- Production apps should add authentication/authorization
- Consider using HTTPS with proper certificates
