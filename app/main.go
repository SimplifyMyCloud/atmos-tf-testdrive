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

// VMMetadata holds information about the GCE instance
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

// getMetadata fetches a value from GCP metadata server
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

// fetchVMMetadata retrieves all relevant metadata
func fetchVMMetadata() (*VMMetadata, error) {
	metadata := &VMMetadata{}

	// Fetch instance name
	if val, err := getMetadata("/instance/name"); err == nil {
		metadata.InstanceName = val
	}

	// Fetch instance ID
	if val, err := getMetadata("/instance/id"); err == nil {
		metadata.InstanceID = val
	}

	// Fetch zone (returns full path, we'll extract zone name)
	if val, err := getMetadata("/instance/zone"); err == nil {
		metadata.Zone = val
	}

	// Fetch project ID
	if val, err := getMetadata("/project/project-id"); err == nil {
		metadata.ProjectID = val
	}

	// Fetch machine type
	if val, err := getMetadata("/instance/machine-type"); err == nil {
		metadata.MachineType = val
	}

	// Fetch internal IP
	if val, err := getMetadata("/instance/network-interfaces/0/ip"); err == nil {
		metadata.InternalIP = val
	}

	// Fetch external IP (may not exist)
	if val, err := getMetadata("/instance/network-interfaces/0/access-configs/0/external-ip"); err == nil {
		metadata.ExternalIP = val
	} else {
		metadata.ExternalIP = "None"
	}

	// Fetch hostname
	if val, err := getMetadata("/instance/hostname"); err == nil {
		metadata.Hostname = val
	}

	return metadata, nil
}

// handleRoot serves the main info page
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

// handleJSON serves metadata as JSON
func handleJSON(w http.ResponseWriter, r *http.Request) {
	metadata, err := fetchVMMetadata()
	if err != nil {
		http.Error(w, fmt.Sprintf("Error fetching metadata: %v", err), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(metadata)
}

// handleHealth serves a simple health check endpoint
func handleHealth(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprint(w, "OK")
}

func main() {
	// Register handlers
	http.HandleFunc("/", handleRoot)
	http.HandleFunc("/json", handleJSON)
	http.HandleFunc("/health", handleHealth)

	// Get port from environment or use 80
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
