output "client-ip" {
  value = "$(chomp(data.http.icanhazip.response_body))"
}