#' Get node files from compute nodes. By default, this operation will print the files on screen.
#'
#' @param cluster The cluster object
#' @param nodeId Id of the node
#' @param filePath  The path to the file that you want to get the contents of
#' @param verbose Flag for printing log files onto console
#'
#' @param ... Further named parameters
#' \itemize{
#'  \item{"downloadPath"}: { Path to save file to }
#'  \item{"overwrite"}: { Will only overwrite existing localPath }
#'}
#'
#' @examples
#' \dontrun{
#' stdoutText <- getClusterFile(cluster, "tvm-1170471534_1-20170829t072146z",
#' filePath = "stdout.txt", verbose = FALSE)
#' getClusterFile(cluster, "tvm-1170471534_2-20170829t072146z",
#' filePath = "wd/output.csv", downloadPath = "output.csv", overwrite = TRUE)
#' }
#' @export
getClusterFile <-
  function(cluster,
           nodeId,
           filePath,
           verbose = TRUE,
           overwrite = FALSE,
           downloadPath = NULL) {
    prefixfilePath <- "startup/%s"

    if (startsWith(filePath, "/")) {
      filePath <- substring(filePath, 2)
    }

    filePath <- sprintf(prefixfilePath, filePath)

    config <- getConfiguration()
    batchClient <- config$batchClient

    nodeFileContent <- batchClient$fileOperations$getNodeFile(
      cluster$poolId,
      nodeId,
      filePath,
      progress = TRUE,
      downloadPath = downloadPath,
      overwrite = overwrite
    )

    nodeFileContent
  }

#' Get job-related files from cluster node. By default, this operation will print the files on screen.
#'
#' @param jobId Id of the foreach job
#' @param taskId Id of the task
#' @param filePath  the path to the task file that you want to get the contents of
#' @param verbose Flag for printing the log files onto console
#' @param ... Further named parameters
#' \itemize{
#'  \item{"downloadPath"}: { Path to save file to }
#'  \item{"overwrite"}: { Will only overwrite existing localPath }
#'}
#'
#' @examples
#' \dontrun{
#' stdoutFile <- getJobFile("job20170822055031", "job20170822055031-task1", "stderr.txt")
#' getJobFile("job20170822055031", "job20170822055031-task1", "stdout.txt", downloadPath = "hello.txt")
#' }
#' @export
getJobFile <-
  function(jobId,
           taskId,
           filePath,
           downloadPath = NULL,
           verbose = TRUE,
           overwrite = FALSE) {

    if (startsWith(filePath, "/")) {
      filePath <- substring(filePath, 2)
    }

    config <- getConfiguration()
    batchClient <- config$batchClient

    jobFileContent <- batchClient$fileOperations$getTaskFile(
      jobId,
      taskId,
      filePath,
      downloadPath = downloadPath,
      overwrite = overwrite,
      progress = TRUE
    )

    jobFileContent
  }
