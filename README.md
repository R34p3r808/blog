**Kyle's Cloud Projects/Tutorials**

This is an AWS project that will extend into a pipeline.  I am not exactly a coder although I have worked with Python before, the above "code" is more or less a simple blog that will follow my journey through this project.  Eventually, this blog will be the source for these tutorials and projects but until it is completely finished, the projects will stay here on github. I can provide a tutorial on my website build as well but that isn't my main focus for now. 

This pipeline will be relatively simple but it will represent my understanding of CI/CD and potentially IaC.  I will most likely be wrapping this website into a docker image that will be administered through kubernetes to show some of my understanding there.

I plan on adding an AWS WAF and potentially testing AWS Guardduty in a few projects that I will blog about on the website.

This project is going to eventually focus on mostly cloud security as that is my end goal! Let's have some fun and hopefully you enjoy following me through my journey from start to finish!

**Making a Dockerfile**

First, it is recommended to make a docker hub profile to ensure that you have access to a list of the prebuilt docker images such as the nginx image that I am using.  This will also give you the opportunity to host your own repository that you can make private or public, just like github.

In order to build a docker container you need to start with a "Dockerfile" that will give some instructions on how the container should be built.

This is my current Dockerfile:

FROM nginx 
COPY index.html /usr/share/nginx/html/index.html
COPY . /usr/share/nginx/html/
EXPOSE 80

Each line represents a configuration that will be implemented when you run the "docker build" command.  I am creating a container that is based off of the ngnix image hosted on the Docker repository.  This will give me the base image needed to host the website.  Ensure that you COPY your index.html file into the /usr/share/nginx/html/index.html of the container.  This will replace the index.html file that is already in the ngnix container.  If you don't do this, you risk the container showing the basic splash index.html that pops up on a standard ngnix server.  This is a main reason that certain people may have an issue with their website showing THEIR index.html.

After this, you want to ensure that you COPY all files in the current directory "." to the same location that you copied your index.html file to.  This will ensure that all files are in the correct directory for hosting the website within the container.

The last command will ensure that port 80 is exposed to the CONTAINER.  This does not expose the host machine port.  We can customize which port we want to use on the host machine through the "docker build" command on the linux command line.  You can also use a docker-compose.yml file that would allow you to fine tune your volumes and port numbers as well.  Docker-compose is an orchestrator for containers but since we will be using kubernetes to do our orchestration on AWS, I won't be doing a deep delve into that as of yet.

**Docker build**

After you have made your website (mine is not yet complete) and built your Dockerfile within the same directory of your website, you can test out your container to ensure that docker is working for you. I am working with Ubuntu 22.04 and I have VSCode installed on the virtual Ubuntu machine as well.  Ensure that you have a copy of your website on the linux box and that you are working from the directory that the website and dockerfile are hosted on the CLI.

Once you are in the correct directory within the CLI, you can run the "docker build -t keitzkyle/blog:v1 ." command.  Ensure that you put the "." at the end to tell docker that you would like the container build to happen in the current directory.  Now, the last part of your command is going to be a bit different.  The name of my docker profile is keitzkyle and I am naming the docker container blog:v1.  The "v1" part is just the tag name.  It is essentially a subcategory of the "blog" repo.  If you eventually push out a v2, you can keep the two builds seperate.  You can push your builds to your docker repo for redundancy with the "docker push keitzkyle/blog:tagname".  Replace the command with your own profile and build name.

When you run the build command you will start to see the build take place.  You will see the commands that you inserted into the Dockerfile take place and the container should be built within seconds.  You still wont be able to see your website because although the container is built, it is not yet running.

**Docker run**

Make sure you are still in the same directory as your website and docker build file.  Type in "docker run -p 8080:80 keitzkyle/blog:v1".  Ensure that you are replacing the build name and tag with your own.  This is going to expose port 8080 of the HOST machine and direct it to port 80 of the container.  You do not have to use port 8080, you can realistically use any port that your machine isn't currently using.  To check which ports your machine is using, you can use the "netstat" or "netstat -ano" command and you can actively see which ports are already listening or established.

After you run the command, you should be able to use whatever browser you choose and type in either "localhost:8080" or "127.0.0.1:8080".  Your containerized application should appear and act as normal!


**Kubernetes installation on AWS**
