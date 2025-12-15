#!/bin/bash
# VM Startup Script for GCE Instance
# This script installs Go, downloads the application code, compiles and runs it

set -e

# Log all output
exec > >(tee /var/log/startup-script.log)
exec 2>&1

echo "========================================"
echo "Starting VM setup at $(date)"
echo "========================================"

# Update system packages
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install required packages
echo "Installing required packages..."
apt-get install -y wget git curl

# Install Go
echo "Installing Go..."
GO_VERSION="1.21.5"
wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
rm -rf /usr/local/go
tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz

# Set Go environment variables
export PATH=$PATH:/usr/local/go/bin
export GOPATH=/root/go
echo 'export PATH=$PATH:/usr/local/go/bin' >> /root/.bashrc
echo 'export GOPATH=/root/go' >> /root/.bashrc

# Verify Go installation
echo "Go version: $(go version)"

# Create application directory
echo "Creating application directory..."
mkdir -p /opt/webapp
cd /opt/webapp

# Create the Go application
echo "Creating Go application..."
cat > main.go << 'GOEOF'
package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
)

const metadataURL = "http://metadata.google.internal/computeMetadata/v1"

type VMMetadata struct {
	InstanceName string
	InstanceID   string
	Zone         string
	ProjectID    string
	MachineType  string
	InternalIP   string
	ExternalIP   string
	Hostname     string
}

func getMetadata(path string) (string, error) {
	client := &http.Client{}
	req, err := http.NewRequest("GET", metadataURL+path, nil)
	if err != nil {
		return "", err
	}

	req.Header.Add("Metadata-Flavor", "Google")

	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	return string(body), nil
}

func fetchVMMetadata() (*VMMetadata, error) {
	metadata := &VMMetadata{}

	if val, err := getMetadata("/instance/name"); err == nil {
		metadata.InstanceName = val
	}

	if val, err := getMetadata("/instance/id"); err == nil {
		metadata.InstanceID = val
	}

	if val, err := getMetadata("/instance/zone"); err == nil {
		metadata.Zone = val
	}

	if val, err := getMetadata("/project/project-id"); err == nil {
		metadata.ProjectID = val
	}

	if val, err := getMetadata("/instance/machine-type"); err == nil {
		metadata.MachineType = val
	}

	if val, err := getMetadata("/instance/network-interfaces/0/ip"); err == nil {
		metadata.InternalIP = val
	}

	if val, err := getMetadata("/instance/network-interfaces/0/access-configs/0/external-ip"); err == nil {
		metadata.ExternalIP = val
	} else {
		metadata.ExternalIP = "None"
	}

	if val, err := getMetadata("/instance/hostname"); err == nil {
		metadata.Hostname = val
	}

	return metadata, nil
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
	metadata, err := fetchVMMetadata()
	if err != nil {
		http.Error(w, fmt.Sprintf("Error fetching metadata: %v", err), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/html; charset=utf-8")

	html := fmt.Sprintf(`
<!DOCTYPE html>
<html>
<head>
    <title>GCE Instance Info</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #4285f4;
            border-bottom: 3px solid #4285f4;
            padding-bottom: 10px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: 200px 1fr;
            gap: 15px;
            margin-top: 20px;
        }
        .label {
            font-weight: bold;
            color: #555;
        }
        .value {
            color: #333;
            font-family: 'Courier New', monospace;
            background-color: #f8f9fa;
            padding: 5px 10px;
            border-radius: 4px;
        }
        .footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            text-align: center;
            color: #666;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>GCE Instance Information</h1>
        <p>This page displays metadata about the Google Compute Engine instance it's running on.</p>

        <div class="info-grid">
            <div class="label">Instance Name:</div>
            <div class="value">%s</div>

            <div class="label">Instance ID:</div>
            <div class="value">%s</div>

            <div class="label">Zone:</div>
            <div class="value">%s</div>

            <div class="label">Project ID:</div>
            <div class="value">%s</div>

            <div class="label">Machine Type:</div>
            <div class="value">%s</div>

            <div class="label">Internal IP:</div>
            <div class="value">%s</div>

            <div class="label">External IP:</div>
            <div class="value">%s</div>

            <div class="label">Hostname:</div>
            <div class="value">%s</div>
        </div>

        <div class="footer">
            <p>Powered by Go • Deployed with Terraform + Atmos</p>
        </div>
    </div>
</body>
</html>
`,
		metadata.InstanceName,
		metadata.InstanceID,
		metadata.Zone,
		metadata.ProjectID,
		metadata.MachineType,
		metadata.InternalIP,
		metadata.ExternalIP,
		metadata.Hostname,
	)

	fmt.Fprint(w, html)
}

func handleJSON(w http.ResponseWriter, r *http.Request) {
	metadata, err := fetchVMMetadata()
	if err != nil {
		http.Error(w, fmt.Sprintf("Error fetching metadata: %v", err), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(metadata)
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprint(w, "OK")
}

func main() {
	http.HandleFunc("/", handleRoot)
	http.HandleFunc("/json", handleJSON)
	http.HandleFunc("/health", handleHealth)

	port := os.Getenv("PORT")
	if port == "" {
		port = "80"
	}

	log.Printf("Starting server on port %s...", port)
	log.Printf("Access the web page at http://<external-ip>:%s/", port)
	log.Printf("Access JSON metadata at http://<external-ip>:%s/json", port)
	log.Printf("Health check at http://<external-ip>:%s/health", port)

	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}
GOEOF

# Initialize Go module
echo "Initializing Go module..."
go mod init webapp

# Build the application
echo "Building Go application..."
go build -o webapp main.go

# Create systemd service for the web app
echo "Creating systemd service..."
cat > /etc/systemd/system/webapp.service << 'EOF'
[Unit]
Description=GCE Metadata Web Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/webapp
ExecStart=/opt/webapp/webapp
Restart=always
RestartSec=5
StandardOutput=append:/var/log/webapp.log
StandardError=append:/var/log/webapp-error.log

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start the service
echo "Starting web application service..."
systemctl daemon-reload
systemctl enable webapp.service
systemctl start webapp.service

# Wait a moment for the service to start
sleep 3

# Check service status
echo "Service status:"
systemctl status webapp.service --no-pager

echo "========================================"
echo "VM setup completed at $(date)"
echo "========================================"
echo "The web application should now be running on port 80"
echo "Access it via the external IP address"
