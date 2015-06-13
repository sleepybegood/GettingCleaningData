# This script does the following
# 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each
#    measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.


## install and load needed packages

if("data.table" %in% rownames(installed.packages()) == FALSE) {
  install.packages("data.table")}

if("downloader" %in% rownames(installed.packages()) == FALSE) {
  install.packages("downloader")}

library(data.table)
library(downloader)


## the firs we have to do is read the data from the web

urlData<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 

## create a temporal directory

tdir <- tempdir()

## change working directory from the temporal directory

setwd(tdir)


## download the data and unzip in the temporal directory

download(urlData, dest="dataset.zip", mode="wb") 
unzip("dataset.zip")


## Read the data
## X are the features
## Y are activities
## Subj are the subjects


trainSubj<-read.table("./UCI HAR Dataset/train/subject_train.txt",header=FALSE)
trainY<-read.table("./UCI HAR Dataset/train/y_train.txt",header=FALSE)
trainX<-read.table("./UCI HAR Dataset/train/X_train.txt",header=FALSE)
testSubj<-read.table("./UCI HAR Dataset/test/subject_test.txt",header=FALSE)
testY<-read.table("./UCI HAR Dataset/test/y_test.txt",header=FALSE)
testX<-read.table("./UCI HAR Dataset/test/X_test.txt",header=FALSE)
features<-read.table("./UCI HAR Dataset/features.txt",header=FALSE)
activityLabels<-read.table("./UCI HAR Dataset/activity_labels.txt",header=FALSE)


## STEP 1: Create the total data

## bind the features train and test
X<-rbind(trainX, testX)

## bind the activities train and test
Y<-rbind(trainY, testY)

## bind the subjects train and test
Subj<-rbind(trainSubj, testSubj)

## the names of the X set are in the features object
colnames(X)<-c(as.character(features$V2))

## name Y as activityNumber
colnames(Y)<-'activityNumber'

## name Subj are subj
colnames(Subj)<-"subj"


## Total data in data.table class for step 5

union<-cbind(Subj,X,Y)
union<-data.table(union)



## STEP 2: Extracts only the measurements on the mean and standard deviation
## for each measurement. 

## For extract only the measurements on the mean and standard deviation I use 
## the grep function that allows identify a pattern in a vector of characters. 
## Means variables have the pattern "mean". Is important delete variables with 
## pattern "meanFreq".

## Variables with "mean" or "Mean"
means<-c(grep("mean", colnames(union)))

## Variables with "meanFreq"
meanFreqs<-grep("meanFreq", colnames(union))

## Variables with mean and not with meanFreq
means<-means[!means%in%meanFreqs]

## Variables with std
desvs<-grep("std", colnames(union))

## Select only the wanted variables
varSel<-union[,c(1,563,means,desvs), with=FALSE]



## STEP 3: Uses descriptive activity names to name the activities in the 
## data set

## For this is neccesary rename the activityLabels set, because in data.table
## mergin is only possible by key or by variables with the same name.

colnames(activityLabels)<-c('activityNumber', 'activityName')
varSel<-merge(varSel, activityLabels, by='activityNumber', 
              all.x=TRUE, all.y=FALSE)

## Delete activity number because we have now the activity name

varSel<-varSel[,activityNumber:=NULL]


## STEP 4: Appropriately labels the data set with descriptive variable names. 

newcolnames<-gsub("-mean\\()-","Mean",colnames(varSel))
newcolnames<-gsub("-mean\\()","Mean",newcolnames)
newcolnames<-gsub("-std\\()-","Std",newcolnames)
newcolnames<-gsub("-std\\()","Std",newcolnames)

setnames(varSel, colnames(varSel), newcolnames)



## STEP 5: New data with the means of all variables by subj y activity.

meanVars<-varSel[,lapply(.SD,mean),by=c("activityName","subj")]

write.table(meanVars,file='./tidyData.txt',
            row.names=FALSE, sep="\t", quote=FALSE)





