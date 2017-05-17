## This R script will achieve the following:

# 1. Merge the training set with the test set to make a merged dataset
# 2. Extract only the mean and the standard deviation for each measurement 
# 3. Use descriptive activity names to name the activities in the data set
# 4. Lable the data set with descriptive variable names
# 5. Creates the desired tidy data set for the purpose of this assignement

## PROCEDURE FOLLOWED

#The file is a zipped file containing data stored as text.  The folder needs to be downloaded and uzipped appropriately

# Create a working directory named manyien and set it for this project

#Download and unzip the folder

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(url, destfile= "./Dataset.zip")

# Unzip the file 

unzip(zipfile= "./Dataset.zip", exdir = "./manyien")

# Load the necessary libraries

library(dplyr)

library(data.table)

library(tidyr)


# Create the file Path..... 

filesPath<- "C:/Users/Dominic/Documents/data/manyien/data/UCI HAR Dataset"

# Merge the training and the test data to create one data set:

dataTrain <- tbl_df(read.table('./train/X_train.txt'))
dataTest <- tbl_df(read.table('./test/X_test.txt'))
dataMerged<- rbind(dataTrain, dataTest)

subTrain<- tbl_df(read.table('./train/subject_train.txt'))
subTest<- tbl_df(read.table('./test/subject_test.txt'))
subject<- rbind(subTrain, subTest)

lableTrain<- tbl_df(read.table('./train/Y_train.txt'))
lableTest<- tbl_df(read.table('./test/Y_test.txt'))
lable<- rbind(lableTrain, lableTest)

# Extract the mean and standard ceviation on the for each measurement 

dataFeatures <- read.table('./features.txt')
SdMean <- grep("-mean\\(\\)|-std\\(\\)", dataFeatures[, 2])
dataMergedSdMean <- dataMerged[, SdMean]


# Name activities in the data set
names(dataMergedSdMean) <- dataFeatures[SdMean, 2]
names(dataMergedSdMean) <- tolower(names(dataMergedSdMean))
names(dataMergedSdMean) <- gsub("\\(|\\)", "", names(dataMergedSdMean))

activities <- read.table('./activity_labels.txt')
tolower(as.character(gsub("_", "", activities$V2)))

lable$V1= activities[lable$V1, 2]
colnames(lable)<- 'activity'
colnames(subject) <- 'subject'


# Organizing and combining all data sets into single one.

newData<-cbind(subject, dataMergedSdMean, lable)

# Defining descriptive names for all variables.
names(newData) <- make.names(names(newData))
names(newData) <- gsub('Acc',"Acceleration",names(newData))
names(newData) <- gsub('GyroJerk',"AngularAcceleration",names(newData))
names(newData) <- gsub('Gyro',"AngularSpeed",names(newData))
names(newData) <- gsub('Mag',"Magnitude",names(newData))
names(newData) <- gsub('^t',"TimeDomain.",names(newData))
names(newData) <- gsub('^f',"FrequencyDomain.",names(newData))
names(newData) <- gsub('\\.mean',".Mean",names(newData))
names(newData) <- gsub('\\.std',".StandardDeviation",names(newData))
names(newData) <- gsub('Freq\\.',"Frequency.",names(newData))
names(newData) <- gsub('Freq$',"Frequency",names(newData))

# Creates a second, independent tidy data set with the average of each variable for each activity and each subject

secData<-aggregate(. ~subject + activity, newData, mean)
secData<-secData[order(secData$subject,secData$activity),]
write.table(secData, file = "TidyData.txt",row.name=FALSE)

