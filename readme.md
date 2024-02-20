## What does this do: 

This will instanciate a t2.micro ec2, install wireguard, create a **single conection** to it
and get the required conf file to conect to it using wireguard.

## Prerequisite:
* Terraform should be [installed](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) 
* This requrires an [IAM user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration) with EC2 access.
* This requires a previous [SSH key pair to be created](https://docs.aws.amazon.com/ground-station/latest/ug/create-ec2-ssh-key-pair.html) on aws and stored localy (needed to ssh and get the .conf file)
* This requires a bash interpreter or any other with scp installed on it.
* [Wireguard ](https://www.wireguard.com/) is required on the machine that will conect to the VPN.

## How to use: 
* Copy the package.
* At the 1st time using it init the repo `terraform init`
* Rename the example.tfvars to terraform.tfvars and set the required variables (the ones not comented)
* `terraform apply`
* use the wireguard client and select the generated .conf file. 
* after using you can delete the ec2 instance with `terraform destroy`


## Variables: 
#### Required:
* ``ssh_key_name``: name of the SSH key on the AWS account (keys are not shared across regions).
  
* ``ssh_pem_path``: The local path .pem file it is used to SSH into the ec2 to get the config data, use unix pathing.

* ``vpn_config_path``: Path where the .conf file will be stored (used to conect through wireguard) please finish it with ``.conf``, use unix pathing.

#### Optional:

* ``allowed_ip``:  This will set an inbound rule on AWS so only your IP can connect to the ec2. If not it will default to all 0.0.0.0/0

* ``aws_region``: Aws region where the ec2 will be created  

* ``ubuntu_ami``: AMI of an ubuntu image, this was only tested on Ubuntu I do not recomend to use another distro.

* ``bash_interpreter``: The scp uses bash sintaxe, this should point to a bash shell

## Observations / Recomendations: 
* This was created thinking of an eazy way of deleting the Ec2  machine after use, if you don't think of doing that or want to have more than a client I recomend [checking this installer](https://github.com/Nyr/wireguard-install) 

* This was originaly created to be used on Windows, but it should work on any unix system.

* The WireGuard Installation (server side) was tested only with Ubuntu.  

## Custom config that can be done: 

* The wireguard ``script.tf`` uses 1.1.1.1 as the dns (cloudFlare, fell free to change it)

---

### Reasoning for the creation of this package:

At the end of january ~ february  I was facing a lot of lag wile playing Gw2, the lag consisted on Spickes of 30s~60s that
would happen twice an hour, this was causing me to DC and go back to a 30min queue :/.

I also noticed that some other sites conecting to some NA severs were having the same problem, after rage quiting sometimes
I decided to figure out what was happening. 

After analyzing some logs I ended up with this a lot:  


````
hop    RTT     PKG              PkG  Loss      IP 
  8    3ms     0/  50 =  0%     0/  50 =  0%  ***.20.224.***.net11.com.br [***.20.224.***] 
                                5/  50 = 10%   |
  9   26ms     5/  50 = 10%     0/  50 =  0%  as******.saopaulo.sp.ix.br [***.16.221.***] 
                               45/  50 = 90%   |
 10  ---      50/  50 =100%     0/  50 =  0%  ***.93.146.*** 
                                0/  50 =  0%   |

````

After talking with some friend the best way of trying to fix it was to use a VPN, and I was recomended to use my own.
I was using wireguard at an EC2 at São Paulo it fixed the package loss problem as well as drastically reduced my ping.

As I just use it for playing I was turning on and off the insance whenever I needed and it is kinda of a pain (after the 4th time), so I developed this package.
