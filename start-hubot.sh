#!/bin/bash

source sirbearry.env

bin/hubot -a "$HUBOT_ADAPTER" --name "$HUBOT_NAME" --alias "$HUBOT_ALIAS"
