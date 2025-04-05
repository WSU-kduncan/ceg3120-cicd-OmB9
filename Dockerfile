FROM nginx:alpine

COPY angular-site /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]