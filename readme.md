# godot-neovim

A Godot pulgin providing Vim motions to the Godot script edtior, using Neovim as a backend.

## Dev notes

You will see some classes have just the name ```T```
In this project the ```T``` class is the main class in the file.
For instance ```class T``` in the file ```nvim_connection.gd``` used to be
```class NvimConnection``` but was renamed to ```T``` when refactoring into
multiple files. 

This seemed to be the simplest solution, for having multiple files in the project
without subplugins, autoloads polluting the global namspace.
