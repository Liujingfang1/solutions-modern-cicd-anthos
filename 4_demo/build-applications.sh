#!/bin/bash -x

if [ -z ${GITLAB_HOSTNAME} ];then
  read -p "What is the GitLab hostname (i.e. my.gitlab.server)? " GITLAB_HOSTNAME
fi
if [ -z ${GITLAB_TOKEN} ];then
  read -p "What is the GitLab token? " GITLAB_TOKEN
fi

SERVICES="hipster-loadgenerator hipster-shop hipster-frontend petabank"

for service in ${SERVICES}; do
  SERVICE_DIRECTORY="${service}-clone"
  rm -rf ${SERVICE_DIRECTORY}
  git clone https://root:${GITLAB_TOKEN}@${GITLAB_HOSTNAME}/${service}/${service}.git ${SERVICE_DIRECTORY}
  pushd ${SERVICE_DIRECTORY}
    # TODO: Remove when each microservice has it's own Gitlab project
    if [ "${service}" == "hipster-shop" ]; then
      HIPSTER_EXISTS=$(ls k8s/stg | grep -e "adservice.yaml")
      if [ -z "${HIPSTER_EXISTS}" ]; then
        git rm -r Dockerfile main.go skaffold.yaml k8s .gitlab-ci.yml
        cp -r ../../starter-repos/hipster-shop/. ./
        sed -i.bak "s/GITLAB_HOSTNAME/${GITLAB_HOSTNAME}/g" k8s/stg/kustomization.yaml
        sed -i.bak "s/GITLAB_HOSTNAME/${GITLAB_HOSTNAME}/g" k8s/prod/kustomization.yaml
        sed -i.bak "s/GITLAB_HOSTNAME/${GITLAB_HOSTNAME}/g" k8s/dev/kustomization.yaml
        rm k8s/stg/kustomization.yaml.bak
        rm k8s/prod/kustomization.yaml.bak
        rm k8s/dev/kustomization.yaml.bak

        git add .
        git commit -m "Initial commit"
        git push -u origin master
      else
        echo "Hipster Shop source code is already pushed to remote master!"
      fi
    else
      # Check if template files have already been replaced
      SERVICE_EXISTS=$(ls k8s/stg | grep -e "${service}.yaml")
      if [ -z "${SERVICE_EXISTS}" ]; then
        # If template files have not been replaced, delete them
        git rm -r Dockerfile main.go skaffold.yaml k8s .gitlab-ci.yml
        # Copy the source code files
        cp -r ../../starter-repos/${service}/. ./
        # Replace GITLAB_HOSTNAME with our own domain
        sed -i.bak "s/GITLAB_HOSTNAME/${GITLAB_HOSTNAME}/g" k8s/stg/kustomization.yaml
        sed -i.bak "s/GITLAB_HOSTNAME/${GITLAB_HOSTNAME}/g" k8s/prod/kustomization.yaml
        sed -i.bak "s/GITLAB_HOSTNAME/${GITLAB_HOSTNAME}/g" k8s/dev/kustomization.yaml
        rm k8s/stg/kustomization.yaml.bak
        rm k8s/prod/kustomization.yaml.bak
        rm k8s/dev/kustomization.yaml.bak

        # Commit & push the code back to Gitlab
        git add .
        git commit -m "Initial commit"
        git push -u origin master
      else
        echo "${SERVICE_NAME} source code is already pushed to remote master!"
      fi
    fi
  popd
done

