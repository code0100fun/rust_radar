
## Set environment variables
heroku config:set NODE_ENV=production --account personal --app rustradar-staging

## Add web sockets to heroku
heroku labs:enable websockets --account personal --app rustradar-staging
