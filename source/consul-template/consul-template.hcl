consul {
  address = "consul:8500"
  retry {
    enabled = true
    attempts = 10
    backoff = "250ms"
  }
}

template {
  source = "/etc/consul-template/maintenance/index.ctmpl"
  destination = "/www/index.html"
}

template {
  source = "/etc/consul-template/app.ctmpl"
  destination = "/etc/nginx/conf.d/app.conf"
  command = "service nginx reload"
}
