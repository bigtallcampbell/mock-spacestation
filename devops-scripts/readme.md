# Mock Space Station: DevOps Scripts
The following scripts are provided to make it easier to move your container application from your development environment into another environment with minimal effort.  The flow of these scripts is the following:

```mermaid
sequenceDiagram
    participant dev_environment
    participant azure_blob_storage
    participant deployed_environment
    dev_environment->>azure_blob_storage: build_export_container.sh to export and upload container image and scripts
    azure_blob_storage->>deployed_environment: download_container.sh to download tar file and scripts
    deployed_environment->>deployed_environment: run_experiment.sh to run the experiment, loading the docker image and running the container.
    deployed_environment->>deployed_environment: docker_cleanup.sh to delete image from container registry.
```