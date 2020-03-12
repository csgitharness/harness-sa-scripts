#!/bin/bash

## Variables
EMAIL=""
NAME=""
USERGROUPID=""
USERGROUPNAME=""
USERID=""
APPNAME=""
CURL_URL="https://app.harness.io/gateway/api/graphql?accountId=$HARNESS_ACCOUNT_ID"
QUERY1='{"query":"{\n applications(limit: 5){\n  pageInfo{\n   total\n  }\n  nodes{\n   name\n  }\n }\n \n}","variables":{}}'

# 1. Create a user group
# 2. create a user
# 3. add to a user group
# 4. Add Permissions to that Group (limit it to application)
# 5. Scope the application to the group, get the ID

# '{"query":"{\n  userGroups(limit:20, offset:0){\n    nodes{\n      id\n      name\n    }\n  }\n}","variables":null}' --compressed > listusergroup.json
# jq '.data.userGroups.nodes[] | select(.name=="'$USERGROUPNAME'")' listusergroup.json > group.json

# Get the list of user groups
fn_common_exc(){
curl -s -X POST $CURL_URL \
-H "x-api-key: $HARNESS_KEY" \
-H 'Content-Type: application/json' \
--data-binary @-
}

fn_get_user_group1(){
echo "Fetch existing user groups"
echo $QUERY1 | fn_common_exc > applist.json
}

fn_get_user_groups(){
echo "Fetch existing user groups"
curl $CURL_URL \
-H 'x-api-key: '$HARNESS_KEY'' \
-H 'content-type: application/json' \
--data-binary '{"query":"{\n  userGroups(limit:20, offset:0){\n    nodes{\n      id\n      name\n    }\n  }\n}","variables":null}' --compressed > listusergroup.json
jq '.data.userGroups.nodes[] | select(.name=="'$USERGROUPNAME'")' listusergroup.json > group.json
USERGROUPID=$(cat group.json | jq -r '.id')
echo $USERGROUPID
rm -rf group.json
}

# Create a user group
fn_create_user_group(){
echo "****Creating a User Group****"
curl 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID'' \
 -H 'x-api-key: '$HARNESS_KEY'' \
 -H 'content-type: application/json' \
 --data-binary $'{"query":"mutation($userGroup: CreateUserGroupInput\u0021){\\n  createUserGroup (input:$userGroup) {\\n    userGroup {\\n      id\\n      name\\n      description\\n      isSSOLinked\\n      importedByScim\\n      notificationSettings {\\n        sendNotificationToMembers\\n        sendMailToNewMembers\\n        slackNotificationSetting {\\n          slackChannelName\\n          slackWebhookURL\\n        }\\n        groupEmailAddresses\\n      }\\n    }\\n  }\\n}","variables":{"userGroup":{"name":"'$USERGROUPNAME'"}}}' --compressed > usergroup.json
USERGROUPID=$(cat usergroup.json | jq -r '.data.createUserGroup.userGroup.id')
echo $USERGROUPID
rm -rf usergroup.json
}
##  Create A User
fn_create_user(){
echo "*****Creating a User*****"
curl 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID'' \
 -H 'authority: app.harness.io' \
 -H 'x-api-key: '$HARNESS_KEY'' \
 -H 'origin: https://app.harness.io' \
 -H 'content-type: application/json' \
 -H 'accept: */*' \
 -H 'sec-fetch-site: same-origin' \
 -H 'sec-fetch-mode: cors' \
 -H 'referer: https://app.harness.io/' \
 -H 'accept-encoding: gzip, deflate, br' \
 -H 'accept-language: en-US,en;q=0.9' \
 --data-binary $'{"query":"mutation createUser($user: CreateUserInput\u0021) {\\n  createUser(input: $user) {\\n    user {\\n      id\\n      email\\n      name\\n  \\t}\\n  }\\n}","variables":{"user":{"name":"'$NAME'","email":"'$EMAIL'","userGroupIds":[]}},"operationName":"createUser"}' --compressed > user.json
USERID=$(cat user.json | jq -r  '.data.createUser.user.id') 
echo $USERID
rm -rf user.json
}
## Update a User Group
fn_update_user_group(){
echo "***Updating a User Group***"
curl 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID'' \
 -H 'authority: app.harness.io' \
-H 'x-api-key: '$HARNESS_KEY'' \
-H 'origin: https://app.harness.io' \
-H 'content-type: application/json' \
-H 'accept: */*' \
-H 'sec-fetch-site: same-origin' \
-H 'sec-fetch-mode: cors' \
-H 'referer: https://app.harness.io/' \
-H 'accept-encoding: gzip, deflate, br' \
-H 'accept-language: en-US,en;q=0.9' \
--data-binary $'{"query":"mutation ($userGroup: UpdateUserGroupInput\u0021) {\\n  updateUserGroup(input: $userGroup) {\\n    clientMutationId\\n    userGroup {\\n      id\\n      name\\n      description\\n      isSSOLinked\\n      importedByScim\\n      users(limit: 190, offset: 0) {\\n        pageInfo {\\n          total\\n        }\\n        nodes {\\n          name\\n          email\\n        }\\n      }\\n      notificationSettings {\\n        sendNotificationToMembers\\n        sendMailToNewMembers\\n        slackNotificationSetting {\\n          slackChannelName\\n          slackWebhookURL\\n        }\\n        groupEmailAddresses\\n      }\\n  \\t}\\n  }\\n}","variables":{"userGroup":{"userGroupId":"'$USERGROUPID'","name":"'$USERGROUPNAME'","userIds":["'$USERID'"],"notificationSettings":{"sendMailToNewMembers":true,"sendNotificationToMembers":true}}}}' --compressed
}
# Add permissions to the group
fn_add_permissions(){
echo "*****adding permissions to the group****"
curl 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID'' \
 -H 'authority: app.harness.io' \
 -H 'x-api-key: '$HARNESS_KEY'' \
 -H 'origin: https://app.harness.io' \
 -H 'content-type: application/json' \
 -H 'accept: */*' \
 -H 'sec-fetch-site: same-origin' \
 -H 'sec-fetch-mode: cors'
 -H 'referer: https://app.harness.io/' \
 -H 'accept-encoding: gzip, deflate, br' \
 -H 'accept-language: en-US,en;q=0.9' \
--data-binary $'{"query":"mutation($userGroup: UpdateUserGroupPermissionsInput\u0021){\\n  updateUserGroupPermissions (input:$userGroup) {\\n      permissions {\\n        accountPermissions{\\n          accountPermissionTypes\\n        }\\n        appPermissions {\\n          permissionType\\n          applications {\\n            filterType\\n            appIds\\n          }\\n          applications{\\n          filterType\\n            appIds\\n          }\\n        }\\n      }\\n  }\\n}\\n\\n","variables":{"userGroup":{"userGroupId":"'$USERGROUPID'","permissions":{"accountPermissions":{"accountPermissionTypes":["READ_USERS_AND_GROUPS","MANAGE_TEMPLATE_LIBRARY","VIEW_AUDITS"]},"appPermissions":[{"permissionType":"ALL","applications":{"appIds":["'$APPID'"]},"actions":["CREATE","READ","UPDATE"]}]}}}}' --compressed
}

# Get the list of Apps 
fn_get_apps(){
echo "****getting list of applications****"
curl 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID'' \
-H 'authority: app.harness.io'  \
-H 'x-api-key: '$HARNESS_KEY''\
-H 'origin: https://app.harness.io' \
-H 'content-type: application/json' \
-H 'accept: */*' \
-H 'sec-fetch-site: same-origin' \
-H 'sec-fetch-mode: cors' \
-H 'referer: https://app.harness.io/' \
-H 'accept-encoding: gzip, deflate, br' \
-H 'accept-language: en-US,en;q=0.9' \
--data-binary '{"query":"{\n  applications(limit:20, offset:0){\n    nodes{\n      name\n      id\n    }\n  }\n}","variables":null}' --compressed > apps.json
jq '.data.applications.nodes[] | select(.name=="'$APPNAME'")' apps.json > a.json
APPID=$(cat a.json | jq -r '.id')
echo $APPID
rm -rf a.json
}
### Main ###
FLAG=$1
EMAIL=$2
NAME=$3
USERGROUPNAME=$4
APPNAME=$5
if [ $# -lt 5 ]; then
echo "ERROR: Not enough arguments"
echo "<FLAG> <EMAIL> <USER_NAME> <USER_GROUP_NAME> <APPNAME>"
exit 0
fi 

if [ "$1" == "-user" ]; then 
fn_get_user_group1
exit 0 
fi

if [ "$1" == "-add" ]; then
  fn_get_user_groups
  fn_create_user
  fn_update_user_group
  fn_get_apps
  fn_add_permissions
fi
if [ "$1" == "-create" ]; then
  fn_create_user_group
  fn_create_user
  fn_update_user_group
  fn_get_apps
  fn_add_permissions
fi
