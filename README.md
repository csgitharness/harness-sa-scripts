# harness-sa-scripts
Solution Architecture Team's scripts that were created for customers



## API - Wrapper

API Wrapper contains some light weight scripts to create resources in Harnesss via the GraphQL API. This is useful when trying to create some automation around the onboarding process of Harness.


This includes
- Create an Application
- Create and Update User Groups
- Create and Update Users
- Link SAML Groups to User Groups 


## Application Automation

This was created for our customer Nationwide and is deeply coupled for their use case. We can have other customers follow a similar process, its up to the team and the SA on the account to make that call. 

Nationwide is doing the onboarding almost entirely through Git Sync, they are cloning a golden template application and editting the YAML files in the cloned application. They are creating cloud providers, scoping it to user groups. They provide onboarding teams a template workflow that they can deploy right out of setup. 


##  CurlCommand

These are curl commands against the Harness API. We can turn these into CLI inputs based of the Rama's input. These curl commands can be shared with customers, they are stripped down and pre-built queries. 

## Pipeline Generator

A project for OCC where they want to dynamically create pipelines by selecting services they want to deploy based on user inputs in the script. 




