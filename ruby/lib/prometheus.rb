require "prometheus-unifio/version"

module Prometheus
  WORKSPACE = File.expand_path(ENV['PROMETHEUS_WORKSPACE'] || '../../../', __FILE__)
  CONFIG = File.join(WORKSPACE, ENV['PROMETHEUS_CONFIG'] || 'prometheus.yaml')
  PACKER = File.join(WORKSPACE, ENV['PROMETHEUS_PACKER_DIR'] || 'packer')
  TERRAFORM =  File.join(WORKSPACE, ENV['PROMETHEUS_TERRAFORM_DIR'] || 'terraform')
end
