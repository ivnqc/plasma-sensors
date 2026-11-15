# plasma-sensors
Choose your stats and display them either in a panel or as a floating element on your desktop. The information is retrieved using [libksysguard](https://github.com/kde/libksysguard), which provides a unified interface for accessing system and hardware statistics, abstracting away many hardware-specific details.

## Panel
![Compact representation](images/compact.png)

## Desktop
![Full representation](images/full.png)

## Installation
 
```bash
git clone https://github.com/ivnqc/plasma-sensors.git
cd plasma-sensors
kpackagetool6 -t Plasma/Applet -i .
```
 
Then add **Plasma Sensors** to a panel or the desktop via **Add or Manage Widgets…**. If nothing seems to happen, you may need to restart the KDE Plasma desktop shell:
 
```bash
systemctl --user restart plasma-plasmashell.service
```

## Usage

Right-click the widget and select **Configure Plasma Sensors...**:

![Usage window](images/click.png)

Customize your widget:

![Settings window](images/settings.png)

## Contributing
 
Issues and pull requests are more than welcome.
 
