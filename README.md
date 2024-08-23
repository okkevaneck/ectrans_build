# ecTrans dwarf

The ecTrans dwarf requires ecBuild and FIAT to be installed before ecTrans
itself can be installed. This installation script installs the c8c5c61 commit
of ecTrans as it is a stable version for AMD and NVIDIA GPUs.

This repositry has two major scripts: `install.sh` and `clean.sh`. Both will
be explained in their own subsection below. Afterwards a section will discuss
how to run the model.

## Installation

Installation of the ecTrans dwarf is quite easy. 
You can download, build, and install ecbuild, fiat, and ectrans itself by
running:

```bash
./install.sh
```

If you only want to download the sources, you can run:

```bash
./install.sh d
```

which creates a `src/sources` folder containing a directory for each
application. Afterwards you can build and install all applications through the
`bi` key:

```bash
./install.sh bi
```

It is also possible to only build and install a specific application. 
For example, to only build and install ecbuild, you first download the sources, 
and then execute:

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

After building or installing an application, there will be a log file in each
sub-directory of `src` with the name of the application. You can use
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

## Execution

After you have succesfully build and installed all three components, you can
now run the binaries located at `src/install/ectrans/bin`. The run directory 
, located in the top-level `ectrans_dwarf` directory, contains pre-made scripts
for executing the model on the specified machine through SLURM jobs. If you 
want to run the GPU version on LUMI-G, you can `sbatch` the `sbatch_lumi-g.sh`
script, which runs the GPU model by default with the following variables:

```console
BINARY=ectrans-benchmark-gpu-dp
RESDIR=sbatch
NFLD=1
NLEV=10
NITER=10
TRUNCATION=79
```

Every one of these variables can be changed through the environment variables,
which all have exactly the same names as above. You can simply specify the name
of any binary in the folder listed above as `BINARY` to change the model.
Futhermore, you can also change the name of your results folder by changing the
`RESDIR` environment variable.
