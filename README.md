# get-pr-info-action

This action outputs the merged PR information based on the gha. 

- This action works best for finding the merged PR.
- After merge the PR can be decorated, updated with comments etc.,

## Pre-requisites

- actions/checkout should be invoked so that the repository is clone and available in the workspace.
- A runner with `gh` and `awk` installed. Recommened to use runner-image [adiseshan/gh:v2.37.0](https://hub.docker.com/repository/docker/adiseshan/gh/general)


# What's new

Please refer to the [release page](https://github.com/adiseshan/get-pr-info-action/releases/latest) for the latest release notes.

# Usage

<!-- start usage -->
```yaml
# Pre-requisite to release a new version.
- uses: actions/checkout@v3
  with:
    fetch-depth: 0

- name: Extract PR number
  id: get-pr-info
  uses: adiseshan/get-pr-info-action@v1
  with:
    # Optional. In case of GHE. eg., github.xxx-internal.com
    # Default: github.com
    INPUT_GITHUB_HOSTNAME: ''
    # Secret PAT with `repo` priviledge
    # [Learn more about creating and using encrypted secrets](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets)
    INPUT_GITHUB_TOKEN: ''
    # The git sha to be considered for finding merged pull request.
    INPUT_GITHUB_SHA: ''
```
<!-- end usage -->

# Examples 

## For github enterprise repositories


```yaml
name: create new release

on:
  push:
    branches:
      - master
  workflow_dispatch:
    inputs:
      TAG_NAME:
        description: 'tag name. If empty, new version will be auto calculated.'

env:
  GITHUB_HOSTNAME: github.com
  GITHUB_TOKEN: ${{ secrets.BOT_GITHUB_TOKEN }}

jobs:
  create-new-release:
    runs-on: ubuntu-latest
    container: 
      image: adiseshan/gh:v1.0.0
      credentials:
        username: ${{ secrets.DOCKER_USER }}
        password: ${{ secrets.DOCKER_TOKEN }}
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Extract PR number
        id: get-pr-from-git-sha
        uses: adiseshan/get-pr-info-action@v1
        with:
          INPUT_GITHUB_HOSTNAME: ${{ env.GITHUB_HOSTNAME }}
          INPUT_GITHUB_TOKEN: ${{ env.GITHUB_TOKEN }}
          INPUT_GITHUB_SHA: ${{ github.sha }}

      - name: debug
        shell: bash
        run: |
          echo PR_NUMBER ${PR_NUMBER}
        env:
          PR_NUMBER: ${{ steps.get-pr-from-git-sha.outputs.OUTPUT_PR_NUMBER }}
```
