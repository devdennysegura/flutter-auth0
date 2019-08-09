# flutter_auth0 Example

A test app for flutter_auth0

## Create a test app in auth0

Create a new test app in auth0 dashboard. An Auth0 app allows different types of 
authentication flows. To test the basic signup and signin using password, you have to
choose app type Regular web application, choose None as Token Endpoint Authentication Method,
 and under Advanced - Grant Types tick off Password as an allowed type.

To test the web login, you also need to configure callback URLs as described in the main README.

## Configure the example app

In example/lib/main.dart, you need to update clientId and domain constants. The already configured id and 
domain belongs to a test app (github.com/gregertw) that you may use (NOTE! You need to use a real email 
address and the user will show up in the auth0 dashboard of this app).