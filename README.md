# delphi-tree-sitter

Delphi (and potentially FreePascal) bindings for [tree-sitter][]

[tree-sitter]: https://github.com/tree-sitter/tree-sitter

## Status

Windows only for now and only tested with Delphi.


| API section | Status |
| --- | --- |
| Parser | Basics covered |
| Language | Mostly complete |
| Tree | Mostly complete |
| TreeCursor | Mostly complete |
| Node | Mostly complete |
| Query | Mostly complete |
| QueryCursor | Mostly complete |
| LookAheadIterator | Missing |
| WebAssembly Integration | Missing |

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

## VCL demo project

Instead of demoing a typical use-case, the VCL demo is intended to allow exploring the API and functionality that tree-sitter supplies.
![image](https://github.com/modersohn/delphi-tree-sitter/assets/44807458/27319bec-f3b6-4a67-8329-f67cc7d9d079)

Currently supports a handful of languages out of the box and a treeview of nodes with field name and ID where applicable. Selects the corresponding code part in the memo when a node gets selected.

Inspector-like grid with node properties. Navigation via popup menu of the tree. Lists field names of the language and allows finding child node by field ID.

Now with secondary form listing symbols, fields and version of the language:
![image](https://github.com/modersohn/delphi-tree-sitter/assets/44807458/1243f2fe-ca26-4658-a24e-55ab11c5c153)

New query form, showing info about the query and allowing iterating over matches and listing their captures. Selecting a capture, selects the captured node in the main form and selects the corresponding code section:
![image](https://github.com/modersohn/delphi-tree-sitter/assets/44807458/ac2cba4f-06b2-4a02-8bb4-d02f5adac857)

## Console demo project loading .pas

[Simple console project](ConsoleReadPasFile.dpr) which demonstrates TTSParser.Parse called with an anonymous method for reading the text to parse.
