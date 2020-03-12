#!/bin/bash

# Create Application
APP_NAME="SampleApp"
APP_DESCRIPTION="Created by Automation Script"

fn_create_app(){
echo "Creating an Application"
curl 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID'' \
-H 'x-api-key: '$HARNESS_KEY'' \
-H 'content-type: application/json' \
--data-binary $'{"query":"mutation createapp($app: CreateApplicationInput\u0021) {\\n  createApplication(input: $app) {\\n    clientMutationId\\n    application {\\n      name\\n      id\\n    }\\n  }\\n}","variables":{"app":{"clientMutationId":"req9","name":"'$APP_NAME'","description":"'$APP_DESCRIPTION'"}},"operationName":"createapp"}' --compressed
}



# Delete Application 
APP_ID="uP22_SFwTHe_-qYwzkm9mA"
fn_delete_app(){
echo "Deleting Application" 
curl 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID'' \
-H 'x-api-key: '$HARNESS_KEY'' \
-H 'content-type: application/json' \
 --data-binary $'{"query":"mutation deleteapp($app: DeleteApplicationInput\u0021) {\\n  deleteApplication(input: $app){\\n    clientMutationId\\n  }\\n}","variables":{"app":{"applicationId":"'$APP_ID'"}},"operationName":"deleteapp"}' --compressed
}


# Create User Group
USERGROUPNAME="SampleGroup"
fn_create_user_group(){
echo "****Creating a User Group****"
curl 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID'' \
 -H 'x-api-key: '$HARNESS_KEY'' \
 -H 'content-type: application/json' \
 --data-binary $'{"query":"mutation($userGroup: CreateUserGroupInput\u0021){\\n  createUserGroup (input:$userGroup) {\\n    userGroup {\\n      id\\n      name\\n      description\\n      isSSOLinked\\n      importedByScim\\n      notificationSettings {\\n        sendNotificationToMembers\\n        sendMailToNewMembers\\n        slackNotificationSetting {\\n          slackChannelName\\n          slackWebhookURL\\n        }\\n        groupEmailAddresses\\n      }\\n    }\\n  }\\n}","variables":{"userGroup":{"name":"'$USERGROUPNAME'"}}}' --compressed 
}

# Delete User Group 
USERGROUPID="fqn3QnvYSAOjhAMkc7YxIw"
fn_delete_user_group(){
curl 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID'' \
 -H 'x-api-key: '$HARNESS_KEY'' \
 -H 'content-type: application/json' \
--data-binary $'{"query":"mutation($userGroup: DeleteUserGroupInput\u0021){\\n  deleteUserGroup (input:$userGroup) {\\n\\t\\tclientMutationId\\n  }\\n}","variables":{"userGroup":{"userGroupId":"'$USERGROUPID'"}}}' --compressed
}


# Create a User
USEREMAIL="sample@harness.io"
USERNAME="captainCanary"

fn_create_user(){
curl 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID'' \
-H 'x-api-key: '$HARNESS_KEY'' \
-H 'content-type: application/json' \
--data-binary $'{"query":"mutation($user: CreateUserInput\u0021){\\n  createUser (input:$user) {\\n\\t\\tclientMutationId\\n  }\\n}","variables":{"user":{"email":"'$USEREMAIL'","name":"'$USERNAME'"}}}' --compressed
}


# Update UserGroup 
USERID="fsyzR55DSPuz7UG1lki3eQ"
USERGROUPID="-c7ZpUokQBCKBXnmiaTY0g"
fn_update_user_group(){
curl 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID'' \
-H 'content-type: application/json' \
-H 'x-api-key: '$HARNESS_KEY'' \
--data-binary $'{"query":"mutation($user: UpdateUserGroupInput\u0021){\\n  updateUserGroup(input: $user){\\n    clientMutationId\\n    userGroup{\\n      name\\n      id\\n    }\\n  }\\n}","variables":{"user":{"userIds":"'$USERID'","userGroupId":"'$USERGROUPID'"}}}' --compressed
}


# Add permissions to the group
USERGROUPID="fqn3QnvYSAOjhAMkc7YxIw"
APP_ID="uP22_SFwTHe_-qYwzkm9mA"
fn_add_permissions(){
echo "*****adding permissions to the group****"
curl 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID'' \
 -H 'x-api-key: '$HARNESS_KEY'' \
 -H 'content-type: application/json' \
--data-binary $'{"query":"mutation($userGroup: UpdateUserGroupPermissionsInput\u0021){\\n  updateUserGroupPermissions (input:$userGroup) {\\n      permissions {\\n        accountPermissions{\\n          accountPermissionTypes\\n        }\\n        appPermissions {\\n          permissionType\\n          applications {\\n            filterType\\n            appIds\\n          }\\n          applications{\\n          filterType\\n            appIds\\n          }\\n        }\\n      }\\n  }\\n}\\n\\n","variables":{"userGroup":{"userGroupId":"'$USERGROUPID'","permissions":{"accountPermissions":{"accountPermissionTypes":["READ_USERS_AND_GROUPS","MANAGE_TEMPLATE_LIBRARY","VIEW_AUDITS"]},"appPermissions":[{"permissionType":"ALL","applications":{"appIds":["'$APPID'"]},"actions":["CREATE","READ","UPDATE"]}]}}}}' --compressed
}


# Fetch User By Name
# Returns Name and ID
USERNAME="captainCanary"
fn_fetch_user_by_name(){
curl 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID'' \
-H 'x-api-key: '$HARNESS_KEY'' \
-H 'content-type: application/json' \
--data-binary '{"query":"{\n  userByName(name:\"'$USERNAME'\"){\n    id\n    name\n    email\n  }\n}","variables":null}' --compressed
}


# Fetch UserGroup By Name
# Returns name, ID
USERGROUPNAME="Notification"
fn_fetch_user_group_by_name(){
curl 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID'' \
-H 'x-api-key: '$HARNESS_KEY'' \
-H 'content-type: application/json' \
--data-binary '{"query":"{\n  userGroupByName(name:\"Notification\"){\n    id\n    name\n  }\n}","variables":null}' --compressed
}