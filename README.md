# Base Rails

 ## updating Bonsai Elasticsearch:
 1. heroku run rake searchkick:reindex:all

 ## steps to get elasticsearch server running in development:
 1. eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
 2. brew install elasticsearch
 3. elasticsearch

 ## getting webpacker to work
 1. yarn install
 2. yarn install --check-files && bin/setup

 ## actioncable
 1. npm install @rails/actioncable
 2. yarn install --check-files
 3. yarn upgrade
 4. ./bin/webpack-dev-server
 5. 

