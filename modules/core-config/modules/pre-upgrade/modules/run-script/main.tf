resource "shell_script" "default" {
  interpreter = ["/bin/bash", "-c"]

  environment = var.environment

  lifecycle_commands {
    create = file(var.script_path)
    read   = file("${path.module}/scripts/read.sh")
    update = file("${path.module}/scripts/no-op.sh")
    delete = file("${path.module}/scripts/no-op.sh")
  }
}
