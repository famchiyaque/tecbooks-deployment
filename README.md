Deployment Repository for TecBooks/MxRep Stack

# Purpose

This repo has the docker configurations for the correct deployment of both the backend (MxRep-Backend) repo and the frontend (TecBooks_V2) repo, which should be on the same level as this directory, named 'backend' and 'frontend'.

# Contents

There contents will consist of docker compose files for both development and production environments, as well as the nginx configurations for connection to the tecbooks domain, and scripts for deployment/re-deployment of the container.

# Configurations

The services as of now to include in the docker container will be the frontend react app, backend nodejs app, and nginx reverse proxy.