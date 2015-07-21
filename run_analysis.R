library(dplyr)
if(!file.exists('projectfile.zip')) {
  url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
  download.file(url,'projectfile.zip')
  unzip('projectfile.zip')
}


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

#Concatenate paths function
#pth = path relative to UCI folder
#fld = folder, UCI by default
concat_pth <- function(pth,fld='UCI HAR Dataset') {
  paste(fld,pth,sep="/")
}

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

#Column labels
feat <- read.table(full_feat,sep=" ")
inscope <- filter(feat
                  ,grepl('mean()',V2,fixed=TRUE) |
                    grepl('std()',V2,fixed=TRUE)
)

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

#Get the vector for columns to import, using custom function
fwCols <- getCols(inscope$V1,561,16)

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

#Now to change the factor of ActivityNumber to a friendly name
activity_label_path <- concat_pth('activity_labels.txt')
activity_label_data <- read.table(activity_label_path,sep=" ",col.names = c('ActivityNumber','ActivityName'))

full_data <- merge(full_data,activity_label_data) %>% select(-ActivityNumber)
library(tidyr)
tidy_data <- gather(full_data
                    ,MeasurementName,MeasurementValue
                    ,-c(SubjectNumber,ActivityName))

summ <- group_by(tidy_data,SubjectNumber,ActivityName,MeasurementName) %>%
        summarise(avg=mean(MeasurementValue))

write.table(summ,'out.txt',row.names = FALSE)