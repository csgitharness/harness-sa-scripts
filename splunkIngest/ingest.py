###############################################
# TITLE: Harness - Splunk Ingest
# CREATED BY: Bryan Feuling
# DATE: 3/30/2020
# DESCRIPTION: This script gives the user the
# the ability to ingest audit information from
# the Harness API into their Splunk Ingest
# Endpoint
###############################################
import requests, json
###############################################
# HARNESS INFORMATION
###############################################
print('What is your Harness Account ID? Example: harnessUrl = https://app.harness.io/#/account/987238413kjdhbvkwer, Account ID = 987238413kjdhbvkwer')
harnessAcct = input()
harnessUrl = ('https://app.harness.io/gateway/api/graphql?harnessAcct=%s' % harnessAcct)
print('What is your Harness API Key?')
harnessKey = input()
###############################################
# SPLUNK INFORMATION
###############################################
print('What is your Splunk Tenant ID?')
splunkAcct = input()
splunkUrl = ('https://api.scp.splunk.com/%s/ingest/v1beta2/metrics' % splunkAcct)
print('What is your Splunk Access Token?')
splunkKey = input()
harnessPayload = "{\"query\":\"{\\n  audits(limit: 100, offset: 0) {\\n    nodes {\\n      changes {\\n        appName\\n        operationType\\n        parentResourceName\\n      }\\n      triggeredAt\\n    }\\n  }\\n}\",\"variables\":{}}"
harnessHeaders = {
  'Content-Type': 'application/json',
  'x-api-key': harnessKey,
  'Accept': '*/*',
  'Cache-Control': 'no-cache',
  'Host': 'app.harness.io'
}
splunkHeaders = {
  'Content-Type': 'application/json',
  'Authorization': ('Bearer %s' % splunkKey)
}
harnessResponse = requests.request("POST", harnessUrl, headers = harnessHeaders, data = harnessPayload)
for r in harnessResponse.json()['data']['audits']['nodes']:
  appName = r['changes'][0]['appName']
  opType = r['changes'][0]['operationType']
  resource = r['changes'][0]['parentResourceName']
  timestamp = r['triggeredAt']
  splunkPayload = ("[{\"body\": [{\"name\":\"Application\",\"value\":%s,\"unit\":\"string\"},{\"name\":\"Action\",\"value\":%s,\"unit\":\"string\"},{\"name\":\"Resource\",\"value\":%s,\"unit\":\"string\"}],\"sourcetype\":\"harness\",\"timestamp\":%f}]" % appName, opType, resource, timestamp)
  splunkResponse = requests.request("POST", splunkUrl, headers = splunkHeaders, data = splunkPayload)