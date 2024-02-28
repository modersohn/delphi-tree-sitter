# delphi-tree-sitter

Delphi (and potentially FreePascal) bindings for [tree-sitter][]

[tree-sitter]: https://github.com/tree-sitter/tree-sitter

## Status

At the very beginning, but basic API bindings are already functional. Windows only for now.

## Installation

No design-time packages etc. necessary. The demos with GUI - as of yet - do not require any additional 3rd party packages.

To run the demos, you need to have `tree-sitter.dll` (of the right architecure) somewhere, where the EXE will 
be able to find it (it won't even start without).

For the different parsers (sometimes called grammars) you need a DLL too, e.g. [tree-sitter-c][]

If you don't have a C compiler setup at hand to compile the tree-sitter DLLs, I can highly recommend [zig][]. 

Tree-sitter itself already comes with a `build.zig` file, so running `zig build` in the root directory of tree-sitter will work. 
This might build a .lib instead of a .dll, so in `build.zig` you would need to change `b.addStaticLibrary` into `b.addSharedLibrary`.

Most parsers do not seem to come with zig-support out of the box, but it should be straightforward to create a `build.zig` and use the one from tree-sitter itself as a template.

[tree-sitter-c]: https://github.com/tree-sitter/tree-sitter-c
[zig]: https://ziglang.org
