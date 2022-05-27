**Kyle's Cloud Projects/Tutorials**

This is an AWS project that will extend into a pipeline.  I am not exactly a coder although I have worked with Python before, the above "code" is more or less a simple blog that will follow my journey through this project.  Eventually, this blog will be the source for these tutorials and projects but until it is completely finished, the projects will stay here on github. I can provide a tutorial on my website build as well but that isn't my main focus for now. 

This pipeline will be relatively simple but it will represent my understanding of CI/CD and potentially IaC.  I will most likely be wrapping this website into a docker image that will be administered through kubernetes to show some of my understanding there.

I plan on adding an AWS WAF and potentially testing AWS Guardduty in a few projects that I will blog about on the website.

This project is going to eventually focus on mostly cloud security as that is my end goal! Let's have some fun and hopefully you enjoy following me through my journey from start to finish!

**#Making a Dockerfile**

First, it is recommended to make a docker hub profile to ensure that you have access to a list of the prebuilt docker images such as the nginx image that I am using.  This will also give you the opportunity to host your own repository that you can make private or public, just like github.

In order to build a docker container you need to start with a "Dockerfile" that will give some instructions on how the container should be built.

**This is my current Dockerfile:**

FROM nginx 
COPY index.html /usr/share/nginx/html/index.html
COPY . /usr/share/nginx/html/
EXPOSE 80

Each line represents a configuration that will be implemented when you run the "docker build" command.  I am creating a container that is based off of the ngnix image hosted on the Docker repository.  This will give me the base image needed to host the website.  Ensure that you COPY your index.html file into the /usr/share/nginx/html/index.html of the container.  This will replace the index.html file that is already in the ngnix container.  If you don't do this, you risk the container showing the basic splash index.html that pops up on a standard ngnix server.  This is a main reason that certain people may have an issue with their website showing THEIR index.html.

After this, you want to ensure that you COPY all files in the current directory "." to the same location that you copied your index.html file to.  This will ensure that all files are in the correct directory for hosting the website within the container.

The last command will ensure that port 80 is exposed to the CONTAINER.  This does not expose the host machine port.  We can customize which port we want to use on the host machine through the "docker build" command on the linux command line.  You can also use a docker-compose.yml file that would allow you to fine tune your volumes and port numbers as well.  Docker-compose is an orchestrator for containers but since we will be using kubernetes to do our orchestration on AWS, I won't be doing a deep delve into that as of yet.

**#Docker build**
 
The command: docker build -t keitzkyle/blog:v1 .

Explanation: After you have made your website (mine is not yet complete) and built your Dockerfile within the same directory of your website, you can test out your container to ensure that docker is working for you. I am working with Ubuntu 22.04 and I have VSCode installed on the virtual Ubuntu machine as well.  Ensure that you have a copy of your website on the linux box and that you are working from the directory that the website and dockerfile are hosted on the CLI.

Once you are in the correct directory within the CLI, you can run the "docker build -t keitzkyle/blog:v1 ." command.  Ensure that you put the "." at the end to tell docker that you would like the container build to happen in the current directory.  Now, the last part of your command is going to be a bit different.  The name of my docker profile is keitzkyle and I am naming the docker container blog:v1.  The "v1" part is just the tag name.  It is essentially a subcategory of the "blog" repo.  If you eventually push out a v2, you can keep the two builds seperate.  You can push your builds to your docker repo for redundancy with the "docker push keitzkyle/blog:tagname".  Replace the command with your own profile and build name.

When you run the build command you will start to see the build take place.  You will see the commands that you inserted into the Dockerfile take place and the container should be built within seconds.  You still wont be able to see your website because although the container is built, it is not yet running.

**#Docker run**

The command: docker run -p 8080:80 keitzkyle/blog:v1

Explanation: Make sure you are still in the same directory as your website and docker build file.  Type in "docker run -p 8080:80 keitzkyle/blog:v1".  Ensure that you are replacing the build name and tag with your own.  This is going to expose port 8080 of the HOST machine and direct it to port 80 of the container.  You do not have to use port 8080, you can realistically use any port that your machine isn't currently using.  To check which ports your machine is using, you can use the "netstat" or "netstat -ano" command and you can actively see which ports are already listening or established.

After you run the command, you should be able to use whatever browser you choose and type in either "localhost:8080" or "127.0.0.1:8080".  Your containerized application should appear and act as normal!


**#Starting ec2 instances for Kubernetes on AWS**

In order to do this, you'll have to have a basic understanding of IAM and security groups on AWS.  You will want to ensure that the ec2 instances that are launched can speak to each other.  You will also need to ensure that you have the correct key pair in order to connect to your linux machine securely.  You will have the option to choose the key pair that you would like to use during the spin up of your ec2 instance.  

The bad news: there are no ec2 instances that you can currently use for free for a kubernetes cluster.  Kubernetes requires at least 2 CPUs and 2 GB of RAM/Memory or you will get a ton of errors during the first command when you create the master node in the cluster....I may or may not have found this out the hard way :(.  I have been using Ubuntu instances built on a t3.small and this only charges about 2 cents an hour.  I did the math and it would essentially cost about 15 dollars a month to run this master node.  Even if you had to run 3 of these nodes, it would be 45 dollars a month which still beats the price of Elastic Kubernetes Service (EKS) at about 70-75 dollars a month for 1 kubernetes (k8) cluster.  There is also another option you could use (Linode) who provides you a 100 dollars of free credits to use their k8 cluster at 30 dollars a month (cheapest option).  Personally, I wanted to build the cluster from the ground up and debug if I had to, to really understand how Kubernetes works.  Eventually, I may switch to Linode and use their clusters since they are a bit cheaper and they seem to work right out of the box.

Get to the point, Kyle: Alright, so once you have 3 ec2 instances running, you will want to remote into them via SSH.  I used putty to do so, if you are doing the same then make sure you download the .ppk version of your key pair and not the .pem version.  The former works well with putty. Ensure that all security groups are allowed to speak to each other, you won't have to do this if you create your ec2 instances at the same time since they will all be in the same ec2 instance.  Ensure that inbound traffic is allowed from the same security group.  The reason you want to do this is because Kubernetes or the kubectl command will use port 6443 by default.  It needs to be able to check on that port on it's own IP address to reach the Kubernetes API.  If a security group is blocking return inbound traffic from itself, you may get an error message that states that it could not reach the "ip address at port 6443" or something along those lines.

**#Installing Kubernetes and Docker on ec2**

After you have logged into all of the instances you will want to run a few commands (all of these can be found on the official Kubernetes site: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/):

#update linux    

sudo apt-get update

#install curl

sudo apt-get install -y apt-transport-https ca-certificates curl

#Install gpg keys

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

#Add the Kubernetes apt repository

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

#Run update and install kubelet, kubeadm, and kubectl

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

#Hold the new tools (this will prevent accidental updates to these tools that may cause your cluster to break)

sudo apt-mark hold kubelet kubeadm kubectl


**To be continued, ran out of time for the day 😥**
