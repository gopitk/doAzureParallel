library(doAzureParallel)

doAzureParallel::setCredentials("credentials.json")
storageAccountName <- "<YOUR_STORAGE_ACCOUNT>"
inputContainerName <- "datasets"

# Generate a sas tokens with the createSasToken function

# Write-only SAS. Will be used for uploading files to storage.
writeSasToken <- rAzureBatch::createSasToken(permission = "w", sr = "c", path = inputContainerName)

# Read-only SAS. Will be used for downloading files from storage.
readSasToken <- rAzureBatch::createSasToken(permission = "r", sr = "c", path = inputContainerName)

# Create a Storage container in the Azure Storage account
rAzureBatch::createContainer(inputContainerName)

# Upload blobs with a write sasToken
rAzureBatch::uploadBlob(inputContainerName,
           fileDirectory = "1989.csv",
           sasToken = writeSasToken,
           accountName = storageAccountName)

rAzureBatch::uploadBlob(inputContainerName,
           fileDirectory = "1990.csv",
           sasToken = writeSasToken,
           accountName = storageAccountName)

# Create URL paths with read-only permissions
csvFileUrl1 <- rAzureBatch::createBlobUrl(storageAccount = storageAccountName,
              containerName = inputContainerName,
              sasToken = readSasToken,
              fileName = "1989.csv")


csvFileUrl2 <- rAzureBatch::createBlobUrl(storageAccount = storageAccountName,
                             containerName = inputContainerName,
                             sasToken = readSasToken,
                             fileName = "1990.csv")

# Create a list of files to download to the cluster using read-only permissions
# Place the files in a directory called 'data'
resource_files = list(
  rAzureBatch::createResourceFile(url = csvFileUrl1, fileName = "data/1989.csv"),
  rAzureBatch::createResourceFile(url = csvFileUrl2, fileName = "data/1990.csv")
)

# Create the cluster
cluster <- makeCluster("sas_resource_files_cluster.json", resourceFiles = resource_files)
registerDoAzureParallel(cluster)
workers <- getDoParWorkers()

# Files downloaded to the cluster are placed in a specific directory on each node called 'wd'
# Use the pre-defined environment variable 'AZ_BATCH_NODE_STARTUP_DIR' to find the path to the directory
listFiles <- foreach(i = 1:workers, .combine='rbind') %dopar% {
  fileDirectory <- paste0(Sys.getenv("AZ_BATCH_NODE_STARTUP_DIR"), "/wd", "/data")
  files <- list.files(fileDirectory)
  df = data.frame("node" = i, "files" = files)
  return(df)
}

# List the files downloaded to each node in the cluster
listFiles

stopCluster(cluster)
