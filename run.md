# setup conda env

# tool to create a conda dir on scratch if current one is older than 2 weeks
python ~/conda-scratch-dir.py 
mamba create  -p ~/scratch/conda/$CONDA_SCRATCH_DIR/egapx python=3.11 pyyaml


ml openjdk/21.0.3_9 eth_proxy
mamba activate -p ~/scratch/conda/2026-02-04/egapx

python3 ui/egapx.py ./M_milvus/input_Milvus_milvus.yaml -e slurm -o M_milvus/output/ -w <YOUR SCRATCH>/nf/


# resume previous runs
bash M_milvus/output/nextflow/resume.sh
python3 ui/egapx.py ./M_milvus/input_Milvus_milvus.yaml -e slurm -o M_milvus/output/ -w <YOUR SCRATCH>/nf/ -resume 

