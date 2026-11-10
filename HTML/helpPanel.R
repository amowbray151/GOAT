helpmenu <- function() {
  HTML(r"(
        <h2>Preface</h2>
        <p>
       Welcome to GOAT! This ShinyApp uses the clusterProfiler package for R to run GO enrichment,
       alongside enrichplot for plotting functions. This is a brief guide designed to help you understand
       how to perform and interpret the results of GO enrichment, and when to use a given plot. I
       assume you are familiar with basic concepts in transcriptomics and statistics. This guide is in no
       way exhaustive, but will hopefully give an introduction to some topics more specific to GO
       enrichment, such as <b>Universe</b> or <b>Gene Set Size</b> to those who are not familiar with the field.
        </p>
        <p>
       I also recommend running your enrichment not only here, but also at least 2 other softwares. 
       There is a lot of variance between softwares due to annotation databases and mapping 
       algorithms, so the results in one are unlikely to match another. For my dataset, clusterProfiler
       happened to work out best, but that may not be the case for you. Some examples of other 
       softwares to try are:
        </p>
       
        <ul>
          <li>GOShiny   </li>
          <li>PANTHER   </li>
          <li>g:Profiler</li>
        </ul>
       
        <h2>GO Enrichment – Input Parameters</h2>
        <p>
       The left-hand side is where you can input your parameters. For the most part, defaults should 
       suffice, though you will obviously need to customize depending on your differentially expressed 
       genes (DEGs), your universe, and organism used. 
        </p>
        <p>
       <b>Universe</b> refers to the background set of genes against which enrichment is tested. For
       RNA-seq, this should generally include all genes that were eligible for differential expression 
       analysis, regardless of whether they were ultimately classified as differentially expressed. In
       practice, this usually means all genes that passed your initial expression/filtering criteria (e.g. 
       filtering so that all genes have a status of “OK”). Each run of RNA-seq has its own universe. 
       Therefore, if you are running GO enrichment on 2-day, 1-week, and 4-week treated groups, you 
       should have a 2-day, 1-week, and 4-week universe. Please do not be lazy, input a universe. 
       You will have less bloat in the output, and it is more defensible than omitting one. <b><h5>I repeat: Please do not 
       be lazy, input a universe!</h5></b>
        </p>
        <p>
       You are also offered the choice of <b>FDR method</b>. Most typically, <b>Benjamini-Hochberg</b> is used in 
       the world of GO enrichment. It controls the <b>false discovery rate (FDR)</b>, and making it less
       conservative than the <b>Bonferroni</b> method, which controls the <b>family-wise error rate (FWER)</b>.
       Given the large number of comparisons being made, Benjamini-Hochberg is often preferred, 
       though the option to change this remains. 
        </p>
        <p>
       Finally, you may select your <b>minimum and maximum Gene Set Sizes (GSS)</b>. These refer to 
       the minimum and maximum number of genes allowed in a GO term, respectively. The purpose
       of this is to <b>reduce bloat and uninformative results</b>. 10 and 500 are just default 
       values, so feel free to tune these to your data.
        </p>
        <p>
       After clicking <b>Run</b>, you will likely see the error message: <b>“Warning: X% of input gene IDs are
       fail to map…”</b> This is to be expected, as it is unlikely all genes will be mapped in a given 
       database (e.g. unclassified genes will not be mapped). For your DEGs, this number should be 
       <b>fairly low</b>, though it depends on the size of your input. For your universe, expect it to be a bit
       higher, but it should still remain <b>relatively low</b>. Unfortunately, there is no real rule for what is 
       acceptable, so use your best judgement on if results are erroneous or not. If you have a very 
       large number of genes that fail to map, you may have selected the incorrect organism.
        </p>
        <h2>GO Enrichment – Results</h2>
        <p>
       After clicking run, the enrichment process will run, and you should see 3 tables. I will offer a brief 
       description of what these are telling you:
        </p>
        <p>
       <b>Ontology:</b> Biological Process (BP), Molecular Function (MF), or Cellular Component (CC). <b>BP</b>
       refers to the actual biological function of genes involved (e.g. response to heat). <b>MF</b> is more 
       concerned with functions at the molecular level (e.g. E-box binding). Finally, <b>CC</b> refers to the 
       cellular location at which genes accomplish their functions (e.g. cytoplasm). Most commonly, BP 
       and MF are where emphasis is placed, though CC still gives useful information.
        </p>
        <p>
        <b>ID/Description:</b> Identifiers for enriched GO Terms. Description is what you will most likely focus on.
        </p>
        <p>
       <b>GeneRatio:</b> This is the number of genes enriched in the GO Term <b>(k)</b> over the total DEGs input 
       <b>(n)</b>. It represents the portion of genes in your input that were contained in a given GO Term. If 
       the n does not match your total list of DEGs, it is likely fine, as some genes may be omitted due 
       to not being mapped.
        </p>
        <h5 style="text-align: center;">GeneRatio = k/n</h5>
        <p>
       <b>BgRatio:</b> This is the total number of genes in the GO Term <b>(K)</b> over the size of your universe 
       <b>(N)</b>. As with GeneRatio, N may not match your actual total universe size.
        </p>
        <h5 style="text-align: center;">BgRatio = K/N</h5>
        <p>
       <b>RichFactor:</b> This is the ratio of genes enriched in the GO Term <b>(k)</b> over the total number of 
       genes in a GO Term <b>(K)</b>. This helps normalize the results between GO Terms containing many 
       genes with those containing few. For example, 5 genes enriched in a pathway containing 15 
       genes would have the same RichFactor as 50 genes enriched in a pathway containing 150 
       genes.
        </p>
        <h5 style="text-align: center;">RichFactor = k/K</h5>
        <p>
       <b>FoldEnrichment:</b> This refers to the effect size of your enriched term, and is equal to your 
       <b>GeneRatio</b> divided by your <b>BgRatio</b>. It confers how much more frequently genes in your input
       list occur in a given GO Term relative to the background universe. Take caution in interpreting it 
       at first glance, however, as small GSSs can inflate the value artificially. <b>Interpret 
       FoldEnrichment alongside your other results!</b>
        </p>
        <h5 style="text-align: center;">FoldEnrichment = GeneRatio/BgRatio = (k/n)/(K/N)</h5>
        <p>
       <b>oddsRatio:</b> Compares the odds of observing genes associated with a GO Term in the input 
       gene list versus the background universe. Is not typically used, but is nice to have. 
        </p>
        <p>
       <b>z-score:</b> A measurement in standard deviations of how far the observed number of genes 
       associated with a GO term deviates from the expected number.
        </p>
        <p>
       <b>pvalue:</b> Your p-value <b>before</b> correction for multiple hypothesis testing.
        </p>
        <p>
       <b>qvalue:</b> An estimate of the minimum false discovery rate (FDR) at which a particular GO term 
       would be considered significant. <b>This is distinct from the adjusted p-value</b>. 
        </p>
        <p>
       <b>p.adjust:</b> Your p-value <b>after</b> correction for multiple hypothesis testing. This accounts for the
       large number of GO terms being tested, and is <b>typically the value reported</b> when discussing 
       statistical significance. 
        </p>
        <p>
       <b>geneID:</b> This is the list of enriched genes contained in a GO Term. 
        </p>
        <p>
       <b>Count:</b> This is the number of genes enriched in the GO Term <b>(k)</b>. 
        </p>
        <p>
       Finally, we have 2 download buttons. The difference between them is that raw GO Terms are 
       simply the list of GO Terms before the simplify() function was run, which helps <b>eliminate 
       degenerate terms similar in meaning</b>. For example, “non-canonical Wnt signaling”, “canonical 
       Wnt signaling ”, and “Wnt signaling ” may be reduced to just “non-canonical Wnt signaling”, 
       depending on the genes involved. The simplified GO Terms should suffice, though <b>the 
       non-simplified terms are available if desired</b>.
        </p>
        <h2>Plotting</h2>
        <p>
       With the results downloaded, GOAT also offers several plotting functions to help visualize and 
       interpret the enrichment results through the use of the enrichplot package. I will offer a brief 
       description of the purpose for each of the plots.
        </p>
        <p>
       <b>Dot Plots:</b> This is one of the most widely used plots for reporting enrichment results. Terms are 
       often ordered by <b>GeneRatio</b>, with size referring to the <b>Count</b> of genes in the term, and colour 
       denoting the <b>p-adjusted</b> value. Here, I use <b>-log<sub>10</sub>(p.adjust)</b> for visual clarity, as a larger value 
       confers a smaller p-value, and therefore stronger statistical evidence against the null hypothesis.
       It is typical to report the top 10 or so terms.
        </p>
        <p>
       <b>Enrichmen Map Plots:</b> Enrichment maps visualize GO terms as nodes, with connections 
       representing their <b>semantic similarity</b>. Terms that are more closely related are connected, 
       allowing clusters of functionally related GO terms to be identified. Their strength lies in helping 
       interpret results. If you have many GO Terms, this plot can help <b>visualize which terms are 
       closely related to each other</b>, and which are less related. The best use case is when you have 
       many enriched terms, and need to show that clusters of GO Terms are related in functional 
       outcome (e.g. you have 15 terms involved in fibrosis, 8 involved in apoptosis, and 11 involved in
       cilium movement).
        </p>
        <p>
       <b>Gene-Concept Network Plots:</b> These genes are similar to enrichment plots, though they do not
       sort by semantic similarity. Instead, their purpose is to <b>show which genes overlap between
       GO terms</b>. For example, if the gene Wnt3a were to be involved in 7/10 of the plotted terms, it
       would be connected to 7/10 nodes. Only genes contained in at least 2 terms will be named. 
       Because of the visual clutter, fewer terms are typically better when plotting.
        </p>
        <p>
       <b>Tree Plots:</b> The final supported type of plot as of now is the tree plot. These serve a similar 
       purpose to enrichment plots, wherein GO Terms are hierarchically clustered according to 
       semantic similarity. <b>Tree plots have discrete clusters, while enrichment map plots do 
       not</b>. Tree plots can be more interpretable at a glance and have less clutter, though they serve a 
       similar purpose to enrichment map plots.
        </p>
        <h2>Final Notes</h2>
        <p>
       And that about wraps up the tutorial! I hope it helped and you understand the basics of GO
       enrichment. There are plenty of resources out there that explore these topics in more depth than 
       I did, so I would encourage you to read them if you are interested. Again, your mileage may vary 
       depending on the software, so if you haven’t, check out some other software to see if your
       results are more coherent there. If you have any suggestions for improvements, let me know!
        </p>
          )"
     
)
}