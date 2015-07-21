#!/usr/bin/env bash

/usr/bin/env $(which mailcatcher) --ip=0.0.0.0 -f > /dev/null 2>&1 &
