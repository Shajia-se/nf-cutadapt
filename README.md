# nf-cutadapt

`nf-cutadapt` is a Nextflow DSL2 module for paired-end FASTQ adapter and quality trimming using `cutadapt`.

## What Is cutadapt (Tool Function)

`cutadapt` removes unwanted sequence from reads and can also do quality and length filtering.
In this module, it can be used to:
- trim 5' adapters (`-g` for R1, `-G` for R2)
- trim 3' adapters (`-a` for R1, `-A` for R2)
- trim low-quality ends (`-q`)
- filter by minimum/maximum read length (`-m` / `-M`)

## What This Module Does

1. Reads paired FASTQ files from `cutadapt_raw_data` using `cutadapt_pattern`.
2. Skips samples that already have both trimmed R1 and R2 outputs.
3. Runs one `cutadapt` task per sample pair.
4. Publishes trimmed FASTQ and log files to output directory.

## Input

- Directory: `params.cutadapt_raw_data`
- Pattern: `params.cutadapt_pattern` (default: `*_R{1,2}_001.fastq.gz`)
- Type: paired-end FASTQ (`R1` / `R2`)

Note: `params.fastqc_raw_data` is still accepted for backward compatibility.

## Output

Under `${project_folder}/${cutadapt_output}` (default `./cutadapt_output/`):
- `${sample}_R1.cutadapt.trimmed.fastq.gz`
- `${sample}_R2.cutadapt.trimmed.fastq.gz`
- `${sample}.cutadapt.log`

## Key Parameters

- `cutadapt_raw_data`: input FASTQ folder
- `cutadapt_pattern`: paired FASTQ matching pattern
- `cutadapt_output`: output folder name
- `adapter_5p`: optional R1 5' adapter (`-g`)
- `adapter_3p`: optional R1 3' adapter (`-a`)
- `adapter_5p_r2`: optional R2 5' adapter (`-G`)
- `adapter_3p_r2`: optional R2 3' adapter (`-A`)
- `quality_cutoff`: optional quality trim threshold
- `minimum_length`: optional minimum read length
- `maximum_length`: optional maximum read length
- `cutadapt_extra_args`: optional raw extra CLI args

## Run

Local:
```bash
nextflow run main.nf -profile local
```

HPC:
```bash
nextflow run main.nf -profile hpc
```

Example (paired-end adapter trimming):
```bash
nextflow run main.nf -profile hpc \
  --cutadapt_raw_data /your/fastq_dir \
  --cutadapt_pattern "*_R{1,2}_001.fastq.gz" \
  --adapter_3p AGATCGGAAGAGC \
  --adapter_3p_r2 AGATCGGAAGAGC \
  --quality_cutoff 20 \
  --minimum_length 20
```

Resume:
```bash
nextflow run main.nf -profile hpc -resume
```

## How To Verify Trimming

Check `${sample}.cutadapt.log` for:
- total read pairs processed
- reads with adapters
- quality-trimmed bases
- reads/pairs filtered by length
- reads written to output

## Project Structure

```text
main.nf
nextflow.config
configs/
  local.config
  slurm.config
```
