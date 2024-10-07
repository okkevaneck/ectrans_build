# ecTrans mini application
The ecTrans mini application requires ecBuild and FIAT to be installed before 
ecTrans itself can be installed. This installation script installs the c8c5c61 
commit of ecTrans as it is a stable version for AMD and NVIDIA GPUs.

This repositry has two major scripts: `install.sh` and `clean.sh`. Both will
be explained in their own subsection below. Afterwards a section will discuss
how to run the model.

## Installation
Installation of the ecTrans mini application is quite easy. 
You can download, build, and install ecbuild, fiat, and ectrans itself by
running the `install.sh` script. The script takes 1 mandatory argument, and `n`
optional ones. The first argument should be the name of the machine you are 
working on. Supported options are: `[lumi|leonardo|mn5|karolina]`. The other
optional argument specify what action to perform, which is explained in the 
paragraphs below.

To download and install all 3 applications, simply run:

```bash
./install.sh <machine>
```

If you only want to download the sources, you can run:

```bash
./install.sh <machine> d
```

which creates a `src/sources` folder containing a directory for each
application. Afterwards you can build and install all applications through the
`bi` key:

```bash
./install.sh <machine> bi
```

It is also possible to only build and install a specific application. 
For example, to only build and install ecbuild, you first download the sources, 
and then execute:

```bash
./install.sh <machine> bi:ecbuild
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

Make sure to run the build and install instructions from an interactive compute
node on a partition with GPUs available! To allocate and cd into an interactive 
node, you can run the following code, where you replace the account, partition, 
and qos according to the system at use:

```bash
salloc \
    --account=<account> \
    --partition=<partition> \
    --qos=<qos> \
    --exclusive \
    --job-name=acc_interactive \
    --time=00:30:00 \
    --ntasks=1 \
    --nodes=1 \
    srun --pty bash -i
```

### Installation instructions for LUMI
Since the compute nodes have internet access, you can simply run 
`./install.sh lumi` to download and install all applications on a compute node.

### Installation instructions for Leonardo
The compute nodes are locked of from the internet, and thus you need to download
the sources first on a login node through `./install.sh leonardo d`. Then 
install the applications on a compute node with `./install.sh leonardo bi`.

### Installation instructions for MareNostrum 5
The compute nodes are locked of from the internet, and thus you need to download
the sources first on a login node through `./install.sh mn5 d`. Then install the
applications on a compute node with `./install.sh mn5 bi`.

### Installation instructions for Karolina
Since the compute nodes have internet access, you can simply run 
`./install.sh karolina` to download and install all applications on a compute 
node.


## Cleaning
Cleaning the project is quite easy through the `clean.sh` script. By default,
only the `sources` and `build` directories are removed as you might want to save
the binaries of various versions. So cleaning of the `sources` and `build` 
directories can be done through:

```bash
./clean.sh
```

It is also possible to remove all three directories (including `install`), by
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

## Performing experiments
After you have succesfully build and installed all three components, you can
now run the binaries located at `src/install/ectrans/bin`. The `jobs` directory 
, located in the top-level `ectrans_dwarf` directory, contains pre-made sbatch
scripts for executing the model on the specified machine through SLURM jobs.
Each of the scripts' name ends with the targetted machine name, e.g. 
`sbatch_lumi-g.sh` is for running on the LUMI-G partition. The script runs the 
GPU model by default with the following default variables:

```bash
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

These job scripts are used by the experiments located in the `experiments` 
folder. This folder contains pre-defined scripts for performing scaling 
experiments using the CPU or GPU models on the different supported machines. 
There are subdirectories for each machine, which contain a `run_cpu.sh` and a 
`run_gpu.sh` script for submitting multiple jobs at the different scales. Each 
of these scripts have the following list of variables that can be altered 
according to your needs:

```bash
# Define experiment details.
BIN=ectrans-benchmark-gpu-dp
NITER=3
TRUNCATION=1599
OUTDIR_PREFIX="$EXPDIR/GPU"
TIMELIMIT="00:20:00"
NODES="4 8 16 32"
```

The ones that we advise to alter are `NITER` for the number of iterations, and
`NODES` to specify how many nodes each job must have. The `TRUNCATION` variable
defines the size of the arrays, the higher the number, the higher the 
resolution, and thus the bigger the array. We took 1599 as a value, because it 
is at the boundry of out-of-memory errors for some machines. However, feel free 
to experiment. You might need to change the job time limit accordingly via the 
`TIMELIMIT` variable.

### Reading the ouput
The model's output consists of a `stderr` and `stdout` file per rank, as well as 
a combined stdout in the slurm outfile. Only rank 0 writes results to stdout,
and thus you can use the general slurm outfile. The outfile will start with some
model definitions, followed by runtime statistics. At the end, there will be an
overview of timing statistics in which each major routine is mentioned. At the
bottom you will find the total measured imbalance as well as wallclock time.

#### LUMI-G exception
Warning: currently the output is not aggregated in the slurm outfile on LUMI-G,
and thus you will need to navigate to the out file of rank 0.


## Score-P integration Karolina
There is Score-P integration on the Karolina supercomputer for who's interested.
You simply need to `export SCOREP_OPENACC_ENABLE=yes` before installation in 
order to activate the tracing. This is done for you in the experiment 
`experiments/karolina/run_scorep_gpu.sh` as well.
