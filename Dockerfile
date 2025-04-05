FROM node:lts-alpine AS build

# Set the working directory in the container
WORKDIR /app

# Copy the Angular project directory from the repository
COPY angular-site/wsu-hw-ng-main /app/wsu-hw-ng-main

# Change to the project directory where angular.json resides
WORKDIR /app/wsu-hw-ng-main

RUN npm install

# Build the application for production
RUN npm run build -- --configuration production

FROM nginx:alpine

# Copy the built files from the build stage to Nginx's web root
COPY --from=build /app/wsu-hw-ng-main/dist/wsu-hw-ng /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]