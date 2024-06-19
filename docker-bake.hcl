variable "ALPINE_VERSION" { default = "latest" }
variable "ALERTMANAGER_VERSION" { default = "latest" }

target "docker-metadata-action" {}
target "github-metadata-action" {}

target "default" {
    inherits = [ "alertmanager" ]
    platforms = [
        "linux/amd64",
        "linux/arm64"
    ]
}

target "local" {
    inherits = [ "alertmanager" ]
    tags = [ "swarmlibs/alertmanager:local" ]
}

target "alertmanager" {
    context = "."
    dockerfile = "Dockerfile"
    inherits = [
        "docker-metadata-action",
        "github-metadata-action",
    ]
    args = {
        ALPINE_VERSION = "${ALPINE_VERSION}"
        ALERTMANAGER_VERSION = "${ALERTMANAGER_VERSION}"
    }
}
