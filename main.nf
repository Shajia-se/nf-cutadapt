#!/usr/bin/env nextflow
nextflow.enable.dsl=2

def cutadapt_output = params.cutadapt_output ?: "cutadapt_output"


process cutadapt {
  stageInMode 'symlink'
  stageOutMode 'move'
  tag "${sample_id}"

  input:
    tuple val(sample_id), path(read1), path(read2)

  publishDir "${params.project_folder}/${cutadapt_output}", mode: 'copy'

  output:
    path "${sample_id}_R1.cutadapt.trimmed.fastq.gz"
    path "${sample_id}_R2.cutadapt.trimmed.fastq.gz"
    path "${sample_id}.cutadapt.log"

  script:
  def opts = []
  if (params.adapter_5p)       opts << "-g ${params.adapter_5p}"
  if (params.adapter_3p)       opts << "-a ${params.adapter_3p}"
  if (params.adapter_5p_r2)    opts << "-G ${params.adapter_5p_r2}"
  if (params.adapter_3p_r2)    opts << "-A ${params.adapter_3p_r2}"
  if (params.quality_cutoff)   opts << "-q ${params.quality_cutoff}"
  if (params.minimum_length)   opts << "-m ${params.minimum_length}"
  if (params.maximum_length)   opts << "-M ${params.maximum_length}"
  if (params.cutadapt_extra_args) opts << "${params.cutadapt_extra_args}"
  def opt_str = opts.join(' ')

  """
  cutadapt \
      -j ${task.cpus} \
      ${opt_str} \
      -o ${sample_id}_R1.cutadapt.trimmed.fastq.gz \
      -p ${sample_id}_R2.cutadapt.trimmed.fastq.gz \
      ${read1} ${read2} > ${sample_id}.cutadapt.log
  """
}


workflow {

  def input_dir = params.cutadapt_raw_data ?: params.fastqc_raw_data
  def pattern = params.cutadapt_pattern ?: "*_R{1,2}_001.fastq.gz"
  def data = Channel.fromFilePairs(
    "${input_dir}/${pattern}",
    flat: true,
    checkIfExists: true
  ).ifEmpty { exit 1, "ERROR: No FASTQ pairs found for pattern: ${input_dir}/${pattern}" }

  data = data.filter { sample_id, read1, read2 ->
      def out1 = new File("${params.project_folder}/${cutadapt_output}/${sample_id}_R1.cutadapt.trimmed.fastq.gz")
      def out2 = new File("${params.project_folder}/${cutadapt_output}/${sample_id}_R2.cutadapt.trimmed.fastq.gz")
      !(out1.exists() && out2.exists())
  }
  cutadapt(data)
}
