# Project 4 - CI

## Continuous Integration Project Overview

### Goal of This Project

The goal is to automate the process of builing and deploying a Docker image of an Angular app to DockerHub whenever changes are pushed to the main branch of this repository.

### Tools Used in This Project

- Docker: To containerize the Angular app.
- DockerHub: Serves as the registry for storing and sharing Docker images.
- NGINX: Web server used within the Docker container which serves the Angular app.
- GitHub Actions: Automation tool for CI pipeline.
- Mermaid: Digramming tool

### Diagram

``` mermaid
graph TD
    A[Developer pushes code to GitHub] --> B{GitHub Actions triggered on push to main}
    B --> C[Checkout code]
    C --> D[Login to DockerHub]
    D --> E[Build Docker image]
    E --> F[Push Docker image to DockerHub]
    F --> G[New image available on DockerHub]
```

## Part 1 - Docker-ize it

## Docker Setup

The following section focuses on the installation and configuration of docker on a Windows OS machine.

1. Download Docker Desktop
   - [Click here to visit the official docker website to download docker desktop](https://docs.docker.com/desktop/setup/install/windows-install/)
2. Run the Installer
   - Execute the installer once downloaded.
   - Follow the prompts as seen.
   - Make sure the option to "Install WSL 2 backend" is selected during installation. This is recmmended for better performance overall.
   - Restart your machine once installation concludes.
3. Launch Docker Desktop
   - Open Docker Desktop from the desktop shorcut or start menu.
4. Verify Installation
    - To verify the installation of Docker open a terminal and run `docker --version`.
    - The command should return the docker verision and buiild number. If the command is not recognized docker may have not installed properly.
5. Test Docker
    - To test if docker can run containers run `docker run hello-world`.
    - If a message like, "Hello from Docker!" is returned the test was successful.
    - If this fails, make sure Docker Desktop is running and WSL2 was installed properly.

## Manually Setting up a Conatiner

As mentioned we will be setting up a container that hosts a static angular website. Below is how I set it up.

1. Extract the angular site files
2. Build the angular app locally by running the following commands:

     ```
     cd angular-site/wsu-hw-ng-main
    npm install
    npm run build -- --configuration production
    ```

4. Run a NGINX Container by running:

    ```
    docker run -d -p 8080:80 -v $(pwd)/angular-site/wsu-hw-ng-main/dist/wsu-hw-ng:/usr/share/nginx/html --name angular-container nginx:alpine
    ```

    **Flags/Arguments**:
    - `-d`: Runs container in detached mode (background).
    - `-p 8080:80`: Maps port 8080 on host to port 80 on the container.
    - `-v $(pwd)/angular-site/wsu-hw-ng-main/dist/wsu-hw-ng:/usr/share/nginx/html`: Mounts the `dist/wsu-hw-ng-main` folder to NGINX's web root.
    - `--name angular-container`: Name for the container
    - `nginx:alpine`: Uses lightweight Alpinge-based NGINX image.

### Commands needed internal to the container to get additional dependencies

For this basic angular app hosted/served by NGINX, no additional dependencies are needed inside the container.

The `nginx:alpine` image already includes NGINX, which is suffcient to serve static files.

### Commands needed internal to the container to run the application

The `nginx:alpine` image automatically starts NGINX when the conatiner is started, so no additional commands are needed.

Within the `nginx:alpine` image it is set to `["nginx", "-g", "daemon off;"]` which starts NGINX in the foreground.

### Verifying Conatiner is serving Angular app

#### Validate from Conatiner Side

1. Access the conatiner's shell by using the following command: `docker exec -it angular-container sh`

2. Check if the Angular files are in the specified path:
`ls /usr/share/nginx/html`

3. Verify NGINX is running:
   - Run `ps aux`
   - Then look for the NGINX process

4. Test the server locally by running: `curl http://localhost`

#### Validate from Host Side

1. Open a browser on your host machine
2. Goto `http://localhost:8080`.
3. The Angular app should load, displaying the eagle homepage.

## Dockerfile & Building Images

### Summary

To clarify I did not pre-build the application locally and copy the files manually. The build process occurs within the Docker container during the multi-stage build.

#### Stage 1 (Build)

- Base Image: `FROM node:lts-alpine AS build` - Uses lightweight Node.js image for builing stage.
- Working Directory: `WORKDIR /app` - Sets the working directory.
- Copy Files: `COPY angular-site/wsu-hw-ng-main /app/wsu-hw-ng-main` - Copies the Angular project into the container.
- Set Working Directory: `WORKDIR /app/wsu-hw-ng-main` - Changes work directory to where the angular.json file is.
- Install Dependencies: `RUN npm install` - Installs Node.js dependencies.
- Build App: `RUN npm run build -- --configuration production` - Builds Angular app for production.

#### Stage 2 (Runtime)

- Base Image: `FROM nginx:alpine` - Uses lightweight NGINX image to serve app.
- Copy Built Files: `COPY --from=build /app/wsu-hw-ng-main/dist/wsu-hw-ng /usr/share/nginx/html` - Copies the files from build stage to NGINX's web root directory.
- Expose Port: `EXPOSE 80`
- Start Nginx: `CMD ["nginx", "-g", "daemon off;"]` - Run NGINX in forground.

### Building a container with a Dockerfile

1. Navigate to the repository's root directory
2. Build the Docker image by running:`docker build -t <DOCKERHUBUSERNAME>/<LASTNAME>-ceg3120:latest .`
    - `-t <DOCKERHUBUSERNAME>/<LASTNAME>-ceg3120:latest`: tags the image with your docker hub username and repository name.
    - `.`: Specifiex the build context.

### Running a container that serves Angular app from image built by the Dockerfile

Run the following command to run the container from the image built eariler: `docker run -d -p 8080:80 --name angular-app <DOCKERHUBUSERNAME>/<LASTNAME>-ceg3120:latest`

- `-d`: Runs in detached mode.
- `p`: Maps port `8080` on the host side and `80` on the container's side.
- `--name angular-app`: Just a name for the conatiner to refrence easily.

### Verifying Conatiner is serving Angular app

#### Validate from Conatiner Side

1. Access the conatiner's shell by using the following command: `docker exec -it angular-container sh`

2. Check if the Angular files are in the specified path:
`ls /usr/share/nginx/html`

3. Verify NGINX is running: 
   - Run `ps aux`
   - Then look for the NGINX process

4. Test the server locally by running: `curl http://localhost`

#### Validate from Host Side

1. Open a browser on your host machine
2. Goto `http://localhost:8080`.
3. The Angular app should load, displaying the eagle homepage.

### Working with your DockerHub Repository

#### Creating a Public Repository in DockerHub

1. Login to DockerHub.
2. Click "Create Repository".
3. Name the repository `<LASTNAME>-ceg3120`.
4. Set visibility to "Public".
5. Click "Create".

#### Creating a PAT

1. Login to DockerHub
2. Goto your account settings
3. Navigate to Security > Personal Access Tokens.
4. Click "Generate new token".
5. Enter a description.
6. Set the scope to Read, Write, Delete.
7. Copy the generated token and store it securely.

#### Autenticating with DockerHub via CLI

Authenticate using the PAT that was created:

- `docker login -u your-dockerhub-username --password <PAT>`
- replace `<PAT>` with your PAT.

#### Pushing the container image to DockerHub Repository

Use the following command to push your image to DockerHub:

- `docker push <DOCKERHUBUSERNAME>/<LASTNAME>-ceg3120:latest`

#### Link to `omb9/bhavsar-ceg3120`

[omb9/bhavsar-ceg3120](https://hub.docker.com/r/omb9/bhavsar-ceg3120)

___

## Part 2 - GitHub Actions and DockerHub

### Configuring GitHub Repository Secrets

#### Create DockerHub PAT

The first thing to do in order to setup secrets is to have something to keep secret. Below is a walkthrough of how to generate a Personal Access Token (PAT) for a Docker account.

1. Login to DockerHub.
2. Goto your account settings
3. Navigate to Security > Personal Access Tokens.
4. Click "Generate new token".
5. Enter a description.
6. Set the scope to Read, Write.
7. Copy the generated token and store it securely.

#### Setting Up Repoistory Secrets

Now that the PAT has been created it needs to be stored and reffered to securly. Below is a walkthrough of how to create GitHub repoistory secrets.

1. Login to GitHub.
2. Navigate to your repoistory.
3. Click "Settings", located on the top menu.
4. Click "Secrets and variables".
5. From the dropdown select "Actions".
6. Click "New repository secret".
7. Copy the PAT from DockerHub to "Secret*".
8. In the "Name*" field the PAT can be named "DOCKER_TOKEN".
9. Create one more repoistory secret for your Docker username.
10. In the "Name*" field the username can be named "DOCKER_USERNAME".
11. Enter your docker username in the "Secret*" field in all lowercase characters.

#### Secrets Utilized For This Project

There were only two secrets used for this project:

- DOCKER_USERNAME - Is your DockerHub username, so GitHub can authenticate to DokcerHub behalf of you.
- DOCKER_TOKEN - Is your PAT, so GitHub can update the DockerHub repository.

### CI with GitHub Actions

#### Workflow Summary

- Name: CI
- Trigger: Pushes to the main branch
- Job: Build & Push a Docker image to DockerHub

#### Explanation of Workflow Steps

1. Checkout code
   - `actions/checkout@v3` action is to check out the repository code, which makes it available to the workflow.
2. Login to DockerHub
   - `docker/login-action@v3` action is to login to DockerHub.
   - Credentials are provided by the GitHub secrets.
3. Build & Push Docker Image
   - `docker/build-push-action@v5` action is to build a Docker image from the current directory and push it to DockerHub.
   - The image is also tagged with [UserName]/[LastName]-ceg3120:latest

#### Values to Update for Different Repositories

If this workflow is to be used in a different repository, the following values need to be updated:

1. DcokerHub Credentials:
   - Make sure the `DOCKER_USERNAME` & `DOCKER_TOKEN` secrets are updated to reflect new repository settings
   - The account that will be hosting the docker image on DockerHub needs to have its username and token filed in.
2. Image Tag:
   - The current tag is `${{ secrets.DOCKER_USERNAME }}/bhavsar-ceg3120:latest`
   - Update `bhavsar-ceg3120:latest` to match your last name or anything that is appropriate.

#### Link to Workflow

- [CI.yml](https://github.com/WSU-kduncan/ceg3120-cicd-OmB9/blob/main/.github/workflows/ci.yml)

### Testing & Validation

#### Testing

- Trigger the workflow by pushing to main or manually with workflow_dispathch.
- Verify the image exists on DockerHub with correct tag and timestamp.

#### Validation

- Pull image from DockerHub.
- Run a container.
- Check logs and test functionality.

## Refrences

- [Installing Docker Desktop](https://www.youtube.com/watch?v=rATNU0Fr8zs)
- [Course Notes](https://github.com/pattonsgirl/CEG3120/blob/main/CourseNotes/containers.md)
- [How to create a Docker Container](https://www.youtube.com/watch?v=SnSH8Ht3MIc)
- Generative AI: `How to create a DockerFile that serves a angular application. Please include best practices and go over all steps.`
- [Docker Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Further reasrch into Angular CLI](https://v17.angular.io/cli/build)
- [NGINX Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html)
- [How to create secrets in GitHub Repo](https://www.youtube.com/watch?v=LRAnMQI0Nlo)
- [Creating a PAT for DockerHub](https://docs.docker.com/security/for-developers/access-tokens/)
- Generative AI: `How to configure a GitHub action to build and push a Docker image`
- [GitHub Actions Introduction](https://docs.docker.com/guides/gha/)
- [Docker Build Push action](https://github.com/docker/build-push-action#usage)
- [Mermaid in Markdown](https://www.youtube.com/watch?v=qGsQolMh9zE)
- [Mermaid getting started](https://mermaid.js.org/intro/getting-started.html)
- [Mermaid VS Code extension](https://marketplace.visualstudio.com/items/?itemName=bierner.markdown-mermaid)
  