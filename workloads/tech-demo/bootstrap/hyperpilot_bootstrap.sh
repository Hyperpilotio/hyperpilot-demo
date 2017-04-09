#!/usr/bin/env bash

# Download the command agent and run it as a daemon
COMMAND_AGENT_URL=http://hyperpilot-snap-collectors.s3.amazonaws.com/command_agent.py

curl -s $COMMAND_AGENT_URL -o /home/ubuntu/command_agent.py

COMMAND_AGENT_SERVICE=http://hyperpilot-snap-collectors.s3.amazonaws.com/command_agent.service

curl -s $COMMAND_AGENT_SERVICE -o command_agent.service
sudo chmod 664 command_agent.service
sudo cp command_agent.service /etc/systemd/system/multi-user.target.wants/

sudo systemctl daemon-reload
sudo systemctl start command_agent.service
