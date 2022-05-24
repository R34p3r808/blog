FROM nginx
COPY index.html /usr/share/nginx/html/index.html
COPY . /usr/share/nginx/html/
EXPOSE 80
