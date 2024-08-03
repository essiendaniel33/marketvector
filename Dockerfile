FROM httpd:2.4
 
COPY ./test-app-html/ /usr/local/apache2/htdocs/
