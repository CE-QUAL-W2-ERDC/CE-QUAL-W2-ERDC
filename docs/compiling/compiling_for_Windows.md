# Compiling CE-QUAL-W2 for Windows

1. Install MinGW or git bash
2. In the MinGW or git bash terminal program, navigate to the directory of the source code to build.
3. Run the following:

```bash
/c/MinGW/bin/mingw32-make.exe -f Makefile.win clean
/c/MinGW/bin/mingw32-make.exe -f Makefile.win distclean
/c/MinGW/bin/mingw32-make.exe -f Makefile.win all
```


