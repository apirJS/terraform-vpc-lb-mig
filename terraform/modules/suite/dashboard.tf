variable "dashboard_display_name" {}
variable "instance_group_eu_name" {}
variable "instance_group_asia_name" {}

resource "google_monitoring_dashboard" "custom_dashboard" {
  dashboard_json = jsonencode({
    "displayName": var.dashboard_display_name,
    "gridLayout": {
      "columns": 2,
      "widgets": [
        // 1️⃣ CPU Utilization for all GCE instances
        {
          "title": "CPU Utilization (All Instances)",
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "filter": "resource.type=\"gce_instance\" metric.type=\"compute.googleapis.com/instance/cpu/utilization\" metadata.system_labels.\"instance_group\"=\"${var.instance_group_eu_name}\"",
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_MEAN"
                    }
                  }
                },
                "plotType": "LINE"
              },
              {
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "filter": "resource.type=\"gce_instance\" metric.type=\"compute.googleapis.com/instance/cpu/utilization\" metadata.system_labels.\"instance_group\"=\"${var.instance_group_asia_name}\"",
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_MEAN"
                    }
                  }
                },
                "plotType": "LINE"
              },
            ],
            "yAxis": {
              "label": "CPU Utilization",
              "scale": "LINEAR"
            }
          }
        },
        // 2️⃣ Backend HTTP Request Count for load balancers
        {
          "title": "HTTP backend Request Count (Load Balancers)",
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "filter": "resource.type=\"https_lb_rule\" metric.type=\"loadbalancing.googleapis.com/https/backend_request_count\"",
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_SUM"
                    }
                  }
                },
                "plotType": "LINE"
              }
            ],
            "yAxis": {
              "label": "Request Count",
              "scale": "LINEAR"
            }
          }
        },
        // 3️⃣ Backend Latency for load balancers
        {
          "title": "Backend Latency (Load Balancers)",
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "filter": "resource.type=\"https_lb_rule\" metric.type=\"loadbalancing.googleapis.com/https/backend_latencies\"",
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_PERCENTILE_95"
                    }
                  }
                },
                "plotType": "LINE"
              }
            ],
            "yAxis": {
              "label": "Latency (s)",
              "scale": "LINEAR"
            }
          }
        },
        // 4️⃣ Network Traffic (Received Bytes) for all GCE instances
        {
          "title": "Network Received Bytes (All Instances)",
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "filter": "resource.type=\"gce_instance\" metric.type=\"compute.googleapis.com/instance/network/received_bytes_count\"",
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_RATE"
                    }
                  }
                },
                "plotType": "LINE"
              }
            ],
            "yAxis": {
              "label": "Bytes/sec",
              "scale": "LINEAR"
            }
          }
        }
      ]
    }
  })
}
