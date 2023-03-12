# TD Docker

- [TD Docker](#td-docker)
  - [Steps](#steps)

## Steps

### 1

```bash
// Add Dockerfile and build
$ docker build -t myproject .

// Run container
$ docker run -it --rm myproject
```

### 2

Fill out your gitlab runner registration token in the `.env` file.

```bash
// Execute runner registration script
$ chmod +x exec_runner.sh
$ ./exec_runner.sh
$ sudo docker exec -it myproject-runner-1 gitlab-runner register
```

![img](https://i.ibb.co/FWR6hg6/Screenshot-from-2023-03-08-21-26-51.png)

### 3

```bash
// Clone GitLab repository
$ git clone https://git.marmous.net/marmous/cesi-continuousintegration.git

// Init git on the local gitlab instance
$ git init
$ git remote add origin http://localhost/agerard57/cesi-continuousintegration.git
```

### 4

To build the HmgAPI and ConsoleDebugger applications on every push to GitLab, we create a .gitlab-ci.yml file in `./.gitlab.ci/`. This folder contains the configuration files for GitLab's CI/CD. For better visibility, each stage is going to be in a separate file, and the `.gitlab-ci.yml` file will include all of them.
So we start by creating a `.build.yml` file that contains the build stage.

### 5

The test stage now runs after the build stage, and it includes a script that changes to the HmgAPI directory and runs the dotnet test command. The test stage uses the same Docker image as the build stages, so there's no need to install any additional dependencies. The artifacts section is not needed for the test stage, as it doesn't generate any artifacts.

### 6

We add a new job that builds and pushes a Docker image to the Docker registry. We have also add an `only` directive to only trigger this stage when a push is made to the master branch.

### 7

To push a Docker image to Docker Hub on each push only if the push concerns the master branch:

- Set up the Docker Hub credentials as environment variables in the GitLab project settings (i.e. `DOCKER_USERNAME` and `DOCKER_PASSWORD`).
  Optional: Set up the container registry and image url as variables
  ![img](https://i.ibb.co/LSngBKq/image.png)

- Add a docker-build stage to build the Docker image: this stage builds the Docker image using the Dockerfile and tags it with the Git commit short SHA.

- Add a docker-push stage to push the Docker image to Docker Hub: this stage pushes the Docker image to Docker Hub using the variables.

### 8

We add a new stage named `clean` that remove preexisting Docker images. This stage always executes, and errors are allowed without failing the pipeline.

### 9

We add to the `test` stage `functional_test` that executes a script that runs `ConsoleDebugger` with an argument. It then generates a maze image and saves it as `console_debugger_test_${timestamp}.maze`. We specify that this file should be saved as an artifact after the stage completion.

### 10

To tag the image with the short commit id (aka SHA), we use `tag` and `${CI_COMMIT_SHORT_SHA}` (also works with `-t`)

```yml
    - docker tag "${DOCKER_REPO}:latest" "${DOCKER_REPO}:${CI_COMMIT_SHORT_SHA}"
```

### 11

We add a timestamp variable as `=$(date +%Y.%m.%d.%H%M)` that will get us the **yyyy.mm.dd.hhmm** format. We apply the tag exactly as above.

### 12

- Click on the "Settings" button on the left-hand side of the page.
- Click on the "CI/CD" tab.
- In "General pipelines", copy the badge URL for the variable you want to display the status of.
- Paste the badge URL into your documentation or README file.

The badge URL for a variable in GitLab CI/CD has the following format:

`https://agerard57.com/gitlab-instance/dockertd/badges/main/pipeline.svg`

![img](https://i.ibb.co/G9BhGW9/image.png)

### 13

This new `coverage_test` job is used to generate test coverage reports for a .NET project. It runs tests using the `dotnet test` command and generates a coverage report in Cobertura format using the `coverlet.msbuild` package.

### 14

The test coverage percentage is extracted from the report using a regular expression specified in the `coverage` section of the job and is displayed as a coverage badge in the GitLab UI (same method as for the other badge).

`https://agerard57.com/gitlab-instance/dockertd/badges/main/coverage.svg`

![img](https://i.ibb.co/ScSJjnJ/image.png)

### 15

To deploy in a staging environment, we start by creating a new `docker-compose.yml` file (`.>deploy>staging>docker-compose.yml`).

![image](https://i.ibb.co/Sr6Jqxp/image.png)

Now, we add two new jobs that start and stop staging.

In Gitlab, we can now see that the staging environment is up.

![image](https://user-images.githubusercontent.com/56207146/224524352-9dd3c6a2-2831-487c-8aca-b0fb82b74815.png)

![image](https://user-images.githubusercontent.com/56207146/224524340-5e0e755c-7eee-4d1e-ba4e-08076c7547ef.png)


### 16

Same as above, except we add the `docker-compose.yml` file in `.>deploy>prod`), with another port.

![image](https://i.ibb.co/jLXdgLH/image.png)

`when: manual` will ensure that prod can only be deployed manually.

### 17

This new job called `container_scan` will execute a scan when master is triggered. The result will be stored in a file named `syftresult_${timestamp}.json`
