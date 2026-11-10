enrich <- function(a,b,c,d,e,f,g,h) {
  
  if (c == "org.Sc.sgd.db") {
    
    key_db <- "COMMON"
    
  } else { 
    key_db <- "SYMBOL"
    }
  
  if (length(b) == 0) {
    enrichGO(
      gene       = a,
      OrgDb      = get(c),
      pAdjustMethod = d,
      pvalueCutoff  = e,
      qvalueCutoff  = f,
      minGSS        = g,
      maxGSS        = h,
      ont           = "ALL",
      pool          = FALSE,
      keyType       = key_db
    )
    
  } else {
    enrichGO(
      gene       = a,
      universe   = b,
      OrgDb      = get(c),
      pAdjustMethod = d,
      pvalueCutoff  = e,
      qvalueCutoff  = f,
      minGSS        = g,
      maxGSS        = h,
      ont           = "ALL",
      pool          = FALSE,
      keyType       = key_db
    )
    
  }
  

}