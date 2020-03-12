# Variables
APP_NAME=""
APP_DESCRIPTION="Created by Automation Script"

fn_create_app(){
echo "Creating an Application"
curl 'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID'' \
-H 'authority: app.harness.io' \
-H 'x-api-key: '$HARNESS_KEY'' \
-H 'content-type: application/json' \
-H 'accept: */*' \
-H 'origin: https://app.harness.io' \
-H 'sec-fetch-site: same-origin' \
-H 'sec-fetch-mode: cors' \
-H 'referer: https://app.harness.io/'\
-H 'accept-encoding: gzip, deflate, br' \
-H 'accept-language: en-US,en;q=0.9' \
--data-binary $'{"query":"mutation createapp($app: CreateApplicationInput\u0021) {\\n  createApplication(input: $app) {\\n    clientMutationId\\n    application {\\n      name\\n      id\\n    }\\n  }\\n}","variables":{"app":{"clientMutationId":"req9","name":"'$APP_NAME'","description":"'$APP_DESCRIPTION'"}},"operationName":"createapp"}' --compressed
}


#main
APP_NAME=$1

fn_create_app