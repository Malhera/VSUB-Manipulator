# VSUB-Manipulator
Vixen's Starbound Universe and Being Manipulator
A Starbound Save manipulator for Windows.

 - Dynamic number of dataset slots
 - Dynamic number of backups per slot, oldest pruned after a modifiable number of backup per slot
 - Wizard to create the first dataset ever from your current Starbound saves the first time you run the script and make it active in the script
 
 ## Menus
 
 - Active Slot - Which dataset is actually active/used by Starbound
  
 - 1 - Backup  : Create a new backup on active dataset slot
  
 - 2 - Restore : Lets you list your backups for your Active slot, and restore from one.
  
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
