FROM nginx
RUN sudo apt-get update && apt-get upgrade
COPY index.html /usr/share/nginx/html/index.html
COPY . /usr/share/nginx/html/
EXPOSE 80
