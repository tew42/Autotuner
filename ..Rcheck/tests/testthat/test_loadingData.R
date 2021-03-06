context("Preparing things for Autotuner")

mmetspFiles <- c(system.file("mzMLs/mtab_mmetsp_ft_120815_24.mzML", package = "mmetspData"),
                 system.file("mzMLs/mtab_mmetsp_ft_120815_25.mzML", package = "mmetspData"),
                 system.file("mzMLs/mtab_mmetsp_ft_120815_26.mzML", package = "mmetspData"))

runfile <- read.csv(system.file("mmetsp_metadata.csv", package = "mmetspData"),
                    stringsAsFactors = F)

runfile <- runfile[runfile$File.Name %in% sub(pattern = ".mzML", "", basename(mmetspFiles)),]

## Loading Autotuner
Autotuner <- createAutotuner(mmetspFiles,
                             runfile,
                             file_col = "File.Name",
                             factorCol = "Sample.Type")

test_that(desc = "Auotuner object creaction",
          code = {

              # this function runs all tests when called upon

              ## Checking if Autotuner is able to correctly subset data
              ## by metadata columns
              expect_equal(sum(c(Autotuner@file_col,
                                 Autotuner@factorCol) %in%
                                    colnames(Autotuner@metadata)), 2)

              ## checking that Autotuner object is constructed with correct
              ## output

              expect_equal(class(Autotuner@time), "list")
              expect_equal(class(unlist(Autotuner@time)), "numeric")
              expect_equal(class(Autotuner@intensity), "list")
              expect_equal(class(unlist(Autotuner@intensity)), "numeric")
              expect_equal(class(Autotuner@file_paths), "character")
              expect_equal(class(unlist(Autotuner@intensity)), "numeric")

              #Autotuner@metadata
              #Autotuner@file_paths


})

lag <- 20
threshold<- 3
influence <- 0.1
signal <- lapply(Autotuner@intensity, ThresholdingAlgo, lag, threshold, influence)

test_that(desc = "Signal Processing Structure", code = {

    ## check that the correct object is returned from signal function
    expect_equal(length(signal), 3)
    expect_equal(length(signal[[1]]), 3)
    expect_equal(length(signal[[2]]), 3)
    expect_equal(length(signal[[3]]), 3)

})

test_that(desc = "Signal Processing Output",
          code = {

              ## check that computation took place
              naCheck <- list()
              for(i in seq_along(signal)) {
                  naCheck[[i]] <- sum(sapply(signal[[3]], function(x) {
                      all(is.na(x))
                  }))

              }

              expect_equal(naCheck[[1]], 0)
              expect_equal(naCheck[[2]], 0)
              expect_equal(naCheck[[3]], 0)

})

returned_peaks <- 10
peaks <- extract_peaks(Autotuner = Autotuner,
                       returned_peaks = returned_peaks,
                       signals = signal)

test_that(desc = "Checking Function to Return Peaks",
          code = {

              nullCount <- sum(sapply(peaks, is.null))
              expect_equal(nullCount, 0)
              expect_equal(ncol(peaks[[1]]) <= returned_peaks, TRUE)

})

returned_peaks <- 10
peak_table <- peakwidth_table(Autotuner = Autotuner,
                              peakList = peaks,
                              returned_peaks = returned_peaks)
test_that(desc = "Checking Peakwidth_table",
          code = {
                expect_equal(class(peak_table), "data.frame")
                expect_equal(any(is.na(peak_table)), FALSE)
          })

peak_difference <- peak_time_difference(peak_table)

test_that(desc = "Checking peak_time_difference",
          code = {
              expect_equal(class(peak_difference), "data.frame")
          })


