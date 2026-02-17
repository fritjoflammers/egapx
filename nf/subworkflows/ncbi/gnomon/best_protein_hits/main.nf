#!/usr/bin/env nextflow
nextflow.enable.dsl=2


/*
 *   align_filter -filter 'pct_coverage >= 50' -nogenbank 
 *      | align_sort -ifmt seq-align-set -k query,-bit_score,slen,-align_length -group 1 -top 1 -nogenbank
 */


include { merge_params } from '../../utilities'


workflow best_protein_hits {
    take:
        gnomon_prot_asn
        swiss_prot_asn
        prot_alignments
        parameters  // Map : extra parameter and parameter update
    main:
        String align_filter_params = merge_params('-ifmt seq-align-set -nogenbank', parameters, 'align_filter')
        String align_sort_params = merge_params('-ifmt seq-align-set -nogenbank', parameters, 'align_sort')

        run_protein_filter_replacement(gnomon_prot_asn, swiss_prot_asn, prot_alignments, align_filter_params, align_sort_params)

    emit:
        alignments = run_protein_filter_replacement.out
}


process run_protein_filter_replacement {
    input:
        path gnomon_prot_asn, stageAs: 'indexed/*'
        path swiss_prot_asn, stageAs: 'indexed/*'
        path input_prot_alignments, stageAs: "input_alignments.asnb"
        val align_filter_params
        val align_sort_params
    
    output:
        path "output/*"
    
    script:
    // Generate unique cache dir per task to avoid collisions
    def cache_dir = "/cluster/scratch/flamme/egapx/asncache_${task.index}_${task.hash}"
    """
    # Create task-specific cache directory
    TMP_CACHE="${cache_dir}"
    mkdir -p \$TMP_CACHE
    
    # Prime the cache
    prime_cache -cache \$TMP_CACHE -ifmt asnb-seq-entry -i ${gnomon_prot_asn} -oseq-ids /dev/null -split-sequences
    prime_cache -cache \$TMP_CACHE -ifmt asnb-seq-entry -i ${swiss_prot_asn} -oseq-ids /dev/null -split-sequences
    
    # Run alignment
    mkdir -p ./output
    # critical fix was adding the "-tmp " parameter
    # as per https://github.com/ncbi/egapx/issues/161#issuecomment-3312572038 
    align_sort ${align_sort_params} -tmp /cluster/scratch/flamme/egapx/ -asn-cache \$TMP_CACHE -i ./input_alignments.asnb -o output/best_protein_hits.asnb
    
    # Cleanup
    rm -rf \$TMP_CACHE
    """
    
    stub:
    """
    mkdir -p output
    touch ./output/best_protein_hits.asnb
    """
}

