#Code Book - Wearables
This code book outlines the steps undertaken by the R-script _run_anlaysis.R_ which can be found on the front page of this git hub.

##Sourcing the data
The data is dowloaded from the following repository:
[Download location] (https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

This can be done directly from R with the following command:
```
 url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
  download.file(url,'projectfile.zip')
```
The zip file downloaded is then extracted to the working directory via
```
  unzip('projectfile.zip')
```

##Importing the data
###Folder Structure
The folder structure is setup as follows, after it is zipped up.

The folder housing the data is `UCI HAR Dataset`, which contains multiple folders. The first folder, `train` has the training data as well as `test` which has the test data. Finally, the column headers are stored within `features.txt` housed in the home directory.

The applicable files we end on concatenating are here:

```
uci_path <- 'UCI HAR Dataset'
train_path <- 'train/X_train.txt'
test_path <- 'test/X_test.txt'
feat_path <- 'features.txt'

full_train <- paste(uci_path,train_path,sep="/")
full_test <- paste(uci_path,test_path,sep="/")
full_feat <- paste(uci_path,feat_path,sep="/")
```

Here the R function `paste()` is used with the `sep="/"` defined, so as to create a full path. This should work for any OS, however, I did it within Windows.

###Bringing the data into R
The format of the files seems to be delimited by spaces, however, there are instances where there are double spaces. To deal with these, the function `readLines()` is utilised to simply return the raw contents in a vector:

```
train_data <- readLines(full_train)
test_data <- readLines(full_test)
feat <- read.table(full_feat,sep=" ")

#Concatenate the training and test data sets
full_data <- c(train_data,test_data)
```
Additionally, the column names are brought in here into the variable `feat`, which will be utilised later.

The `c()` function here concatenates the two vectors together to one long vector. Now we need to split it into columns.

##Working with the data
