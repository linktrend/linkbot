#!/bin/bash
#
# Deployment Configuration for LiNKbot Monorepo
# Define deployment targets for each bot
#
# This file should be customized for your infrastructure
# and kept in version control (no secrets here - use SSH keys for auth)
#

# VPS 1 (Lisa's current deployment)
export VPS1_HOST="root@178.128.77.125"
export VPS1_PATH="/root/linkbot"

# VPS 2 (Future deployment - Bob/Kate)
export VPS2_HOST="root@vps2.example.com"
export VPS2_PATH="/root/linkbot"

# Local deployment (Mac Mini - Tom/Kate)
export LOCAL_PATH="$HOME/linkbot"

# Add more targets as needed
# export VPS3_HOST="root@vps3.example.com"
# export VPS3_PATH="/root/linkbot"
