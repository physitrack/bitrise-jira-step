# bitrise-jira-step

This Bitrise step moves the ticket linked with the PR to another column and adds comment with information about build.


## How to use

Add step definition. 
```YML
 comment:
    steps:
      - git::https://github.com/physitrack/bitrise-jira-step.git@master:
          title: bitrise-jira-step
          inputs:
            - host: $JIRA_HOST
            - user: $JIRA_USER
            - api_token: $JIRA_API_TOKEN
            - transition_id: $JIRA_TRANSAITION_ID
```
You can check the transition available for given issue by running:
```bash
curl -D- -u user:api_token -X GET JIRA_HOST/rest/api/2/issue/JIRA_ISSUE/transitions
```
As a `$JIRA_ISSUE` (format: XXX-1234) use id for the ticket that is currently in the column from which you would like to move it.

As a `$user` use your account email address.

API token used to authenticate can be created [here](https://id.atlassian.com/manage/api-tokens?_ga=2.43946604.875494627.1562923837-75487430.1434788493)
