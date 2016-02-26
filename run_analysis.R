# 1. Merge the training and the test sets to create one data set.

# Set the working directory to the folder location  where the data set was unzipped.
setwd('C:/Users/deschmidt/Desktop/Getting and Cleaning Data/Course Project/UCI HAR Dataset')

#Read in the data
features <- read.table('./features.txt', header = FALSE)
activityLabel <- read.table('./activity_labels.txt', header = FALSE, col.names = c('activityID', 'activityType'))
subjectTrain <- read.table('./train/subject_train.txt', header = FALSE, col.names = "subjectID")
xTrain <- read.table('./train/x_train.txt', header = FALSE, col.names = features[,2])
yTrain <- read.table('./train/y_train.txt', header = FALSE, col.names = "activityID")
subjectTest <- read.table('./test/subject_test.txt', header = FALSE, col.names = "subjectID")
xTest <- read.table('./test/x_test.txt', header = FALSE, col.names = features[,2])
yTest <- read.table('./test/y_test.txt', header = FALSE, col.names = "activityID")

#Combine data tables by row
xData <- rbind(xTrain, xTest)
subjectData <- rbind(subjectTrain, subjectTest)
yData <- rbind(yTrain, yTest)

#Combine data by column to get final data set
dataCombined <- cbind(subjectData, yData)
dataFinal <- cbind(xData, dataCombined)

#Create a vector of column names from the final data set (dataFinal)
colNames <- colnames(dataFinal)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.

#Create a logical vector to get TRUE values for the ID, mean and standard deviation columns.
subNameVector = (grepl("activity..",colNames) | grepl("subject..",colNames) | grepl(".mean..",colNames) & !grepl(".meanFreq..",colNames) & !grepl(".mean..-",colNames) | grepl(".std..",colNames) & !grepl(".std()..-",colNames))

#Subset dataFinal using subNameVector to get only the desired colunms
dataFinal <- dataFinal[subNameVector == TRUE]

# 3. Use descriptive activity names to name the activities in the data set

#Merge dataFinal with activityLabel to get descriptive activity names
dataFinal <- merge(dataFinal, activityLabel, by = 'activityID', all.x = TRUE)

#Create new column name vector to include new column names
colNames <- colnames(dataFinal)

# 4. Appropriately label the data set with descriptive variable names.

#Rename variables to get cleaner column names
names(dataFinal) <- gsub("^t", "Time", names(dataFinal))
names(dataFinal) <- gsub("^f", "Frequency", names(dataFinal))
names(dataFinal) <- gsub("BodyBody", "Body", names(dataFinal))
names(dataFinal) <- gsub("Gyro", "Gyroscope", names(dataFinal))
names(dataFinal) <- gsub("Acc", "Accelerometer", names(dataFinal))
names(dataFinal) <- gsub("Mag", "Magnitude", names(dataFinal))

# 5. Create a second, independent tidy data set with the average of each variable for each activity and each subject.

# Create a new table by removing the activityType column
dataFinalWOactType = dataFinal[,names(dataFinal) != 'activityType']

# Aggregate dataFinalWOactType to get just the average of each variable for each activity and each subject
tidyData = aggregate(dataFinalWOactType[,names(dataFinalWOactType) != c('activityID','subjectID')],by=list(activityID=dataFinalWOactType$activityID,subjectID = dataFinalWOactType$subjectID),mean)

# Merge dataFinalWOactType with activityLabel to bring back activityType
tidyData = merge(tidyData,activityLabel,by='activityID',all.x=TRUE)

# Export the tidyData set 
write.table(tidyData, './tidyData.txt',row.names=TRUE,sep='\t')