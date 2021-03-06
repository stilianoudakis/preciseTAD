context("test-createTADdata")

test_that("Whether createTADdata gives us the same output", {

    data(arrowhead_gm12878_5kb)
    bounds.GR <- extractBoundaries(domains.mat=arrowhead_gm12878_5kb,
                                   filter=FALSE,
                                   CHR=c("CHR21","CHR22"),
                                   resolution=5000)

    data(tfbsList)

    set.seed(123)

    tadData <- createTADdata(bounds.GR=bounds.GR,
                             resolution=5000,
                             genomicElements.GR=tfbsList,
                             featureType="oc",
                             resampling="rus",
                             trainCHR="CHR21",
                             predictCHR="CHR22")

    expect_equal(nrow(tadData[[1]]), 370)

    expect_equal(nrow(tadData[[2]]), 9660)

})
