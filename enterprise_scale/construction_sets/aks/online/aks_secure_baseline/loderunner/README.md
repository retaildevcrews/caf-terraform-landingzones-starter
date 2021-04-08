# Loderunner Installation

The following instructions will deploy LodeRunner on your CAF Secure Baseline infrastructure.

## Prerequisites

* You need to have a CAF infrastructure up and running for this deployment.
* You need to be connected to your Azure Kubernetes Service (AKS) cluster.
* You need to have NGSA-Memory app running on your AKS cluster.
* You need to have the GitHubs Packages site whitelisted in your CAF Firewall.

### Deploying the NGSA-Memory app

Instructions on how to deploy the NGSA Memory app can be found [here](../ngsa/README.md).

### Whitelist the GitHub Packages URL (pkg-containers-az.githubusercontent.com) in the infrastructure firewall

This is needed as otherwise the deployment of LodeRunner will fail.
To do this, head over to your Azure Portal and find the vNet-Hub resource group created by Infrastructure Provisioning, e.g. vnet-hub-re1, then locate the egress firewall resource.

Go to packages application rule collection by navigating to:

[Egress Firewall] > [Setting] > [Rules(Classic)] > [Application rule collection] > [Packages]

Add the a new Target FQDN

| **name**  | **Source type** |      **Source**     | **Protocol:Port** | **Target FQDNs** |
|-----------|-----------------|---------------------|-------------------|------------------|
| github-pkgs      | IP Group        |same as Docker entry |     Https:443     |     pkg-containers-az.githubusercontent.com      |

## Deployment

Ensure that you had navigated to this folder. Then, run the following command to deploy the LodeRunner app.

```bash
kubectl apply -f loderunner.yaml
```

Confirm that the deployment was successful by checking for the pods.

```bash
# Get the pod name
kubectl get pods -n ngsa-l8r

# Check the logs and ensure the tests are running.
# Replace <pod-name> with your pod name from the previous command.
kubectl logs <pod-name> -n ngsa-l8r -f
```
