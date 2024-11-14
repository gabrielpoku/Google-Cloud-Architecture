# Google-Cloud-Architecture

## Developer Control Plane

This plane is the primary configuration layer and interaction point for the platform users. It harbors the following components:

* A **Version Control System**. GitHub is a prominent example, but this can be any system that contains two types of repositories:
  * Application Source Code
  * Platform Source Code, e.g. using Terraform

### Integration and Delivery Plane

This plane is about building and storing the image, creating app and infra configs from the abstractions provided by the developers, and deploying the final state. It’s where the domains of developers and platform engineers meet.

This plane usually contains four different tools:

* A **CI pipeline**. It can be Github Actions or any CI tooling on the market.
* The **image registry** holding your container images. Again, this can be any registry on the market.
* An **orchestrator** which in our example, is the Humanitec Platform Orchestrator.
* The **CD system**, which can be the Platform Orchestrator’s deployment pipeline capabilities — an external system triggered by the Orchestrator using a webhook, or a setup in tandem with GitOps operators like ArgoCD.

### Monitoring and Logging Plane

The integration of monitoring and logging systems varies greatly depending on the system. This plane however is not a focus of the reference architecture.

### Security Plane

The security plane of the reference architecture is focused on the secrets management system. The secrets manager stores configuration information such as database passwords, API keys, or TLS certificates needed by an Application at runtime. It allows the Platform Orchestrator to reference the secrets and inject them into the Workloads dynamically. You can learn more about secrets management and integration with other secrets management

The reference architecture sample implementations use the secrets store attached to the Humanitec SaaS system.

### Resource Plane

This plane is where the actual infrastructure exists including clusters, databases, storage, or DNS services. The configuration of the Resources is managed by the Platform Orchestrator which dynamically creates app and infrastructure configurations with every deployment and creates, updates, or deletes dependent Resources as required.

## How to spin up your  Google Cloud Implementation

By default, the following will be provisioned:

* VPC
* GKE Autopilot Cluster
* Google Service Account to access the cluster
* Ingress NGINX in the cluster
* Resource Definitions in Humanitec for:
  * Kubernetes Cluster

5. Run terraform:

   ```shell
   terraform init
   terraform plan
   terraform apply
   ```
> If you're recreating the reference architecture and facing the issue of `WorkloadIdentityPool already exists`,
> please run the following commands to import workload identity pools and workload identity pool provider
> ```shell
> gcloud iam workload-identity-pools undelete humanitec-wif-pool --location=global
> gcloud iam workload-identity-pools providers undelete humanitec-wif --workload-identity-pool=-wif-pool --location=global
> terraform import module.base.module.credentials.google_iam_workload_identity_pool.pool humanitec-wif-pool
> terraform import module.base.module.credentials.google_iam_workload_identity_pool_provider.pool_provider humanitec-wif-pool/humanitec-wif
> ```

   This should output:

   ```bash
   "htc-ref-arch-cluster"
   "k8s-cluster"
   ```

3. Verify the existence of the newly created GKE cluster:

   ```bash
   gcloud container clusters list --filter "name=htc-ref-arch-cluster"
   ```

   This should output cluster data like this:

   ```bash
   NAME                  LOCATION       MASTER_VERSION  MASTER_IP       MACHINE_TYPE    NODE_VERSION    NUM_NODES  STATUS
   htc-ref-arch-cluster  <your-region>  xx.xx.xx-gke.xx xx.xx.xx.xx     n2d-standard-4  xx.xx.xx-gke.xx 3          RUNNING
   ```

#### Portal Prerequisites

Backstage requires a GitHub connection, which in turn needs:

* A GitHub organization and permission to create new repositories in it. Go to <https://github.com/account/organizations/new> to create a new org (the "Free" option is fine). Note: is has to be an organization, a free account is not sufficient.
* Create a classic github personal access token with `repo`, `workflow`, `delete_repo` and `admin:org` scope [here](https://github.com/settings/tokens).
* Set the `GITHUB_TOKEN` environment variable to your token.

  ```shell
  export GITHUB_TOKEN="my-github-token"
  ```

* Set the `GITHUB_ORG_ID` environment variable to your GitHub organization ID.

  ```shell
  export GITHUB_ORG_ID="my-github-org-id"
  ```

* Install the GitHub App for Backstage into your GitHub organization
  * Run `docker run --rm -it -e GITHUB_ORG_ID -v $(pwd):/pwd -p 127.0.0.1:3000:3000 ghcr.io/humanitec-architecture/create-gh-app` ([image source](https://github.com/architecture/create-gh-app/)) and follow the instructions:
    * “All repositories” ~> Install
    * “Okay, […] was installed on the […] account.” ~> You can close the window and server.

#### Portal Usage

* Enable `with_backstage` inside your `terraform.tfvars` and configure the additional variables that are required for Backstage.
* Perform another `terraform apply`

### Cleaning up

Once you are finished with the reference architecture, you can remove all provisioned infrastructure and the resource definitions created in Humanitec with the following:

1. Delete all Humanitec Applications scaffolded using the Portal, if you used one, but not the `backstage` app itself.

2. Ensure you are (still) logged in with `gcloud`.

3. Ensure you still have the `TOKEN` environment variable set to an appropriate Humanitec API token with the `Administrator` role on the Humanitec Organization.
  
   You can verify this in the UI if you log in with an Administrator user and go to Resource Management, and check the "Usage" of each resource definition with the prefix set in `humanitec_prefix` - by default this is `htc-ref-arch-`.

4. Run terraform:

   ```shell
   terraform destroy
   ```

