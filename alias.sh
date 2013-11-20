#!/bin/bash

alias preview='open -a \"/Applications/Google\ Chrome.app/\"'
alias doc='preview README.md'
alias cfp='cf push | awk \"{ print $NF }\" | xargs open -a /Applications/Google\ Chrome.app'
