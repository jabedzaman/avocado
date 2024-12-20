#!/bin/bash

if [ -z "$(pgrep pasystray)" ] ; then
    pasystray &
fi
