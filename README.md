# Vixen's Starbound Universe and Being Manipulator

***A Starbound Save manipulator for Windows.***

 - Dynamic number of dataset slots, name and rename them!
 - Dynamic number of backups per slot, oldest pruned after a modifiable number of backup per slot, + manual named backups that are immune to the pruning!
 - Wizard to create the first dataset ever from your current Starbound saves the first time you run the script and make it active in the script
 
 ## Menus
 
 - Active Slot - Which dataset is actually active/used by Starbound
  
 - 1 - Backup  : Create a new backup on active dataset slot
    - m1       - Manual modifier, allows to create a named backup that can't get pruned automatically
 - 2 - Restore : Lets you list your backups for your Active slot, and restore from one.
    - d#       - in the Restore menu, d + backup slot lets you delete the chosen backup after confirmation
 - 3 - Switch  : Lets you switch your Active Slot, making an automatic backup for it before restoring an other slot as your Active Slot
    - f option  - By adding " f " in front of the number of the slot you want to switch to, you can avoid generating a new backup on your current active dataset before switching.  
      - If your current dataset doesn't have any backup yet, this option will be overwritten to generate a backup anyways.
 - 4 - Manage  : Will let you overview all yours Slots
    - empty     -   In an empty slot, you'll be able to create a new dataset or import from and other slot.
      - Create a new data set in an empty slot that contains no save data. Let's you start fresh!
      - Import a peculiar backup or whole dataset from an already existing dataset in an other slot into an empty slot to make a copy.
    - non-empty -   In a non-empty slot, you'll be able to empty it (delete) or change its label with the rename option.
      - Rename an existing dataset. Simple!
      - Delete a dataset (doesn't work on your current active dataset), clearing all the back-ups in that slot and wiping the name, ready to be reused!
 
 ## The point

Just because it's a annoying to move around and keep track of multiple save folders for different modpacks/users, and also that some mods can sometimes just decide to Thanos-snap your whole storage folder, so bye-bye your characters and your whole universe, start again back from 0.

The point of that script? That what I just said above isn't a thing anymore. So far it isn't.



 ### Why batch

I wanted to share it to some people who aren't big on computer stuff.

I didn't wanted to ask of people either to install python, nor to deal with powershell/vbs which can be obfuscated, nor ask of people to download an unsigned binary that I would have compiled in C# or netframework, or even more hassle and not much more reassuring for them, have them compile from source.

At least with batch, it hides nothing, has no third party requirement, and works out of the box.



#### Credits
 - A vulpine
 - A friend who helped with dynamic variable trickery and solving the multi-digit comparison issue. They prefer to stay anonymous for the time being.
