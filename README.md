# Plasma DualSense Controller Plasmoid

This is a KDE Plasma widget (Plasmoid) for displaying status information about connected PlayStation DualSense controllers. It provides real-time monitoring for battery level, connection state, and more via a native QML interface.

This project depends on a D-Bus backend to interface with DualSense controllers at the system level.

## Features

- Displays battery level (numeric and graphical)
- Supports multiple controllers simultaneously
- Built using native QML and KDE Plasma components

## Backend Dependency

This frontend is designed to work with the following Python D-Bus backend:

**dualsense-idle-timeout**  
https://github.com/alekoHalkias/dualsense-idle-timeout

Follow the setup instructions in that repository to install and run the D-Bus service. This plasmoid connects to that service to retrieve controller data.

## Installation

### 1. Open terminal and Run the command from the downloaded location

```bash
git clone https://github.com/alekoHalkias/org.kde.dualsenseidle
cd org.kde.dualsenseidle
kpackagetool6 --type Plasma/Applet -i .