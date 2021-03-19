version 1.0

workflow TransferNanoporeAssemblies {

    input {
        Array[File] barcode_summary
        Array[File] filtered_fastq
        Array[File] sorted_bam
        Array[File] flagstat_out
        Array[File] samstats_out
        Array[File] covhist_out
        Array[File] cov_out
        Array[File] variants
        Array[File] consensus
        Array[File] renamed_consensus
        String out_dir
    }

    call transfer_outputs {
        input:
            barcode_summary = barcode_summary,
            filtered_fastq = filtered_fastq,
            sorted_bam = sorted_bam,
            flagstat_out = flagstat_out,
            samstats_out = samstats_out,
            covhist_out = covhist_out,
            cov_out = cov_out,
            variants = variants,
            consensus = consensus,
            renamed_consensus = renamed_consensus,
            out_dir = out_dir
    }
    
    output {
        String transfer_date = transfer_outputs.transfer_date
    }
}    

task transfer_outputs {
    input {
        Array[File] barcode_summary
        Array[File] filtered_fastq
        Array[File] sorted_bam
        Array[File] flagstat_out
        Array[File] samstats_out
        Array[File] covhist_out
        Array[File] cov_out
        Array[File] variants
        Array[File] consensus
        Array[File] renamed_consensus
        String out_dir
    }
    
    String outdir = sub(out_dir, "/$", "")

    command <<<
        
        gsutil -m cp ~{sep=' ' barcode_summary} ~{outdir}/demux/
        gsutil -m cp ~{sep=' ' filtered_fastq} ~{outdir}/filtered_fastq/
        gsutil -m cp ~{sep=' ' sorted_bam} ~{outdir}/alignments/
        gsutil -m cp ~{sep=' ' flagstat_out} ~{outdir}/bam_stats/
        gsutil -m cp ~{sep=' ' samstats_out} ~{outdir}/bam_stats/
        gsutil -m cp ~{sep=' ' covhist_out} ~{outdir}/bam_stats/
        gsutil -m cp ~{sep=' ' cov_out} ~{outdir}/bam_stats/
        gsutil -m cp ~{sep=' ' consensus} ~{outdir}/assemblies/
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
        memory: "4 GB"
        cpu: 1
        disks: "local-disk 10 SSD"
    }
}