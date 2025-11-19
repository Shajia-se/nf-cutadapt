#!/usr/bin/env nextflow
nextflow.enable.dsl=2

def cutadapt_output = params.cutadapt_output ?: "cutadapt_output"


process cutadapt {
  stageInMode 'symlink'
  stageOutMode 'move'
  tag "${f}"

  input:
    path f
    val outdir

  publishDir "${params.project_folder}/${cutadapt_output}", mode: 'copy'

  output:
    path "${f.simpleName}.trimmed.fastq.gz"
    path "${f.simpleName}.cutadapt.log"

  script:
  """
  mkdir -p ${params.project_folder}/${outdir}

  cutadapt \
      -j ${task.cpus} \
      --length ${params.sgRNA_size} \
      -g ${params.upstreamseq} \
      -o ${params.project_folder}/${outdir}/${f.simpleName}.trimmed.fastq.gz \
      ${f} > ${params.project_folder}/${outdir}/${f.simpleName}.cutadapt.log
  """
}


workflow {

  def outdir = params.cutadapt_output ?: "cutadapt_output"

  def data = Channel.fromPath("${params.cutadapt_raw_data}/*fastq.gz")

  data = data.filter { f ->
      def trimmed = f.getName().replace(".fastq.gz", ".trimmed.fastq.gz")
      ! file("${params.project_folder}/${outdir}/${trimmed}").exists()
  }

  cutadapt(data, outdir)
}
