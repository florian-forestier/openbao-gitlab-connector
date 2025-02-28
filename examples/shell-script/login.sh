#!/usr/bin/env bash

### Part 1 - Login to OpenBAO and retrieve a OpenBAO Token, using CI_JOB_TOKEN or GITLAB_TOKEN

# Login to OpenBAO using multiple methods (CI auto-login or Gitlab token)
if [ -n "$CI_COMMIT_SHA" ]; then
  echo "CI detected. Retrieving openbao token for this job ..."
  OPENBAO_TOKEN=$(curl -s -X POST -k --data "{\"token\":\"$CI_JOB_TOKEN\"}" $OPENBAO_ADDR/v1/auth/gitlab/ci | python3 /tools/jq.py "auth/client_token")
else #Login through Gitlab Token
  if [ -z "$GITLAB_TOKEN" ]; then
    echo "GITLAB_TOKEN is missing. Please enter your GitLab token: "
    read -sr GITLAB_TOKEN_INPUT
    export GITLAB_TOKEN=$GITLAB_TOKEN_INPUT
  fi
  echo "Gitlab Token detected. Retrieving openbao token for this gitlab token ..."
  OPENBAO_TOKEN=$(curl -s -X POST -k --data "{\"token\":\"$GITLAB_TOKEN\"}" "$OPENBAO_ADDR/v1/auth/gitlab/login" | python3 /tools/jq.py "auth/client_token")
fi

export OPENBAO_TOKEN=$OPENBAO_TOKEN


### Part 2 - Retrieve a secret and export content

# Retrieve whole secret
OPENBAO_SECRET=$(curl -s -X GET -k --header "X-Vault-Token: $OPENBAO_TOKEN" "$OPENBAO_ADDR/v1/gitlab/data/path/to/my/secret")

# Export variables
export USER=$(echo "$OPENBAO_SECRET" | python3 /tools/jq.py "data/data/user")
export PASS=$(echo "$OPENBAO_SECRET" | python3 /tools/jq.py "data/data/pass")
