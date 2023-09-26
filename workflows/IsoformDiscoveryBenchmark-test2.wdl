version 1.0

import "Mandalorian.wdl" as MandalorianWorkflow
import "IsoQuant.wdl" as IsoQuantWorkflow
import "IsoQuantv2.wdl" as IsoQuantv2Workflow
import "StringTie.wdl" as StringTieWorkflow
import "Bambu.wdl" as BambuWorkflow
import "Flair.wdl" as FlairWorkflow
import "Talon.wdl" as TalonWorkflow
import "IsoSeq.wdl" as IsoSeqWorkflow
import "IsoSeqv2.wdl" as IsoSeqv2Workflow
import "Flames.wdl" as FlamesWorkflow
import "Cupcake.wdl" as CupcakeWorkflow
import "IsoformDiscoveryBenchmarkTasks.wdl" as IsoformDiscoveryBenchmarkTasks

workflow LongReadRNABenchmark {
    input {
        File inputBAM
        File inputBAMIndex
        File referenceGenome
        File referenceGenomeIndex
        File referenceAnnotation
        File expressedGTF
        File expressedKeptGTF
        File excludedGTF
        String datasetName
        String dataType
    }

    call MandalorianWorkflow.Mandalorian as Mandalorian {
        input:
            inputBAM = inputBAM,
            inputBAMIndex = inputBAMIndex,
            referenceGenome = referenceGenome,
            referenceGenomeIndex = referenceGenomeIndex,
            referenceAnnotation = referenceAnnotation,
            datasetName = datasetName,
    }


    call IsoQuantv2Workflow.IsoQuantv2 as IsoQuantv2 {
        input:
            inputBAM = inputBAM,
            inputBAMIndex = inputBAMIndex,
            referenceGenome = referenceGenome,
            referenceGenomeIndex = referenceGenomeIndex,
            referenceAnnotation = referenceAnnotation,
            datasetName = datasetName,
            dataType = dataType
    }

    call IsoQuantv2Workflow.IsoQuantv2 as IsoQuantv2ReferenceFree {
        input:
            inputBAM = inputBAM,
            inputBAMIndex = inputBAMIndex,
            referenceGenome = referenceGenome,
            referenceGenomeIndex = referenceGenomeIndex,
            datasetName = datasetName,
            dataType = dataType
    }


    call IsoQuantWorkflow.IsoQuant as IsoQuant {
        input:
            inputBAM = inputBAM,
            inputBAMIndex = inputBAMIndex,
            referenceGenome = referenceGenome,
            referenceGenomeIndex = referenceGenomeIndex,
            referenceAnnotation = referenceAnnotation,
            datasetName = datasetName,
            dataType = dataType
    }

    call IsoQuantWorkflow.IsoQuant as IsoQuantReferenceFree {
        input:
            inputBAM = inputBAM,
            inputBAMIndex = inputBAMIndex,
            referenceGenome = referenceGenome,
            referenceGenomeIndex = referenceGenomeIndex,
            datasetName = datasetName,
            dataType = dataType
    }

    call StringTieWorkflow.StringTie as StringTie {
        input:
            inputBAM = inputBAM,
            referenceAnnotation = referenceAnnotation,
            datasetName = datasetName
    }

    call StringTieWorkflow.StringTie as StringTieReferenceFree {
        input:
            inputBAM = inputBAM,
            datasetName = datasetName
    }

    call BambuWorkflow.Bambu as Bambu {
        input:
            inputBAM = inputBAM,
            inputBAMIndex = inputBAMIndex,
            referenceGenome = referenceGenome,
            referenceGenomeIndex = referenceGenomeIndex,
            referenceAnnotation = referenceAnnotation,
            datasetName = datasetName,
            dataType = dataType
    }

    call FlairWorkflow.Flair as Flair {
        input:
            inputBAM = inputBAM,
            inputBAMIndex = inputBAMIndex,
            referenceGenome = referenceGenome,
            referenceGenomeIndex = referenceGenomeIndex,
            referenceAnnotation = referenceAnnotation,
            datasetName = datasetName
    }

    call TalonWorkflow.Talon as Talon {
        input:
            inputBAM = inputBAM,
            inputBAMIndex = inputBAMIndex,
            referenceGenome = referenceGenome,
            referenceGenomeIndex = referenceGenomeIndex,
            referenceAnnotation = referenceAnnotation,
            datasetName = datasetName,
            dataType = dataType
    }


    call IsoSeqv2Workflow.IsoSeqv2 as IsoSeqv2 {
        input:
            inputBAM = inputBAM,
            inputBAMIndex = inputBAMIndex,
            referenceGenome = referenceGenome,
            referenceGenomeIndex = referenceGenomeIndex,
            datasetName = datasetName
    }

        call IsoSeqv2Workflow.IsoSeqv2 as IsoSeqv2 {
        input:
            inputBAM = inputBAM,
            inputBAMIndex = inputBAMIndex,
            referenceGenome = referenceGenome,
            referenceGenomeIndex = referenceGenomeIndex,
            datasetName = datasetName
    }


    call FlamesWorkflow.Flames as Flames {
        input:
            inputBAM = inputBAM,
            inputBAMIndex = inputBAMIndex,
            referenceGenome = referenceGenome,
            referenceGenomeIndex = referenceGenomeIndex,
            referenceAnnotation = referenceAnnotation,
            datasetName = datasetName
    }

    call CupcakeWorkflow.Cupcake as Cupcake {
        input:
            inputBAM = inputBAM,
            inputBAMIndex = inputBAMIndex,
            datasetName = datasetName
    }

    # Note: Make sure that your toolNames arrays match the order of your gtfList arrays.
    # If they don't match, you may not get an error but you will get incorrect results.
    Array[File] gtfListReduced = [Mandalorian.MandalorianGTF, IsoQuant.isoQuantGTF, IsoQuantv2.isoQuantv2GTF, StringTie.stringTieGTF, Bambu.bambuGTF, Flair.flairGTF, Talon.talonGTF, Flames.flamesGFF]
    Array[File] gtfListReferenceFree = [IsoQuantReferenceFree.isoQuantGTF, IsoQuantv2.isoQuantv2GTF, StringTieReferenceFree.stringTieGTF, IsoSeq.isoSeqGFF, IsoSeqv2.isoSeqv2GFF, Cupcake.cupcakeGFF]
    Array[String] toolNamesReduced = ["mandalorian", "isoquant", "isoquantv2", "stringtie", "bambu", "flair", "talon", "flames"]
    Array[String] toolNamesReferenceFree = ["isoquant", "isoquantv2" "stringtie", "isoseq", "isoseqv2", "cupcake"]

    scatter(gtfAndTool in zip(gtfListReduced, toolNamesReduced)) {
        File gtf = gtfAndTool.left
        String tool = gtfAndTool.right

        call IsoformDiscoveryBenchmarkTasks.GffCompareTrack {
            input:
                datasetName = datasetName,
                toolName = tool,
                toolGTF = gtf,
                expressedGTF = expressedGTF,
                expressedKeptGTF = expressedKeptGTF
        }
    }

    call IsoformDiscoveryBenchmarkTasks.GffCompareTrackDenovo {
        input:
            datasetName = datasetName,
            toolGTFs = gtfListReduced,
            expressedKeptGTF = expressedKeptGTF
    }

    scatter(gtf in gtfListReferenceFree) {
        call IsoformDiscoveryBenchmarkTasks.ReferenceFreeAnalysis {
            input:
                inputGTF = gtf,
                expressedGTF = expressedGTF
        }
    }

    call IsoformDiscoveryBenchmarkTasks.SummarizeAnalysis {
        input:
            trackingFiles = GffCompareTrack.tracking,
            toolNames = toolNamesReduced,
            datasetName = datasetName
    }

    call IsoformDiscoveryBenchmarkTasks.SummarizeReferenceFreeAnalysis {
        input:
            inputList = ReferenceFreeAnalysis.stats,
            toolNames = toolNamesReferenceFree,
            datasetName = datasetName
    }

    call IsoformDiscoveryBenchmarkTasks.SummarizeDenovoAnalysis {
        input:
            trackingFile = GffCompareTrackDenovo.tracking,
            toolNames = toolNamesReduced,
            datasetName = datasetName
    }

    call IsoformDiscoveryBenchmarkTasks.PlotAnalysisSummary as PlotAnalysisSummary {
        input:
            summary = SummarizeAnalysis.summary,
            datasetName = datasetName,
            type = "reduced"
    }

    call IsoformDiscoveryBenchmarkTasks.PlotAnalysisSummary as PlotAnalysisSummaryReferenceFree {
        input:
            summary = SummarizeReferenceFreeAnalysis.summary,
            datasetName = datasetName,
            type = "reffree"
    }

    call IsoformDiscoveryBenchmarkTasks.PlotDenovoAnalysisSummary as PlotDenovoAnalysisSummaryKnown {
        input:
            denovoSummary = SummarizeDenovoAnalysis.denovoSummaryKnown,
            datasetName = datasetName,
            type = "known"
    }

    call IsoformDiscoveryBenchmarkTasks.PlotDenovoAnalysisSummary as PlotDenovoAnalysisSummaryNovel {
        input:
            denovoSummary = SummarizeDenovoAnalysis.denovoSummaryNovel,
            datasetName = datasetName,
            type = "novel"
    }

    output {
        File analysisSummary = SummarizeAnalysis.summary
        File analysisSummaryReferenceFree = SummarizeReferenceFreeAnalysis.summary
        File analysisSummaryDenovoKnown = SummarizeDenovoAnalysis.denovoSummaryKnown
        File analysisSummaryDenovoNovel = SummarizeDenovoAnalysis.denovoSummaryNovel
        File analysisSummaryPlot = PlotAnalysisSummary.analysisSummaryPlot
        File referenceFreeAnalysisSummaryPlot = PlotAnalysisSummaryReferenceFree.analysisSummaryPlot
        File denovoAnalysisSummaryPlotKnown = PlotDenovoAnalysisSummaryKnown.denovoAnalysisSummaryPlot
        File denovoAnalysisSummaryPlotNovel = PlotDenovoAnalysisSummaryNovel.denovoAnalysisSummaryPlot
    }
}
