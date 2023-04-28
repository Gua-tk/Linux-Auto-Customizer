
### Dependencies for displaying the customizer logo in neofetch w3m-img

- w3m-img
- imagemagick
- A terminal emulator that supports \033[14t or xdotool or xwininfo + xprop or xwininfo + xdpyinfo for getting the 
terminal window size in pixels so that we can size the image correctly.

I noticed that if the variable DISPLAY is null, neofetch cannot display the image. I already raised PR.


