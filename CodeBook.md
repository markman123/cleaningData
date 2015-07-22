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
#Training paths
full_train <- concat_pth(train_path)
full_train_type <- concat_pth(train_type)
full_train_subj <- concat_pth(train_subj)

#Test paths
full_test <- concat_pth(test_path)
full_test_type <- concat_pth(test_type)
full_test_subj <- concat_pth(test_subj)

#Feature i.e. column names
full_feat <- concat_pth(feat_path)
```

### Filtering Columns
I tried importing all 360-odd columns, and that didn't end well. I then decided to filter the mean() & std() and only import these columns.

To do this, `read.table` the columns and then filter by using the `dplyr` function `filter()`:

```
#Column labels
feat <- read.table(full_feat,sep=" ")
inscope <- filter(feat
                  ,grepl('mean()',V2,fixed=TRUE) |
                    grepl('std()',V2,fixed=TRUE)
)
```
The columns of the input files are 16 characters wide, and as part of the `read.fwf` (fwf = fixed width file) function, if you pass a negative number as part of a vector, this is 'ignore'.

#### `getCols()`
```
#getCols will limit the column vector for fixed width import to try and save on mem!
#colNumbers - vector of the columns that need to be imported
#ttlCols - total number of columns in the document (561 for ours)
#fwsize - Fixed width size (16 char columns in the source file for us)
getCols <- function(colNumbers,ttlCols,fwsize) {
  v <- integer()
  for (i in 1:ttlCols){
    if(i %in% colNumbers){
      #if it is an inscope, add it as +ive
      v <- c(v,fwsize)
    } else {
      v <- c(v,-1*fwsize)
    }
  }
  v
}
```
This is called in the assignment as `fwCols <- getCols(inscope$V1,561,16)` which will create a vector which has 16 where the column has __mean()__ or __std()__ in it and -16 where it does not. This will import only those that are columns.

### Loading the files and concatenating
Using the `getCols()` function, there is a vector of 16 and -16 for the fixed width files. Each are loaded in turn, they are bound together with `cbind()` and then finally moving them all to `full_data` as well as removing the staging variables to free the memory.

```
#Load the data
train_data <- read.fwf(full_train,fwCols)
names(train_data) <- inscope$V2
train_subj_data <- read.table(full_train_subj)
train_activity <- read.table(full_train_type)

#Test
test_data <- read.fwf(full_test,fwCols)
names(test_data) <- inscope$V2
test_subj_data <- read.table(full_test_subj)
test_activity <- read.table(full_test_type)


#Add the additional columns to train_data and test_data
train_data <- cbind(train_data,train_subj_data,train_activity)
names(train_data)[67:68] <- c("SubjectNumber","ActivityNumber")

test_data <- cbind(test_data,test_subj_data,test_activity)
names(test_data)[67:68] <- c("SubjectNumber","ActivityNumber")

#Concatenate the training and test data sets
full_data <- rbind(train_data,test_data)
rm(test_data
   ,test_activity
   ,test_subj_data
   ,train_data
   ,train_activity
   ,train_subj_data)
```

### Changing activity numbers to activity names
In the dataset, there are integers to represent **WALKING**, **STANDING** etc., so these should now be changed to be te terms. This is done by reading the list `activity_labels.txt` file, and then merging the tables and dropping the index:

```

#Now to change the factor of ActivityNumber to a friendly name
activity_label_path <- concat_pth('activity_labels.txt')
activity_label_data <- read.table(activity_label_path,sep=" ",col.names = c('ActivityNumber','ActivityName'))

full_data <- merge(full_data,activity_label_data) %>% select(-ActivityNumber)
```
The net result is closer, now to melt it with `tidyr` packages.

### Tidyr it up
Moving the 60-something columns is simply with `tidyr`'s gather function:

```
library(tidyr)
tidy_data <- gather(full_data
                    ,MeasurementName,MeasurementValue
                    ,-c(SubjectNumber,ActivityName))
```
The `gather()` function takes the dataset (full_data), the name of the key - 'MeasurementName', the name of the value field 'MeasurementValue' and finally the columns. IN this case, it has been articulated all columns except the SubjectNumber and ActivityName columns. A small subset of the data is below:

```
  SubjectNumber ActivityName   MeasurementName MeasurementValue
1             7      WALKING tBodyAcc-mean()-X        0.3016485
2             5      WALKING tBodyAcc-mean()-X        0.3433592
3             6      WALKING tBodyAcc-mean()-X        0.2696745
4            23      WALKING tBodyAcc-mean()-X        0.2681938
5             7      WALKING tBodyAcc-mean()-X        0.3141912
6             7      WALKING tBodyAcc-mean()-X        0.2032763
```

The columns have been 'melted' down into the MeasurementName / MeasurementValue columns.

### Summarising
Finally, I use the `dplyr` functions `summarise`, `%>%` and `group_by` functions to show the mean of SubjectNumber/ActivityName, MeasurementName unique combinations:

```
summ <- group_by(tidy_data,SubjectNumber,ActivityName,MeasurementName) %>%
        summarise(avg=mean(MeasurementValue))
```

This group's by, and passes into summarise to take the `mean` of the `MeasurementValue` function into a new column named `avg` giving the final output table of:

```
  SubjectNumber ActivityName   MeasurementName         avg
1             1       LAYING tBodyAcc-mean()-X  0.22159824
2             1       LAYING tBodyAcc-mean()-Y -0.04051395
3             1       LAYING tBodyAcc-mean()-Z -0.11320355
4             1       LAYING  tBodyAcc-std()-X -0.92805647
5             1       LAYING  tBodyAcc-std()-Y -0.83682741
6             1       LAYING  tBodyAcc-std()-Z -0.82606140
```

which is outputed with default variables of `write.table` by:

```
write.table(summ,'out.txt',row.names = FALSE)
```
