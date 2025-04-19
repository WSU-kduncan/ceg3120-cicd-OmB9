# Project 5 - CD

## Project Overview

Coming soon<sup>TM</sup>

## Part 1 - Semantic Versioning

### Generating Tags

#### Checking Tags in a git Repository

To see tags in a git repository run the following command:

```bash
git tag
```

This command will list all tags present locally.

To view tags in the remote repository use:

```bash
git ls-remote --tags origin
```

#### Generating Tags in a git Repository

To generate a basic tag without metadata use:

```bash
git tag v1.0.0
```

To generate a tag with an annotation (metadata) use:

```bash
git tag v1.0.0 -m "Initial release"
```

Replace the `v1.0.0` with a desired tag/verision number.

Replace `Initial release" with a desired annotation.

#### Pushing a tag to GitHub

To push a tag(s) use the following commands:

To push a specific tag to GitHub use:

```bash
git push origin v1.0.0
```

To push all local tags to GitHub use:

```bash
git push origin --tags
```

### Semantic Versioning Container Images with GitHub Actions

This project

#### Summary of Workflow

- The workflow gets triggered whenever a tag matching the semantic versioning format is pushed.
- Builds Docker image from the Dockerfile
- Generates three tags for the image:
  - latest
  - Major version
  - Major.minor verision
- Pushes the image to DockerHub with those tags.

#### Explanation of Workflow Steps

Below is the workflow file being used:

```yml
name: CI

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Generate Docker metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ secrets.DOCKER_USERNAME }}/bhavsar-ceg3120
          tags: |
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}
            type=semver,pattern={{major}}.{{minor}}
            type=raw,value=latest

      - name: Login to DockerHub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}

```

1. Checkout Code: `actions/checkout@v3` to grab the repository code.
2. Generate Metadata: `docker/metadata-action@v5` is used to create tags based on the git tag.
3. Login to DockerHub: `docker/login-action@v3` is used along with the secrets to authenticate to DockerHub.
4. Build and Push Image: `ocker/build-push-action@v5` is used to build the image and push it to DockerHub with the aforementioned tags.

#### Changes in Workflow

I updated my existing workflow yaml file to accommodate the workflow with tags.

The most noteable changes are the on push tags and generating docker metadata portions of the file.

#### Link to Workflow

[CI.yml](https://github.com/WSU-kduncan/ceg3120-cicd-OmB9/blob/main/.github/workflows/ci.yml)

### Testing & Validating

#### Test Workflow is Working

To test the workflow works as intended follow these steps:

1. Create and push a new tag:

    ```bash
    git tag -a v1.0.1 -m "Test release"
    git push origin v1.0.1
    ```

2. Navigate to the "Actions" tab in your GitHub repository.
3. Verify workflow ran successfully.

#### Verify Image Runs

1. Pull the image from DockerHub:

    ```bash
    docker pull [DockerUsername]/[RepoName]:1.0
    ```

- Make sure to replace `[DockerUsername]` with your username and `[RepoName]` with your repo name.

2. Run a container:

    ```bash
    docker run -p 8080:80 [DockerUsername]/[RepoName]:1.0
    ```

- Make sure to replace `[DockerUsername]` with your username and `[RepoName]` with your repo name.

3. Open a browser and go to `http://localhost:8080` to verify the application runs as expected.

## Refrences

- [GitHub Tags Tutorial](https://www.youtube.com/watch?v=govmXpDGLpo)
- [Docker Tagging KB](https://docs.docker.com/build/ci/github-actions/manage-tags-labels/)
- [Git-Based Semantic Versioning](https://github.com/marketplace/actions/git-semantic-version)
