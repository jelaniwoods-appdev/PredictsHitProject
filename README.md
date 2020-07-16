# Base Rails

## Standard Workflow

 1. Set up the project: `bin/setup`
 1. Start the web server by running `bin/server`.
 1. nvm install node
 1. As you work, remember to navigate to `/git`

 ## updating Bonsai Elasticsearch:
 1. heroku run rake searchkick:reindex:all

 ## steps to get elasticsearch server running in development:
 1. eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
 2. brew install elasticsearch
 3. elasticsearch