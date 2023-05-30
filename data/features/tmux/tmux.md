Increase productivity using terminal. Manage sessions, windows and panes.

`tmux` is loaded every time you load a bash session except if you are already running `tmux`. 

###### Mouse features

Mouse is inactive by default. This means that when right-click you will call the right click of the system, causing it 
to display the usual drop-down menu with copy, paste, etc.

You can use `tm` bash function to write the line that activates the mouse into your `.tmux.conf` if you have your mouse 
inactive and want to set it active; or if your mouse is already active and want to deactivate it you must kill the 
`tmux` server with function `tks` and launch another one again calling `bash` or `tmux`.

With an active mouse you can:
- Click on the different panes to select the active pane.
- Double-click on status bar to create a new window.
- Right-click on an element to see its drop-down menu, which will show different options depending on the clicked 
  element.
- Click-drag in the status bars of each window to move them.
- Scroll inside of tmux panes using the middle button.


###### Bindings & functions

* prefix & `r`: Reload configuration from `.tmux.conf`.
* `tks`: Kill tmux server. 
* `tm`: Changes the mouse default stay from `on` to nothing (default) by writing or removing from `.tmux.conf`
* ctrl + `+` : Increases Terminal and text size.
* ctrl + `-` : Decreases Terminal and text size.
