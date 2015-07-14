library(dplyr)
if(!file.exists('projectfile.zip')) {
  url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
  download.file(url,'projectfile.zip')
  unzip('projectfile.zip')
}

uci_path <- 'UCI HAR Dataset'
train_path <- 'train/X_train.txt'
test_path <- 'test/X_test.txt'
feat_path <- 'features.txt'

full_train <- paste(uci_path,train_path,sep="/")
full_test <- paste(uci_path,test_path,sep="/")
full_feat <- paste(uci_path,feat_path,sep="/")

train_data <- readLines(full_train)
test_data <- readLines(full_test)
feat <- read.table(full_feat,sep=" ")

#Concatenate the training and test data sets
full_data <- c(train_data,test_data)
#Clear the memory.
rm(train_data,test_data)

#Get rid of double spacing:
full_data <- gsub("  "," ",full_data)
#Now that is sorted, we can split based on space:
full_data <- read.table(text = full_data,sep=" ")
#Not sure why, but kill the first NA column
full_data <- select(full_data,-1)
#Now assign the names... paste the row number as well as there are dupes
names(full_data) <- paste0(feat[,1],feat[,2])
#now, lets limit to only those with mean and standard dev:
mean.sd.data <- select(full_data,contains('mean()'),contains('std()'))
