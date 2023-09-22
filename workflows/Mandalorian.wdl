version 1.0

task MandalorianTask {
    input {
        File inputBAM
        File inputBAMIndex
        File referenceGenome
        File referenceGenomeIndex
        File? referenceAnnotation
        String datasetName
        Int cpu = 16
        Int numThreads = 32
        Int memoryGB = 128
        Int diskSizeGB = 500
        String docker = "us-central1-docker.pkg.dev/methods-dev-lab/iso-reconstruct-benchmark/mandalorian@sha256:20e2d4d3f4e5e7b26e8a743624366f21d79b351dbcdbc975dc5f8a2e27f80db8"
        File monitoringScript = "gs://ctat_genome_libs/terra_scripts/cromwell_monitoring_script2.sh"
    }

    String outputPrefix = if defined(referenceAnnotation) then "Mandalorian_out_~{datasetName}" else "Mandalorian_denovo_out_~{datasetName}"

    command <<<
        bash ~{monitoringScript} > monitoring.log &

        /usr/local/src/Mandalorion/Mando.py \
        -G ~{referenceGenome} \
        -g ~{referenceAnnotation} \
        -f ~{inputBAM} \
        -p ~{outputPrefix} &
        
        mv "~{outputPrefix}/Isoforms.filtered.clean.gtf" "~{outputPrefix}/~{datasetName}.Isoforms.filtered.clean.gtf"
    >>>

    output {
        File MandalorianGTF = "~{outputPrefix}/~{datasetName}.Isoforms.filtered.clean.gtf"
        File monitoringLog = "monitoring.log"
    }

    runtime {
        cpu: cpu
        memory: "~{memoryGB} GiB"
        disks: "local-disk ~{diskSizeGB} HDD"
        docker: docker
    }
}

workflow Mandalorian {
    input {
        File inputBAM
        File inputBAMIndex
        File referenceGenome
        File referenceGenomeIndex
        File? referenceAnnotation
        String datasetName
    }

    call MandalorianTask {
        input:
            inputBAM = inputBAM,
            inputBAMIndex = inputBAMIndex,
            referenceGenome = referenceGenome,
            referenceGenomeIndex = referenceGenomeIndex,
            referenceAnnotation = referenceAnnotation,
            datasetName = datasetName,
    }

    output {
        File MandalorianGTF = MandalorianTask.MandalorianGTF
        File monitoringLog = MandalorianTask.monitoringLog
    }
}
