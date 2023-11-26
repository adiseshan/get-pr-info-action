#!/bin/bash
# Env Pre requisites
# INPUT_GITHUB_SHA: Input git sha to search.
# INPUT_GITHUB_TOKEN: With read priviledges.
# INPUT_GITHUB_HOSTNAME: github.com or the GHE hostname.

set -o pipefail

validate() {
    gh version
}

setup() {
    git config --global --add safe.directory "*"
    echo "${INPUT_GITHUB_TOKEN}" | gh auth login --hostname "${INPUT_GITHUB_HOSTNAME}" --git-protocol https --with-token
    git_status_check_cmd="gh auth status --hostname ${INPUT_GITHUB_HOSTNAME}"
	if ! ${git_status_check_cmd}; then
        echo "git status check failed for hostname ${INPUT_GITHUB_HOSTNAME}. "
        exit 1
    fi

}

main() {
    validate
    setup
    echo "identifying PR for the GITHUB_SHA ${INPUT_GITHUB_SHA}"
    pr_number=$(gh pr list --search "${INPUT_GITHUB_SHA}" --state merged --json number --jq '.[0].number')
    echo "identified pr_number as ${pr_number}"
    echo "::set-output name=pr_number::${pr_number}"
    if [[ -n "${pr_number}" ]]; then
        pr_info=$(gh pr view "${pr_number}" --json=title,url,body --jq '"\(.url)\n\(.title)\n\(.body)"')
        pr_url=$(awk 'NR==1' <<< "${pr_info}")
        pr_title=$(awk 'NR==2' <<< "${pr_info}")
        pr_body=$(awk 'NR>2' <<< "${pr_info}")
        echo "identified2 pr_url as ${pr_url}"
        echo "identified2 pr_title as ${pr_title}"
        echo "identified2 pr_body as ${pr_body}"
        echo "::set-output name=pr_title::${pr_title}"
        # echo "::set-output name=pr_body::${pr_body}" #multi line output. TODO
        echo "::set-output name=pr_url::${pr_url}"
    fi
}

main "$@"
