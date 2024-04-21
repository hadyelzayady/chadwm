#!/bin/sh

xrdb merge ~/.Xresources

while type chadwm >/dev/null; do chadwm && continue || break; done
