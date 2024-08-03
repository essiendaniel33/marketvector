FROM nginx:alpine
 
COPY ./test-app-html/ /usr/local/apache2/htdocs/
