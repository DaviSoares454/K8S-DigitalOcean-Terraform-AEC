# K8S-DigitalOcean-Terraform-ATC
This repository contains **Terraform** files to deploy, into **DigitalOcean** cloud, a _**[hello-world](https://github.com/prometheus-community/helm-charts)**_ web app and _**[Prometheus-stack](https://github.com/prometheus-community/helm-charts)**_ with _**Grafana**_. <br /> 
It also deploys NGINX ingress and ingress controllers for the web access to the Grafana app and the hello-world page. <br /> 
 <br /> 
 All development and tests were done on Ubuntu 20.04.

## Requeriments
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli);
- [Helm](https://helm.sh/docs/intro/install/);
- DigitalOcean account and [API token](https://docs.digitalocean.com/reference/api/api-reference/#section/Introduction/Curl-Examples) with READ/WRITE access.


## Files
This repository Terraform's structure is divided in 3 files:
- _**1-digitalocean.tf**_: contains required Terraform providers e DigitalOcean cluster creation configuration;
- _**2-deploy-app.tf**_: has the app namespace, deployment, service, ingress and NGINX ingress configurations ;
- _**3-monitoring.tf**_: include the monitoring stack deploy with namespace, deployment, service and ingress components. <br /> <br /> <br />

___
# Setting up the environment
1. **Downloading the repository:**<br />

```
$ wget https://github.com/DaviSoares454/K8S-DigitalOcean-Terraform-ATC/archive/refs/heads/main.zip;
$ unzip main.zip
$ cd K8S-DigitalOcean-Terraform-ATC-main/
```
2. **Editing the files:**<br /> 
Here you will find only the main configurations for each file, but you are free to edit the entire contents as you wish.
  2.  **1-digitalocean.tf:**<br />
  Starting at line 24, here you can edit the cluster name, region, worker nodes size and quantity.<br />
  
  ```
  25    name = "davik8s"
  26    region = "nyc3"
  31    size = "s-1vcpu-2gb"
  32    node_count = 3
  ```
  2.  **2-deploy-app.tf:**<br />
  The last component in this file is the hello-world ingress. Here you configure the domain you want to use as your hello-world page.<br />
  
  ```
  94    host = "example.com"
  ```
  3.  **3-monitoring.tf:**<br />
  As the last file, here you can edit the domain, but now used to expose **grafana's** frontend.<br />
  
  ```
  37    host = "graf.example.com"
  ```
  

3. **Running the code:**<br />
First, run terrafom following command to validate and plan the infraestructure provisioning.  <br />

```
$ terraform apply;
```


You'll be promped by this message. Here you need to put the DigitalOcean API Token, then press enter. <br />
```
var.do_token     
  Enter a value: <PUT THE TOKEN HERE>
```

After Terraform calculated all the modifications, you'll be prompted to accept the planned modifications and perform the actions.  <br />
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: <WRITE YES>
```

The infrastructure deployment will take about 10 minutes to complete.<br />
After completing, Terraform CLI will show _"Apply complete!"_ message and how many resources did it changed.<br /> <br />
Now, with your cluster and deployments set, you need to copy the Load Balancer's IP that was created in DigitalOcean, you can use DigitalOcean's dashboard to do that, or download the kubeconfig file from your cluster though DigitalOcean as well. <br />
Then you need to point your domain **(the same host that you configured at the 2-deploy-app.tf and 3-monitoring.tf files)** to that IP. <br />





___
# Results<br />
In this results example, I used _ecsys.io_ domain. So I ended up with two web links: <br />
**ecsys.io** (for the main hello-world page) and <br />
**graf.ecsys.io** (for the grafana web page).
1. **Hello-world web page:**<br />

![Hostname changes everytime you refresh the page (LoadBalacing).](/results/hello-world.png "hello-world result.")

2. **Grafana web page:**<br />
Default login username: admin<br />
Default password: prom-operator<br /><br />
![Grafana login page.](/results/grafana-login.png "Grafana login page.")<br /><br />
Grafana dashboard example<br />
![Grafana login page.](/results/grafana-dashboard.png "Grafana login page.")