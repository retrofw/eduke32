This is a dynamically linked port of eduke32 to the Dingoo Linux.
Source included.

Installation:
1) Copy the eduke32 directory somewhere on your filesystem
2) Put the duke3d.grp file from your original Duke Nukem 3D CD in the same directory
3) Run the ./eduke32.dge executable

Note: If you are upgrading from the older version, you might need to delete /local/home/.eduke32 directory first.

Controls:

D-PAD		- movement
A		- shoot
B		- strafe/open
X		- look up/down
Y		- jump
L		- crouch/center view
R + UP/DOWN	- cycle weapons
R + LEFT/RIGHT	- cycle items
START		- use item
SELECT		- game menu

All the controls are custimozable via the menu

Mods:
Eduke32 supports game mods.
For a tutorial on how to launch eduke32 mods in dingux, read:
http://dingoowiki.com/index.php/Eduke32#Mods

Bugs:
* The first eduke32 launch after Dingux reboot might result in a crash. If that happens, simply run the game again.
* When the music is enabled, there is a chance the game will run out of ram and on the map loading screen.
  To prevent this from happening either 1) turn on SWAP 2) disable music from the game menu.

Credits:
I'd like to thank the following people:
* mth                                   	- for writing the 16bpp video mode support for Dingoo
* Ayla                                          - for beta testing
* Eduke32 developers:
 * Plagman					- for help with debugging the eduke32 source
 * TerminX					- for help with getting rid of nedmalloc and implementing D-PAD aiming,
						  D-PAD weapon/item selection and savestate autonaming features
 * other people from #eduke32 on freenode	- for many hints and general help/interest

Changelog:
Release #3 08/11/2010
* updated the game to svn1724
* new D-PAD aiming and D-PAD weapon selection
* new savestate autonaming
* changed the button layout in menu
* other small fixes
Release #2 03/02/2010
* updated the game to svn1594
* bug with item names showing in a wrong order is now fixed
* added icon and .dge extension for better gmenu2x support
Release #1 24/08/2009
* initial release based on svn1489
________________________________________
Compiled by Zear, release #3, 08/11/2010
zeartul(at)gmail(dot)com
