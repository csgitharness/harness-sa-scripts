#!/bin/bash


## Variables ##

#ssoProviderId
SSO_PROVIDER_ID="" 
SAML_GROUP_NAME=""
USER_GROUP_ID=""
USER_GROUP_NAME=""

# Link Function to wire up the User Group to SAML Provider
fn_link(){
    curl 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID''\
     -H 'authority: app.harness.io'  \
     -H 'x-api-key: '$HARNESS_KEY'' \
     -H 'content-type: application/json' \
     -H 'accept: */*' \
     -H 'origin: https://app.harness.io' \
     -H 'sec-fetch-site: same-origin' \
     -H 'sec-fetch-mode: cors' \
     -H 'referer: https://app.harness.io/'\
     -H 'accept-encoding: gzip, deflate, br' \
     -H 'accept-language: en-US,en;q=0.9' \
    --data-binary $'{"query":"mutation updateUserGroup($userGroup:UpdateUserGroupInput\u0021) {\\n\\tupdateUserGroup(input: $userGroup) {\\n  \\tuserGroup {\\n      id\\n      name\\n      description\\n      isSSOLinked\\n      importedByScim\\n\\t\\t\\tusers(limit: 190, offset: 0){\\n        pageInfo {\\n          total\\n        }\\n        nodes {\\n          name\\n          email\\n        }\\n      }\\n    }  \\n  }  \\n}\\n","variables":{"userGroup":{"userGroupId":"'$USER_GROUP_ID'","ssoSetting":{"samlSettings":{"ssoProviderId":"'$SSO_PROVIDER_ID'","groupName":"'$SAML_GROUP_NAME'"}}}},"operationName":"updateUserGroup"}' --compressed
    echo "SUCCESS"
}

# Function Get an SSO Provider ID
fn_get_sso_providers() {
    curl -s 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID'' \
    -H 'authority: app.harness.io' \
    -H 'x-api-key: '$HARNESS_KEY'' \
    -H 'content-type: application/json' \
    -H 'accept: */*' -H 'origin: https://app.harness.io' \
    -H 'sec-fetch-site: same-origin' \
    -H 'sec-fetch-mode: cors' \
    -H 'referer: https://app.harness.io/'\
    -H 'accept-encoding: gzip, deflate, br' \
    -H 'accept-language: en-US,en;q=0.9' \
    --data-binary '{"query":"query {\n  ssoProviders(limit:3){\n    nodes{\n      name\n      id\n    }\n  }\n}","variables":null}' --compressed > ssoProviderId.json
    
    jq '.data.ssoProviders.nodes[] | select(.name=="'$SAML_GROUP_NAME'")' ssoProviderId.json > sso.json
    SSO_PROVIDER_ID=$(cat sso.json | jq -r '.id')
    echo $SSO_PROVIDER_ID
    rm -rf sso.json
    rm -rf ssoProviderId.json
}

# Function Get a list of User Groups
fn_get_user_groups(){
echo "Fetch existing user groups"

curl -s 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID'' \
-H 'authority: app.harness.io'  \
-H 'x-api-key: '$HARNESS_KEY'' \
-H 'content-type: application/json' \
-H 'accept: */*' \
-H 'origin: https://app.harness.io' \
-H 'sec-fetch-site: same-origin' \
 -H 'sec-fetch-mode: cors' \
 -H 'referer: https://app.harness.io/' \
 -H 'accept-encoding: gzip, deflate, br' \
 -H 'accept-language: en-US,en;q=0.9' \
 --data-binary '{"query":"{\n  userGroups(limit:20, offset:0){\n    nodes{\n      id\n      name\n    }\n  }\n}","variables":null}' --compressed > listusergroup.json


jq '.data.userGroups.nodes[] | select(.name=="'$USER_GROUP_NAME'")' listusergroup.json > group.json
USER_GROUP_ID=$(cat group.json | jq -r '.id') 
echo $USER_GROUP_ID
}

### MAIN ### 

# ./saml.sh OktaAdmin DevOps

SAML_GROUP_NAME=$1
USER_GROUP_NAME=$2 

if [ $# -lt 2 ]; then
echo "ERROR: Not enough arguments"
echo "<GROUP_NAME><SAML_GROUP_NAME>"
exit 0
fi 

fn_get_user_groups

fn_get_sso_providers

fn_link


