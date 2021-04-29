version 1.0

workflow TransferNanoporeAssemblies {

    input {
        Array[File] filtered_fastq
        Array[File] trim_sorted_bam
        Array[File] flagstat_out
        Array[File] samstats_out
        Array[File] covhist_out
        Array[File] cov_out
        Array[File] variants
        Array[File] scaffold_consensus
        Array[File] renamed_consensus
        String out_dir
    }

    call transfer_outputs {
        input:
            filtered_fastq = filtered_fastq,
            trim_sorted_bam = trim_sorted_bam,
            flagstat_out = flagstat_out,
            samstats_out = samstats_out,
            covhist_out = covhist_out,
            cov_out = cov_out,
            variants = variants,
            scaffold_consensus = scaffold_consensus,
            renamed_consensus = renamed_consensus,
            out_dir = out_dir
    }
    
    output {
        String transfer_date = transfer_outputs.transfer_date
    }
}    

task transfer_outputs {
    input {
        Array[File] filtered_fastq
        Array[File] trim_sorted_bam
        Array[File] flagstat_out
        Array[File] samstats_out
        Array[File] covhist_out
        Array[File] cov_out
        Array[File] variants
        Array[File] scaffold_consensus
        Array[File] renamed_consensus
        String out_dir
    }
    
    String outdir = sub(out_dir, "/$", "")

    command <<<
        
        gsutil -m cp ~{sep=' ' filtered_fastq} ~{outdir}/filtered_fastq/
        gsutil -m cp ~{sep=' ' trim_sorted_bam} ~{outdir}/alignments/
        gsutil -m cp ~{sep=' ' flagstat_out} ~{outdir}/bam_stats/
        gsutil -m cp ~{sep=' ' samstats_out} ~{outdir}/bam_stats/
        gsutil -m cp ~{sep=' ' covhist_out} ~{outdir}/bam_stats/
        gsutil -m cp ~{sep=' ' cov_out} ~{outdir}/bam_stats/
        gsutil -m cp ~{sep=' ' scaffold_consensus} ~{outdir}/assemblies/
        gsutil -m cp ~{sep=' ' variants} ~{outdir}/variants/
        gsutil -m cp ~{sep=' ' renamed_consensus} ~{outdir}/assemblies/
        
        transferdate=`date`
        echo $transferdate | tee TRANSFERDATE
    >>>

    output {
        String transfer_date = read_string("TRANSFERDATE")
    }

    runtime {
        docker: "theiagen/utility:1.0"
        memory: "16 GB"
        cpu: 4
        disks: "local-disk 100 SSD"
    }
}
