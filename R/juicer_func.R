#' Helper function for transforming a GRanges object into matrix form to be
#' saved as .txt or .BED file and imported into juicer
#'
#' @param grdat A GRanges object representing boundary coordinates
#'
#' @return A dataframe that can be saved as a BED file to import into juicer
#'
#' @export
#'
#' @import IRanges GenomicRanges
#'
#' @examples
#' \donttest{
#' # Read in ARROWHEAD-called TADs at 5kb
#' data(arrowhead_gm12878_5kb)
#'
#' # Extract unique boundaries
#' bounds.GR <- extractBoundaries(domains.mat = arrowhead_gm12878_5kb,
#'                                filter = FALSE,
#'                                CHR = c("CHR21", "CHR22"),
#'                                resolution = 5000)
#'
#' # Read in GRangesList of 26 TFBS
#' data(tfbsList)
#'
#' tfbsList_filt <- tfbsList[which(names(tfbsList) %in%
#'                                                    c("Gm12878-Ctcf-Broad",
#'                                                      "Gm12878-Rad21-Haib",
#'                                                      "Gm12878-Smc3-Sydh",
#'                                                      "Gm12878-Znf143-Sydh"))]
#'
#' # Create the binned data matrix for CHR1 (training) and CHR22 (testing)
#' # using 5 kb binning, distance-type predictors from 26 different TFBS from
#' # the GM12878 cell line, and random under-sampling
#' tadData <- createTADdata(bounds.GR = bounds.GR,
#'                          resolution = 5000,
#'                          genomicElements.GR = tfbsList_filt,
#'                          featureType = "distance",
#'                          resampling = "rus",
#'                          trainCHR = "CHR21",
#'                          predictCHR = "CHR22")
#'
#' # Perform random forest using TADrandomForest by tuning mtry over 10 values
#' # using 3-fold CV
#' tadModel <- TADrandomForest(trainData = tadData[[1]],
#'                             testData = tadData[[2]],
#'                             tuneParams = list(mtry = 2,
#'                                             ntree = 500,
#'                                             nodesize = 1),
#'                             cvFolds = 3,
#'                             cvMetric = "Accuracy",
#'                             verbose = TRUE,
#'                             model = TRUE,
#'                             importances = TRUE,
#'                             impMeasure = "MDA",
#'                             performances = TRUE)
#'
#' # Apply preciseTAD on a specific 2mb section of CHR22:17000000-19000000
#' pt <- preciseTAD(genomicElements.GR = tfbsList_filt,
#'                  featureType = "distance",
#'                  CHR = "CHR22",
#'                  chromCoords = list(17000000, 19000000),
#'                  tadModel = tadModel[[1]],
#'                  threshold = 1.0,
#'                  verbose = TRUE,
#'                  parallel = TRUE,
#'                  cores = 2,
#'                  splits = 2,
#'                  DBSCAN_params = list(10000, 3),
#'                  flank = NULL)
#'
#' # Transform into juicer format
#' juicer_func(pt[[2]])
#' }
juicer_func <- function(grdat) {
    # n <- length(unique(as.character(seqnames(grdat))))
    
    chrs <- unique(as.character(seqnames(grdat)))
    
    mat_list <- list()
    
    for (i in seq_len(length(chrs))) {
        grdat_chr <- grdat[which(as.character(seqnames(grdat)) == chrs[i])]
        
        if (length(grdat_chr) > 1) {
            mymat <- data.frame(matrix(nrow = (length(grdat_chr) - 1), ncol = 6))
            mymat[, 1] <- mymat[, 4] <- gsub("chr", "", chrs[i])
            for (j in seq_len(length(grdat_chr) - 1)) {
                mymat[j, 2] <- mymat[j, 5] <- start(grdat_chr)[j]
                mymat[j, 3] <- mymat[j, 6] <- start(grdat_chr)[j + 1]
            }
            
            mat_list[[i]] <- mymat
            
        }
        
    }
    
    mat_list <- do.call("rbind.data.frame", mat_list)
    names(mat_list) <- c("chr1", "x1", "x2", "chr2", "y1", "y2")
    return(mat_list)
    
}
