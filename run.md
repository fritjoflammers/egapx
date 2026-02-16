
ml openjdk/21.0.3_9 eth_proxy
mamba activate -p ~/scratch/conda/2026-02-04/egapx

python3 ui/egapx.py ./examples/input_D_farinae_small.yaml -e slurm -o example_out -w ~/scratch/nf/
