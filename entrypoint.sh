#!/bin/bash
set -e

# Start X virtual framebuffer on display :0 with a screen of 1024x768 and 16-bit color
Xvfb :0 -screen 0 1920x1080x16 &
sleep 2

# Start x11vnc to share display :0 without a password and in shared mode
x11vnc -display :0 -nopw -forever -shared &
sleep 2

# Start websockify to serve noVNC on port 6080, connecting to the VNC server on default port 5900
websockify --web /usr/share/novnc/ 6080 localhost:5900 &
sleep 2

# Ensure that the DISPLAY environment variable is set for the GUI application
export DISPLAY=:0

echo "Access the PDI client via web browser at http://<your-domain-or-ip>:6080/vnc.html"

echo "==== Content of carte-config.xml ===="
cat $PDI_HOME/carte-config.xml
echo "======================================="
exec sh -c "$PDI_HOME/spoon.sh"
#pwd cluster:cluster
#exec sh -c "$PDI_HOME/carte.sh 0.0.0.0 8080"
# $PDI_HOME/carte-config.xml"
