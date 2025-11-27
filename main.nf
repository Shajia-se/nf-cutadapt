#!/usr/bin/env nextflow
nextflow.enable.dsl=2

def cutadapt_output = params.cutadapt_output ?: "cutadapt_output"


process cutadapt {
  stageInMode 'symlink'
  stageOutMode 'move'
  tag "${f}"

  input:
    path f

  publishDir "${params.project_folder}/${cutadapt_output}", mode: 'copy'

  output:
    path "${f.simpleName}.trimmed.fastq.gz"
    path "${f.simpleName}.cutadapt.log"

  script:
  """
  cutadapt \
      -j ${task.cpus} \
      --length ${params.sgRNA_size} \
      -g ${params.upstreamseq} \
      -o ${f.simpleName}.trimmed.fastq.gz \
      ${f} > ${f.simpleName}.cutadapt.log
  """
}


workflow {

  def data = Channel.fromPath("${params.fastqc_raw_data}/*fastq.gz")

  data = data.filter { f ->
      def trimmed = f.getName().replace(".fastq.gz", ".trimmed.fastq.gz")
      def outFile = new File("${params.project_folder}/${cutadapt_output}/${trimmed}")
      ! outFile.exists()
  }
  cutadapt(data)
}
