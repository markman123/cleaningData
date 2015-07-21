#Code Book - Wearables
This code book outlines the steps undertaken by the R-script `run_anlaysis.R` which can be found in this repository.

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
There are several files that are required to be imported to create our dataset. To manage this, I created a series of variables to hold the path information relative to the 'UCI HAR Dataset' folder:

```
#Path to the training data, the type and the subject #
train_path <- 'train/X_train.txt'
train_type <- 'train/y_train.txt'
train_subj <- 'train/subject_train.txt'
#Now for the test data, as above
test_path <- 'test/X_test.txt'
test_type <- 'test/y_test.txt'
test_subj <- 'test/subject_test.txt'
#And the names of the columns are here
feat_path <- 'features.txt'
```
Since these are relative to the path, and my folder is in the working directory, I created a helper function to manage the concatenation and to try and keep as DRY (Don't Repeat Yourself) as possible.

### Helper Function - concat_pth()
`concat_pth()` is a simple function which takes two inputs:
* pth - the path relative to the data folder. These are articulated in my implementation above.
* fld - folder that has the data, defaults to 'UCI HAR Dataset'.

Here is the function:
```
concat_pth <- function(pth,fld='UCI HAR Dataset') {
  paste(fld,pth,sep="/")
}
```
The paste function has a seperator argument, which concatenates each of the arguments with this in between.

### The files - in depth
Looking at the files more closely, there are 7 files which are brought together to make our dataset:

* X\_train/X\_test: contains the data, made up of 561 columns of data read from the Galaxy
* y\_train/y\_test: contains the activity identifier, which I've called `ActivityID`. These are later converted by...
* activity_labels: Contains the mapping from ID to name, such as Laying etc.
* subject\_train/subject\_test: Listing of the unique identifier of the subject/person whom the measurements relate to

These are concatenated using the helper function articulated above, and stored in variables:
```

```