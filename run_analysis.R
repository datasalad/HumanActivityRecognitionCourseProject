runAnalysis <- function() {
    
    ## initial settings  
    currentDir <- getwd()
    rawDataDir <- "rawdata"
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    dataFilesDir <- "UCI HAR Dataset"
    
    rawDataset <- file.path(currentDir, rawDataDir, "dataset.zip")
    
    ## download and unzip UCI HAR Dataset if it doesn't exist on the filesystem
    if (!dir.exists(rawDataDir)) {
        dir.create(rawDataDir)
        setwd(file.path(currentDir, rawDataDir))
        download.file(url, rawDataset)
        unzip(rawDataset)
        setwd(currentDir)
    } 
    
    list.files(file.path(currentDir, rawDataDir, dataFilesDir))
    
    ## ----------------------------------------------------------------------------
    ## --- Step 1 - Merge the training and the test sets to create one data set 
    ## ----------------------------------------------------------------------------
    
    ## get the training dataset
    trainingtData <- read.table(file.path(currentDir, rawDataDir, dataFilesDir, "train", "X_train.txt"))
    
    ## get the test dataset
    testData <- read.table(file.path(currentDir, rawDataDir, dataFilesDir, "test", "X_test.txt"))
    
    ## merge two datasets by rows (training data followed by the test data)
    mergedDataset <- rbind(trainingtData, testData)
    
    ## ----------------------------------------------------------------------------
    ## --- Step 2 - Extract only the measurements on the mean and 
    ## --- standard deviation for each measurement 
    ## ----------------------------------------------------------------------------
    
    ## get features list
    features <- read.table(file.path(currentDir, rawDataDir, dataFilesDir, "features.txt"))
    
    ## apply column names
    names(features) <- c("featureId", "featureName")
    
    ## get only the feature for standard deviation and mean
    requiredFeatures <- grep("std|mean", features$featureName, ignore.case = FALSE)
    
    ## extract the measurements for required features
    measurementsDataset <- mergedDataset[ ,requiredFeatures]
    
    
    ## ----------------------------------------------------------------------------
    ## --- Step 3 - Uses descriptive activity names to name the activities
    ## --- in the data set
    ## ----------------------------------------------------------------------------
    
    ## Lets create a new data frame, where we'll merge activities data from training and test datasets
    
    ## read activity labels
    activities <- read.table(file.path(currentDir, rawDataDir, dataFilesDir, "activity_labels.txt"))
    
    ## read activities data from training and test datasets
    trainingDataActivitiesRaw <- read.table(file.path(currentDir, rawDataDir, dataFilesDir, "train", "y_train.txt"))
    testDataActivitiesRaw <- read.table(file.path(currentDir, rawDataDir, dataFilesDir, "test", "y_test.txt"))
    
    ## create a data frame for training data and replace the values for activities with a helper function
    trainingDataActivity <- data.frame(activity = replaceActivityNames(trainingDataActivitiesRaw$V1, activities))
    testDataActivity <- data.frame(activity = replaceActivityNames(testDataActivitiesRaw$V1, activities))
    
    ## merge two datasets by rows (training data followed by the test data - like we did for measurements data)
    activityData <- rbind(trainingDataActivity, testDataActivity)
    
    ## ----------------------------------------------------------------------------
    ## --- Step 4 - Appropriately label the data set with descriptive
    ## --- variable names
    ## ----------------------------------------------------------------------------
    
    descriptiveNames <- features$featureName[requiredFeatures]
    
    descriptiveNames <- gsub("Mag", "-magnitude", descriptiveNames)
    descriptiveNames <- gsub("Acc", "-acceleration", descriptiveNames)
    descriptiveNames <- gsub("BodyBody", "body", descriptiveNames)
    descriptiveNames <- gsub("^f(.*)$", "\\1-frequency", descriptiveNames)
    descriptiveNames <- gsub("^t(.*)$", "\\1-time", descriptiveNames)
    descriptiveNames <- gsub("(Jerk|Gyro)", "-\\1", descriptiveNames)
    descriptiveNames <- gsub("\\(\\)", "", descriptiveNames)
    descriptiveNames <- tolower(descriptiveNames)
    
    print("measurementsDataset labels:")
    print(descriptiveNames)
    
    ## set column names
    names(measurementsDataset) <- descriptiveNames
    
    ## get the subjects data from training and test datasets and merge them like we
    ## did for activities and measurement
    trainingSubjects <- read.table(file.path(currentDir, rawDataDir, dataFilesDir, "train", "subject_train.txt"))
    testSubjects <- read.table(file.path(currentDir, rawDataDir, dataFilesDir, "test", "subject_test.txt"))
    subjects <- rbind(trainingSubjects, testSubjects)
    names(subjects) <- c("subject")
    
    ## combine subjects with activities (by columns) + measurements
    dataset <- cbind(cbind(subjects, activityData), measurementsDataset)
    str(dataset)
    
    ## ----------------------------------------------------------------------------
    ## --- Step 5 - From the data set in step 4, creates a second, independent 
    ## --- tidy data set with the average of each variable for each activity 
    ## --- and each subject
    ## ----------------------------------------------------------------------------
    
    # ## Calculate the average of each variable for each activity and each subject
    # allSubjects <- sort(unique(subjects$subject))
    # allActivities <- as.vector(activities$V2)
    # allVariables <- descriptiveNames
    # 
    # tidyDataset <- data.frame()
    # 
    # for (subj in allSubjects){
    #     for (act in allActivities) {
    #         ## crate a new observation, which consists of (subject, activity, mean of variable)
    #         observation <- c(subj)
    #         observation <- append(observation, act)
    #         data <- dataset[(dataset$subject == subj & dataset$activity == act) , ]
    #         
    #         for (variable in allVariables){
    #             ## calculate average for each feature
    #             varMean <- mean(data[ , variable])
    #             
    #             ## add mean to the observation 
    #             observation <- append(observation, varMean)
    #         }
    #         ## append the observation to the dataset
    #         tidyDataset <- rbind(tidyDataset, as.data.frame(t(observation)))
    #     }
    # }
    # 
    # ## apply names
    # names(tidyDataset) <- c("subject", "activity", as.vector(descriptiveNames))
    # str(tidyDataset)
    
    
    ## UPD
    ## updated to more elegant, dplyr version of step 5
    
    library(dplyr)
    
    tidyDataset <- tbl_df(dataset) %>%
        group_by(subject, activity) %>%
        summarize_each(funs(mean))
    
    str(tidyDataset)
    
    ## write the dataset for the submission into the file
    write.table(tidyDataset, "tidydataset.txt", row.name = FALSE)
}

## helper function to replace the values for activities with a descriptive labels
replaceActivityNames <- function(activities, labels) {
    for(i in labels$V1) {
        activities[activities == i] <- as.character(labels$V2[i])
    }
    activities
}