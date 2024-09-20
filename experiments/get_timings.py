"""
This script parses CPU and GPU experiment results and prints the timings.
"""

import os
import pathlib
from collections import deque


def tail(filename: str, n:int=10):
    """Return the last n lines of a file."""
    with open(filename) as f:
        return deque(f, n)


def parse_outfile(outfile_path: str):
    """Get the 5th last line of the slurm outfile and parse the timings."""
    time_line = tail(outfile_path, 5)[0]
    time_line = time_line.strip().split()
    wallclock, cpu, vector = time_line[3], time_line[6], time_line[9]
    return wallclock, cpu, vector


def print_timings():
    """Filter experiments on CPU and GPU, report timings per setup."""
    # Get the location of this file and use it as a starting point.
    exp_path = pathlib.Path(__file__).parent.resolve()
    print(f"Finding results in {exp_path}..")

    # Go over systems, version, and setup. 
    for root, _, files in os.walk(exp_path):
        # Make sure the results are from CPU and GPU experiments.
        if f"{os.sep}CPU{os.sep}" not in root and \
            f"{os.sep}GPU{os.sep}" not in root:
                continue
        
        # Find the SLURM out files.
        for f in files:
            if f.startswith("slurm-") and f.endswith(".out"):
                # Dissect system, version, and setup from root string.
                system, version, setup = root.split(os.sep)[-3:]
                
                # Get timings from outfile.
                wallclock, cpu, vector = parse_outfile(os.path.join(root, f))
                
                # Report results.
                print(f"{system}\t{version}\t{setup}")
                print("WALLCLOCK\tCPU\tVECTOR")
                print(f"{wallclock}\t\t{cpu}\t{vector}\n")


if __name__ == "__main__":
    print_timings()
