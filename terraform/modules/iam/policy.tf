data "google_iam_policy" "dicoding" {
  binding {
    role    = "roles/compute.instanceViewer"
    members = ["reviewer_googlecloud@dicoding.com"]
  }
}
