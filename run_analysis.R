## Merges training and the test sets

realDataName = "./UCI HAR Dataset/train/X_train.txt"
testDataName = "./UCI HAR Dataset/test/X_test.txt"

realSet <- read.table(realDataName, header = FALSE)
testSet <- read.table(testDataName, header = FALSE)

dataSet <- rbind(realSet, testSet)

## Extracts measurements on the mean and standard deviations

featuresName = "./UCI HAR Dataset/features.txt"
features <- read.table(featuresName, header = FALSE, stringsAsFactors = FALSE)

meanStdFeatures <- features[grep("mean|std", features[, 2]), ]
meanStdDataSet <- dataSet[, meanStdFeatures[, 1]]

realSubjName = "./UCI HAR Dataset/train/Subject_train.txt"
testSubjName = "./UCI HAR Dataset/test/Subject_test.txt"

subjectRealSet <- read.table(realSubjName, header = FALSE)
subjectTestSet <- read.table(testSubjName, header = FALSE)
subjectDataSet <- rbind(subjectRealSet, subjectTestSet)

yRealName = "./UCI HAR Dataset/train/y_train.txt"
yTestName = "./UCI HAR Dataset/test/y_test.txt"

activityRealSet <- read.table(yRealName, header = FALSE)
activityTestSet <- read.table(yTestName, header = FALSE)
activityDataSet <- rbind(activityRealSet, activityTestSet)

meanStdDataSet <- cbind(meanStdDataSet, activityDataSet)
meanStdDataSet <- cbind(meanStdDataSet, subjectDataSet)
names(meanStdDataSet) <- c(meanStdFeatures[, 2], "Activity", "Subject")

## Uses descriptive activity names to name the activities in the data set

library(plyr)
activitiesIds <- meanStdDataSet[, "Activity"]
activitiesFactors <- as.factor(activitiesIds)
names <- c("1" = "walking",
           "2" = "upstairs",
           "3" = "downstairs",
           "4" = "sitting",
           "5" = "standing",
           "6"="laying")
activitiesFactors = revalue(activitiesFactors, names)
meanStdDataSet[, "Activity"] = activitiesFactors

## Appropriate labels the data set with descriptive activity names.

names(meanStdDataSet) <- c(meanStdFeatures[, 2], "Activity", "Subject")

## Creates independent tidy data set with the average of each variable for each activity/subject

library(data.table)
tidyDataTable <- data.table(meanStdDataSet)
avgTidyDataTable <- tidyDataTable[, lapply(.SD, mean), by = c("Activity", "Subject")]
newColNames = sapply(names(avgTidyDataTable)[-(1:2)], function(name) paste("mean", name, sep = " "))
setnames(avgTidyDataTable, names(avgTidyDataTable), c("Activity", "Subject", newColNames))
write.csv(avgTidyDataTable, file = "output.txt", row.names = FALSE)
