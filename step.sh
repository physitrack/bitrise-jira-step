#!/bin/bash
#

# When either is unset.
if [ -z "$pull_request_id" ] || [ -z "$jira_issue" ]; then
	echo "Extracting values from merge commit message."
	# Check if this is a no ticket type merge.
	if [[ $BITRISE_GIT_MESSAGE == *"[NO-TICKET]"* ]]; then
		echo "This commit has no assigned ticket."
		exit -1
	fi

	# Extract JIRA issue identifier from commit message.
	jira_issue=`echo $BITRISE_GIT_MESSAGE | egrep -o '[A-Z]+-[0-9]+' | head -n 1`

	if [ ! "$jira_issue" ]; then
		echo "Commit message does not contain correct JIRA issue ID."
		exit -1
	fi

	# Extract Pull Request identifier from commit message.
	pull_request_id=`echo $BITRISE_GIT_MESSAGE | egrep -o '#[0-9]+' | head -n 1`

fi

repository_url=`echo "$GIT_REPOSITORY_URL" | sed 's/.git//g' | tr : /`
pull_request_url="https://$repository_url/pull/$pull_request_id"

# Generate comment body.

comment_body="[Pull Request|$pull_request_url] for ticket $jira_issue was merged.\nCan be tested using build: #$BITRISE_BUILD_NUMBER"

echo $comment_body
comment_url=$host/rest/api/2/issue/$jira_issue/comment
echo "$comment_url"

# Add comment on JIRA.
curl -D- -o /dev/null -u $user:$api_token -X POST -H "Content-Type: application/json" -d "{\"body\": \"$comment_body\"}" $comment_url

transition_url=$host/rest/api/2/issue/$jira_issue/transitions
echo "$transition_url"

# Move ticket.
res=$( curl -w %{http_code} -s --output /dev/null -D- -u $user:$api_token -X POST -H "Content-Type: application/json" -d "{\"transition\": {\"id\" : \"$transition_id\"} }" $transition_url)