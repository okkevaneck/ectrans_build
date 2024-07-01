# ecTrans dwarf

The ecTrans dwarf requires ecBuild and FIAT to be installed before ecTrans 
itself can be installed. Moreover, a specific version of ecTrans, maintained by 
Okke van Eck, is installed as it contains custom ROCTX markers for profiling.

This repositry has two major scripts: `install.sh` and `clean.sh`. Both will
be explained in their own subsection below.

## Installation

Installation of the ecTrans dwarf is quite easy. By simply running:

```bash
./install.sh
```

You will download, build, and install ecbuild, fiat, and ectrans itself.
If you only want to download the sources, you can run:

```bash
./install.sh d
```

which creates a `src/sources` folder containing a directori for each
application. Afterwards you can build and install only a specific application
through the `bi:` key. For example, to only build and install ecbuild, you
first download the sources, and then execute:

```bash
./install.sh bi:ecbuild
```

This functionality allows you to only rebuild and reinstall specific parts
of the ectrans chain. Whenever you are installing specific applications, please
remember that the following installation order must remain, as they are 
dependend on each other:

1. ecbuild
2. fiat
3. ectrans.

After building or installing an application, there will be a log file in the
`build` or `install` directory with the name of the application. You can use
this to debug any alterations you made to the source code.

## Cleaning

Cleaning the project is quite easy through the `clean.sh` script. By default,
only the build and install directories are removed as you probably do not want
to re-download the sources everytime an installation needs to be redone.
So cleaning of the build and install directories can be done through:

```bash
./clean.sh
```

It is also possible to remove all three directories (including sources), by
specifying `all` as an argument:

```bash
./clean.sh all
```

If you want to only remove a specific directory, you can simply specify 
`sources`, `build`, or `install` as an argument. For example for only removing
the install directory, you would run:

```bash
./clean.sh install
```

Lastly, it is also possible to remove a specific application from one of the
folders by simplying specifying it as a second argument. For example, if only
want to remove the ectrans installation, you can remove it with:

```bash
./clean.sh install ectrans
```
