#!/bin/sh
man -k . | awk '{print $1}' | rofi -dmenu | xargs -r man -Tpdf | zathura -