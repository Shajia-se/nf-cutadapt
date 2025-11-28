# nf-cutadapt

A simple, portable cutadapt trimming pipeline using Nextflow.  

📁 Demo data

```bash
mkdir -p ~/nf-cutadapt/test_data
cd ~/nf-cutadapt/test_data

wget https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR155/007/SRR1553607/SRR1553607_1.fastq.gz
wget https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR155/007/SRR1553607/SRR1553607_2.fastq.gz

````

🚀 Run locally (Docker)

```bash
nextflow run main.nf -profile local
```

Requirements:

* Nextflow
* Docker
* cutadapt image, e.g.
  `docker pull mpagegebioinformatics/cutadapt:4.5`
* `configs/local.config` 

🚀 Run on HPC (Slurm + Singularity)

```bash
nextflow run main.nf -profile hpc
```

Requirements:

* Slurm scheduler
* Singularity available
* cutadapt `.sif` at e.g.:
  `$HOME/singularity_images/cutadapt-4.5.sif`
* `configs/slurm.config` 

📤 Output

Trimmed FASTQ files and logs are written to:

```text
${project_folder}/cutadapt_output/
```

by default (or whatever you set via `params.cutadapt_output`).

Each input `SAMPLE.fastq.gz` produces:

* `SAMPLE.trimmed.fastq.gz`
* `SAMPLE.cutadapt.log`

📂 Project structure

```text
main.nf
nextflow.config
configs/
├── local.config      # local + Docker
└── slurm.config      # HPC + Slurm + Singularity
test_data/            # optional demo data
```

✔️ What this pipeline does

* Loads all `*.fastq.gz` 
* Runs `cutadapt` with:

  * fixed output read length: `--length ${params.sgRNA_size}`
  * 5′ adapter / sgRNA upstream sequence: `-g ${params.upstreamseq}`
* Writes:

  * trimmed reads: `${f.simpleName}.trimmed.fastq.gz`
  * cutadapt log: `${f.simpleName}.cutadapt.log`
* Skips samples that already have a trimmed FASTQ in the final output directory
* Works identically on local and HPC environments (only the profile changes)

