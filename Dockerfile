FROM nginx:alpine
 
COPY ./test-app-html/ /usr/share/nginx/html
