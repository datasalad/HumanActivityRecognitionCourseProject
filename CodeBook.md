Codebook
========
This code book describes the variables, the data, and transformations/work  performed to clean up the data.


The Experiment
------------------------------

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. 

The Data Set Structure
------------------------------
- 'README.txt'

- 'features_info.txt': Shows information about the variables used on the feature vector.

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

- 'train/X_train.txt': Training set.

- 'train/y_train.txt': Training labels.

- 'test/X_test.txt': Test set.

- 'test/y_test.txt': Test labels.

The following files are available for the train and test data. Their descriptions are equivalent. 

- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

- 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

- 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

- 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 

**Note**: All the files in train/Inertial Signals and test/Inertial Signals **will not be used** for in this analysis.

Units
------------------------------
- The measurements of acceleration signal from the smartphone accelerometer is in standard gravity units 'g'.
- The measurements from gyroscope are in radians/second. 


Transformations / any work  performed to clean up the data
------------------------------


`run_analysis.R` script does the following:


0. Downloads the data for analysis and unzips the archive.

```r
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
```

1. Merges the training set `trainingtData` and the test set `testData` to create one data set `mergedDataset`.

```r 
    ## ----------------------------------------------------------------------------
    ## --- Step 1 - Merge the training and the test sets to create one data set 
    ## ----------------------------------------------------------------------------
    
    ## get the training dataset
    trainingtData <- read.table(file.path(currentDir, rawDataDir, dataFilesDir, "train", "X_train.txt"))
    
    ## get the test dataset
    testData <- read.table(file.path(currentDir, rawDataDir, dataFilesDir, "test", "X_test.txt"))
    
    ## merge two datasets by rows (training data followed by the test data)
    mergedDataset <- rbind(trainingtData, testData)
```
2. Extracts only the measurements on the mean `mean()` and standard deviation `std()` for each measurement.

```r 
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
```
3. Uses descriptive activity names to name the activities in the data set.

```r 
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
```
4. Appropriately labels the data set with descriptive variable names from.

```r 
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
```
5. From the data set in step 4, creates a second, independent tidy data set `tidyDataset` with the average of each variable for each activity and each subject.

```r 
    ## ----------------------------------------------------------------------------
    ## --- Step 5 - From the data set in step 4, creates a second, independent 
    ## --- tidy data set with the average of each variable for each activity 
    ## --- and each subject
    ## ----------------------------------------------------------------------------
    
    ## Calculate the average of each variable for each activity and each subject
    allSubjects <- sort(unique(subjects$subject))
    allActivities <- as.vector(activities$V2)
    allVariables <- descriptiveNames
    
    tidyDataset <- data.frame()
    
    for (subj in allSubjects){
        for (act in allActivities) {
            ## crate a new observation, which consists of (subject, activity, mean of variable)
            observation <- c(subj)
            observation <- append(observation, act)
            data <- dataset[(dataset$subject == subj & dataset$activity == act) , ]
            
            for (variable in allVariables){
                ## calculate average for each feature
                varMean <- mean(data[ , variable])
                
                ## add mean to the observation 
                observation <- append(observation, varMean)
            }
            ## append the observation to the dataset
            tidyDataset <- rbind(tidyDataset, as.data.frame(t(observation)))
        }
    }
    
    ## apply names
    names(tidyDataset) <- c("subject", "activity", as.vector(descriptiveNames))
    str(tidyDataset)
```

The script saves the tidy data set of `180` observations and `81` columns (`2` columns for `subject` and `activity` and `79` columns for measurement variables) to a text file called `tidydataset.txt`.


```r 
    ## write the dataset for the submission into the file
    write.table(tidyDataset, "tidydataset.txt", row.name = FALSE)
```


run_analysis.R script output
------------------------------

```r
runAnalysis()
```

```
trying URL 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
Content type 'application/zip' length 62556944 bytes (59.7 MB)
==================================================
downloaded 59.7 MB

measurementsDataset labels:

 [1] "body-acceleration-mean-x-time"                       "body-acceleration-mean-y-time"                      
 [3] "body-acceleration-mean-z-time"                       "body-acceleration-std-x-time"                       
 [5] "body-acceleration-std-y-time"                        "body-acceleration-std-z-time"                       
 [7] "gravity-acceleration-mean-x-time"                    "gravity-acceleration-mean-y-time"                   
 [9] "gravity-acceleration-mean-z-time"                    "gravity-acceleration-std-x-time"                    
[11] "gravity-acceleration-std-y-time"                     "gravity-acceleration-std-z-time"                    
[13] "body-acceleration-jerk-mean-x-time"                  "body-acceleration-jerk-mean-y-time"                 
[15] "body-acceleration-jerk-mean-z-time"                  "body-acceleration-jerk-std-x-time"                  
[17] "body-acceleration-jerk-std-y-time"                   "body-acceleration-jerk-std-z-time"                  
[19] "body-gyro-mean-x-time"                               "body-gyro-mean-y-time"                              
[21] "body-gyro-mean-z-time"                               "body-gyro-std-x-time"                               
[23] "body-gyro-std-y-time"                                "body-gyro-std-z-time"                               
[25] "body-gyro-jerk-mean-x-time"                          "body-gyro-jerk-mean-y-time"                         
[27] "body-gyro-jerk-mean-z-time"                          "body-gyro-jerk-std-x-time"                          
[29] "body-gyro-jerk-std-y-time"                           "body-gyro-jerk-std-z-time"                          
[31] "body-acceleration-magnitude-mean-time"               "body-acceleration-magnitude-std-time"               
[33] "gravity-acceleration-magnitude-mean-time"            "gravity-acceleration-magnitude-std-time"            
[35] "body-acceleration-jerk-magnitude-mean-time"          "body-acceleration-jerk-magnitude-std-time"          
[37] "body-gyro-magnitude-mean-time"                       "body-gyro-magnitude-std-time"                       
[39] "body-gyro-jerk-magnitude-mean-time"                  "body-gyro-jerk-magnitude-std-time"                  
[41] "body-acceleration-mean-x-frequency"                  "body-acceleration-mean-y-frequency"                 
[43] "body-acceleration-mean-z-frequency"                  "body-acceleration-std-x-frequency"                  
[45] "body-acceleration-std-y-frequency"                   "body-acceleration-std-z-frequency"                  
[47] "body-acceleration-meanfreq-x-frequency"              "body-acceleration-meanfreq-y-frequency"             
[49] "body-acceleration-meanfreq-z-frequency"              "body-acceleration-jerk-mean-x-frequency"            
[51] "body-acceleration-jerk-mean-y-frequency"             "body-acceleration-jerk-mean-z-frequency"            
[53] "body-acceleration-jerk-std-x-frequency"              "body-acceleration-jerk-std-y-frequency"             
[55] "body-acceleration-jerk-std-z-frequency"              "body-acceleration-jerk-meanfreq-x-frequency"        
[57] "body-acceleration-jerk-meanfreq-y-frequency"         "body-acceleration-jerk-meanfreq-z-frequency"        
[59] "body-gyro-mean-x-frequency"                          "body-gyro-mean-y-frequency"                         
[61] "body-gyro-mean-z-frequency"                          "body-gyro-std-x-frequency"                          
[63] "body-gyro-std-y-frequency"                           "body-gyro-std-z-frequency"                          
[65] "body-gyro-meanfreq-x-frequency"                      "body-gyro-meanfreq-y-frequency"                     
[67] "body-gyro-meanfreq-z-frequency"                      "body-acceleration-magnitude-mean-frequency"         
[69] "body-acceleration-magnitude-std-frequency"           "body-acceleration-magnitude-meanfreq-frequency"     
[71] "body-acceleration-jerk-magnitude-mean-frequency"     "body-acceleration-jerk-magnitude-std-frequency"     
[73] "body-acceleration-jerk-magnitude-meanfreq-frequency" "body-gyro-magnitude-mean-frequency"                 
[75] "body-gyro-magnitude-std-frequency"                   "body-gyro-magnitude-meanfreq-frequency"             
[77] "body-gyro-jerk-magnitude-mean-frequency"             "body-gyro-jerk-magnitude-std-frequency"             
[79] "body-gyro-jerk-magnitude-meanfreq-frequency"        
```

```r
str(dataset)
```

```
'data.frame':	10299 obs. of  81 variables:
 $ subject                                            : int  1 1 1 1 1 1 1 1 1 1 ...
 $ activity                                           : Factor w/ 6 levels "LAYING","SITTING",..: 3 3 3 3 3 3 3 3 3 3 ...
 $ body-acceleration-mean-x-time                      : num  0.289 0.278 0.28 0.279 0.277 ...
 $ body-acceleration-mean-y-time                      : num  -0.0203 -0.0164 -0.0195 -0.0262 -0.0166 ...
 $ body-acceleration-mean-z-time                      : num  -0.133 -0.124 -0.113 -0.123 -0.115 ...
 $ body-acceleration-std-x-time                       : num  -0.995 -0.998 -0.995 -0.996 -0.998 ...
 $ body-acceleration-std-y-time                       : num  -0.983 -0.975 -0.967 -0.983 -0.981 ...
 $ body-acceleration-std-z-time                       : num  -0.914 -0.96 -0.979 -0.991 -0.99 ...
 $ gravity-acceleration-mean-x-time                   : num  0.963 0.967 0.967 0.968 0.968 ...
 $ gravity-acceleration-mean-y-time                   : num  -0.141 -0.142 -0.142 -0.144 -0.149 ...
 $ gravity-acceleration-mean-z-time                   : num  0.1154 0.1094 0.1019 0.0999 0.0945 ...
 $ gravity-acceleration-std-x-time                    : num  -0.985 -0.997 -1 -0.997 -0.998 ...
 $ gravity-acceleration-std-y-time                    : num  -0.982 -0.989 -0.993 -0.981 -0.988 ...
 $ gravity-acceleration-std-z-time                    : num  -0.878 -0.932 -0.993 -0.978 -0.979 ...
 $ body-acceleration-jerk-mean-x-time                 : num  0.078 0.074 0.0736 0.0773 0.0734 ...
 $ body-acceleration-jerk-mean-y-time                 : num  0.005 0.00577 0.0031 0.02006 0.01912 ...
 $ body-acceleration-jerk-mean-z-time                 : num  -0.06783 0.02938 -0.00905 -0.00986 0.01678 ...
 $ body-acceleration-jerk-std-x-time                  : num  -0.994 -0.996 -0.991 -0.993 -0.996 ...
 $ body-acceleration-jerk-std-y-time                  : num  -0.988 -0.981 -0.981 -0.988 -0.988 ...
 $ body-acceleration-jerk-std-z-time                  : num  -0.994 -0.992 -0.99 -0.993 -0.992 ...
 $ body-gyro-mean-x-time                              : num  -0.0061 -0.0161 -0.0317 -0.0434 -0.034 ...
 $ body-gyro-mean-y-time                              : num  -0.0314 -0.0839 -0.1023 -0.0914 -0.0747 ...
 $ body-gyro-mean-z-time                              : num  0.1077 0.1006 0.0961 0.0855 0.0774 ...
 $ body-gyro-std-x-time                               : num  -0.985 -0.983 -0.976 -0.991 -0.985 ...
 $ body-gyro-std-y-time                               : num  -0.977 -0.989 -0.994 -0.992 -0.992 ...
 $ body-gyro-std-z-time                               : num  -0.992 -0.989 -0.986 -0.988 -0.987 ...
 $ body-gyro-jerk-mean-x-time                         : num  -0.0992 -0.1105 -0.1085 -0.0912 -0.0908 ...
 $ body-gyro-jerk-mean-y-time                         : num  -0.0555 -0.0448 -0.0424 -0.0363 -0.0376 ...
 $ body-gyro-jerk-mean-z-time                         : num  -0.062 -0.0592 -0.0558 -0.0605 -0.0583 ...
 $ body-gyro-jerk-std-x-time                          : num  -0.992 -0.99 -0.988 -0.991 -0.991 ...
 $ body-gyro-jerk-std-y-time                          : num  -0.993 -0.997 -0.996 -0.997 -0.996 ...
 $ body-gyro-jerk-std-z-time                          : num  -0.992 -0.994 -0.992 -0.993 -0.995 ...
 $ body-acceleration-magnitude-mean-time              : num  -0.959 -0.979 -0.984 -0.987 -0.993 ...
 $ body-acceleration-magnitude-std-time               : num  -0.951 -0.976 -0.988 -0.986 -0.991 ...
 $ gravity-acceleration-magnitude-mean-time           : num  -0.959 -0.979 -0.984 -0.987 -0.993 ...
 $ gravity-acceleration-magnitude-std-time            : num  -0.951 -0.976 -0.988 -0.986 -0.991 ...
 $ body-acceleration-jerk-magnitude-mean-time         : num  -0.993 -0.991 -0.989 -0.993 -0.993 ...
 $ body-acceleration-jerk-magnitude-std-time          : num  -0.994 -0.992 -0.99 -0.993 -0.996 ...
 $ body-gyro-magnitude-mean-time                      : num  -0.969 -0.981 -0.976 -0.982 -0.985 ...
 $ body-gyro-magnitude-std-time                       : num  -0.964 -0.984 -0.986 -0.987 -0.989 ...
 $ body-gyro-jerk-magnitude-mean-time                 : num  -0.994 -0.995 -0.993 -0.996 -0.996 ...
 $ body-gyro-jerk-magnitude-std-time                  : num  -0.991 -0.996 -0.995 -0.995 -0.995 ...
 $ body-acceleration-mean-x-frequency                 : num  -0.995 -0.997 -0.994 -0.995 -0.997 ...
 $ body-acceleration-mean-y-frequency                 : num  -0.983 -0.977 -0.973 -0.984 -0.982 ...
 $ body-acceleration-mean-z-frequency                 : num  -0.939 -0.974 -0.983 -0.991 -0.988 ...
 $ body-acceleration-std-x-frequency                  : num  -0.995 -0.999 -0.996 -0.996 -0.999 ...
 $ body-acceleration-std-y-frequency                  : num  -0.983 -0.975 -0.966 -0.983 -0.98 ...
 $ body-acceleration-std-z-frequency                  : num  -0.906 -0.955 -0.977 -0.99 -0.992 ...
 $ body-acceleration-meanfreq-x-frequency             : num  0.252 0.271 0.125 0.029 0.181 ...
 $ body-acceleration-meanfreq-y-frequency             : num  0.1318 0.0429 -0.0646 0.0803 0.058 ...
 $ body-acceleration-meanfreq-z-frequency             : num  -0.0521 -0.0143 0.0827 0.1857 0.5598 ...
 $ body-acceleration-jerk-mean-x-frequency            : num  -0.992 -0.995 -0.991 -0.994 -0.996 ...
 $ body-acceleration-jerk-mean-y-frequency            : num  -0.987 -0.981 -0.982 -0.989 -0.989 ...
 $ body-acceleration-jerk-mean-z-frequency            : num  -0.99 -0.99 -0.988 -0.991 -0.991 ...
 $ body-acceleration-jerk-std-x-frequency             : num  -0.996 -0.997 -0.991 -0.991 -0.997 ...
 $ body-acceleration-jerk-std-y-frequency             : num  -0.991 -0.982 -0.981 -0.987 -0.989 ...
 $ body-acceleration-jerk-std-z-frequency             : num  -0.997 -0.993 -0.99 -0.994 -0.993 ...
 $ body-acceleration-jerk-meanfreq-x-frequency        : num  0.8704 0.6085 0.1154 0.0358 0.2734 ...
 $ body-acceleration-jerk-meanfreq-y-frequency        : num  0.2107 -0.0537 -0.1934 -0.093 0.0791 ...
 $ body-acceleration-jerk-meanfreq-z-frequency        : num  0.2637 0.0631 0.0383 0.1681 0.2924 ...
 $ body-gyro-mean-x-frequency                         : num  -0.987 -0.977 -0.975 -0.987 -0.982 ...
 $ body-gyro-mean-y-frequency                         : num  -0.982 -0.993 -0.994 -0.994 -0.993 ...
 $ body-gyro-mean-z-frequency                         : num  -0.99 -0.99 -0.987 -0.987 -0.989 ...
 $ body-gyro-std-x-frequency                          : num  -0.985 -0.985 -0.977 -0.993 -0.986 ...
 $ body-gyro-std-y-frequency                          : num  -0.974 -0.987 -0.993 -0.992 -0.992 ...
 $ body-gyro-std-z-frequency                          : num  -0.994 -0.99 -0.987 -0.989 -0.988 ...
 $ body-gyro-meanfreq-x-frequency                     : num  -0.2575 -0.0482 -0.2167 0.2169 -0.1533 ...
 $ body-gyro-meanfreq-y-frequency                     : num  0.0979 -0.4016 -0.0173 -0.1352 -0.0884 ...
 $ body-gyro-meanfreq-z-frequency                     : num  0.5472 -0.0682 -0.1107 -0.0497 -0.1622 ...
 $ body-acceleration-magnitude-mean-frequency         : num  -0.952 -0.981 -0.988 -0.988 -0.994 ...
 $ body-acceleration-magnitude-std-frequency          : num  -0.956 -0.976 -0.989 -0.987 -0.99 ...
 $ body-acceleration-magnitude-meanfreq-frequency     : num  -0.0884 -0.0441 0.2579 0.0736 0.3943 ...
 $ body-acceleration-jerk-magnitude-mean-frequency    : num  -0.994 -0.99 -0.989 -0.993 -0.996 ...
 $ body-acceleration-jerk-magnitude-std-frequency     : num  -0.994 -0.992 -0.991 -0.992 -0.994 ...
 $ body-acceleration-jerk-magnitude-meanfreq-frequency: num  0.347 0.532 0.661 0.679 0.559 ...
 $ body-gyro-magnitude-mean-frequency                 : num  -0.98 -0.988 -0.989 -0.989 -0.991 ...
 $ body-gyro-magnitude-std-frequency                  : num  -0.961 -0.983 -0.986 -0.988 -0.989 ...
 $ body-gyro-magnitude-meanfreq-frequency             : num  -0.129 -0.272 -0.2127 -0.0357 -0.2736 ...
 $ body-gyro-jerk-magnitude-mean-frequency            : num  -0.992 -0.996 -0.995 -0.995 -0.995 ...
 $ body-gyro-jerk-magnitude-std-frequency             : num  -0.991 -0.996 -0.995 -0.995 -0.995 ...
 $ body-gyro-jerk-magnitude-meanfreq-frequency        : num  -0.0743 0.1581 0.4145 0.4046 0.0878 ...
```

```r
str(tidyDataset)
```
```
'data.frame':	180 obs. of  81 variables:
 $ subject                                            : Factor w/ 30 levels "1","2","3","4",..: 1 1 1 1 1 1 2 2 2 2 ...
 $ activity                                           : Factor w/ 6 levels "WALKING","WALKING_UPSTAIRS",..: 1 2 3 4 5 6 1 2 3 4 ...
 $ body-acceleration-mean-x-time                      : Factor w/ 180 levels "0.277330758736842",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-mean-y-time                      : Factor w/ 180 levels "-0.0173838185273684",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-mean-z-time                      : Factor w/ 180 levels "-0.111148103547368",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-std-x-time                       : Factor w/ 180 levels "-0.283740258842105",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-std-y-time                       : Factor w/ 180 levels "0.114461336747368",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-std-z-time                       : Factor w/ 180 levels "-0.260027902210526",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ gravity-acceleration-mean-x-time                   : Factor w/ 180 levels "0.935223201473684",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ gravity-acceleration-mean-y-time                   : Factor w/ 180 levels "-0.282165021263158",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ gravity-acceleration-mean-z-time                   : Factor w/ 180 levels "-0.068102864",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ gravity-acceleration-std-x-time                    : Factor w/ 180 levels "-0.976609642526316",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ gravity-acceleration-std-y-time                    : Factor w/ 180 levels "-0.971305961473684",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ gravity-acceleration-std-z-time                    : Factor w/ 180 levels "-0.947717226105263",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-mean-x-time                 : Factor w/ 180 levels "0.0740416333157895",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-mean-y-time                 : Factor w/ 180 levels "0.0282721095884211",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-mean-z-time                 : Factor w/ 180 levels "-0.00416840617789474",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-std-x-time                  : Factor w/ 180 levels "-0.113615602435789",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-std-y-time                  : Factor w/ 180 levels "0.0670025007684211",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-std-z-time                  : Factor w/ 180 levels "-0.502699788526316",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-mean-x-time                              : Factor w/ 180 levels "-0.041830963526",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-mean-y-time                              : Factor w/ 180 levels "-0.0695300462115789",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-mean-z-time                              : Factor w/ 180 levels "0.0849448173042105",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-std-x-time                               : Factor w/ 180 levels "-0.473535485894737",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-std-y-time                               : Factor w/ 180 levels "-0.0546077686594737",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-std-z-time                               : Factor w/ 180 levels "-0.344266629473684",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-jerk-mean-x-time                         : Factor w/ 180 levels "-0.0899975423705263",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-jerk-mean-y-time                         : Factor w/ 180 levels "-0.0398428709463158",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-jerk-mean-z-time                         : Factor w/ 180 levels "-0.0461309295021053",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-jerk-std-x-time                          : Factor w/ 180 levels "-0.207421854757895",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-jerk-std-y-time                          : Factor w/ 180 levels "-0.304468510631579",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-jerk-std-z-time                          : Factor w/ 180 levels "-0.404255452631579",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-magnitude-mean-time              : Factor w/ 180 levels "-0.136971176556842",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-magnitude-std-time               : Factor w/ 180 levels "-0.219688645631579",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ gravity-acceleration-magnitude-mean-time           : Factor w/ 180 levels "-0.136971176556842",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ gravity-acceleration-magnitude-std-time            : Factor w/ 180 levels "-0.219688645631579",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-magnitude-mean-time         : Factor w/ 180 levels "-0.141428809031579",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-magnitude-std-time          : Factor w/ 180 levels "-0.0744717500625263",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-magnitude-mean-time                      : Factor w/ 180 levels "-0.160979552536842",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-magnitude-std-time                       : Factor w/ 180 levels "-0.186978364526316",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-jerk-magnitude-mean-time                 : Factor w/ 180 levels "-0.298703679084211",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-jerk-magnitude-std-time                  : Factor w/ 180 levels "-0.325324878894737",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-mean-x-frequency                 : Factor w/ 180 levels "-0.202794306326316",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-mean-y-frequency                 : Factor w/ 180 levels "0.0897127264021053",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-mean-z-frequency                 : Factor w/ 180 levels "-0.331560117789474",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-std-x-frequency                  : Factor w/ 180 levels "-0.319134719578947",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-std-y-frequency                  : Factor w/ 180 levels "0.056040006846",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-std-z-frequency                  : Factor w/ 180 levels "-0.279686751494737",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-meanfreq-x-frequency             : Factor w/ 180 levels "-0.207548374494737",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-meanfreq-y-frequency             : Factor w/ 180 levels "0.113093646103158",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-meanfreq-z-frequency             : Factor w/ 180 levels "0.0497265196172632",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-mean-x-frequency            : Factor w/ 180 levels "-0.170546964549579",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-mean-y-frequency            : Factor w/ 180 levels "-0.0352255241130632",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-mean-z-frequency            : Factor w/ 180 levels "-0.468999224631579",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-std-x-frequency             : Factor w/ 180 levels "-0.133586606326316",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-std-y-frequency             : Factor w/ 180 levels "0.106739857136",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-std-z-frequency             : Factor w/ 180 levels "-0.534713440421053",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-meanfreq-x-frequency        : Factor w/ 180 levels "-0.209261973376842",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-meanfreq-y-frequency        : Factor w/ 180 levels "-0.386237143210526",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-meanfreq-z-frequency        : Factor w/ 180 levels "-0.185530281244211",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-mean-x-frequency                         : Factor w/ 180 levels "-0.339032197115789",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-mean-y-frequency                         : Factor w/ 180 levels "-0.103059416434737",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-mean-z-frequency                         : Factor w/ 180 levels "-0.255940940315789",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-std-x-frequency                          : Factor w/ 180 levels "-0.516691938736842",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-std-y-frequency                          : Factor w/ 180 levels "-0.0335081597884211",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-std-z-frequency                          : Factor w/ 180 levels "-0.436562227473684",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-meanfreq-x-frequency                     : Factor w/ 180 levels "0.0147844986621053",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-meanfreq-y-frequency                     : Factor w/ 180 levels "-0.0657746190010526",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-meanfreq-z-frequency                     : Factor w/ 180 levels "0.00077332156431579",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-magnitude-mean-frequency         : Factor w/ 180 levels "-0.128623450629474",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-magnitude-std-frequency          : Factor w/ 180 levels "-0.398032586842105",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-magnitude-meanfreq-frequency     : Factor w/ 180 levels "0.1906437244",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-magnitude-mean-frequency    : Factor w/ 180 levels "-0.0571194000343158",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-magnitude-std-frequency     : Factor w/ 180 levels "-0.103492403002105",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-acceleration-jerk-magnitude-meanfreq-frequency: Factor w/ 180 levels "0.0938221807027368",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-magnitude-mean-frequency                 : Factor w/ 180 levels "-0.199252568986316",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-magnitude-std-frequency                  : Factor w/ 180 levels "-0.321017953894737",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-magnitude-meanfreq-frequency             : Factor w/ 180 levels "0.268844367525895",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-jerk-magnitude-mean-frequency            : Factor w/ 180 levels "-0.319308593778947",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-jerk-magnitude-std-frequency             : Factor w/ 180 levels "-0.381601911789474",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ body-gyro-jerk-magnitude-meanfreq-frequency        : Factor w/ 180 levels "0.190663448793684",..: 1 2 3 4 5 6 7 8 9 10 ...
```


Variable list and descriptions
------------------------------

Variable name                                       | Description
----------------------------------------------------|----------------------------------------------------
subject                                             | ID of the subject who performed the activity for each window sample. Its range is from 1 to 30.
activity                                            | Activity name (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING)
body-acceleration-mean-x-time                       | Average of Mean Value of Time domain Body Acceleration in X direction
body-acceleration-mean-y-time                       | Average of Mean Value of Time domain Body Acceleration in Y direction
body-acceleration-mean-z-time                       | Average of Mean Value of Time domain Body Acceleration in Z direction
body-acceleration-std-x-time                        | Average of Standard Deviation of Time domain Body Acceleration in X direction
body-acceleration-std-y-time                        | Average of Standard Deviation of Time domain Body Acceleration in Y direction
body-acceleration-std-z-time                        | Average of Standard Deviation of Time domain Body Acceleration in Z direction
gravity-acceleration-mean-x-time                    | Average of Mean Value of Time domain Gravity Acceleration in X direction
gravity-acceleration-mean-y-time                    | Average of Mean Value of Time domain Gravity Acceleration in Y direction
gravity-acceleration-mean-z-time                    | Average of Mean Value of Time domain Gravity Acceleration in Z direction
gravity-acceleration-std-x-time                     | Average of Standard Deviation of Time domain Gravity Acceleration in X direction
gravity-acceleration-std-y-time                     | Average of Standard Deviation of Time domain Gravity Acceleration in Y direction
gravity-acceleration-std-z-time                     | Average of Standard Deviation of Time domain Gravity Acceleration in Z direction
body-acceleration-jerk-mean-x-time                  | Average of Mean Value of Time domain Body Acceleration Jerk signal in X direction
body-acceleration-jerk-mean-y-time                  | Average of Mean Value of Time domain Body Acceleration Jerk signal in Y direction
body-acceleration-jerk-mean-z-time                  | Average of Mean Value of Time domain Body Acceleration Jerk signal in Z direction
body-acceleration-jerk-std-x-time                   | Average of Standard Deviation of Time domain Body Acceleration Jerk signal in X direction
body-acceleration-jerk-std-y-time                   | Average of Standard Deviation of Time domain Body Acceleration Jerk signal in Y direction
body-acceleration-jerk-std-z-time                   | Average of Standard Deviation of Time domain Body Acceleration Jerk signal in Z direction
body-gyro-mean-x-time                               | Average of Mean Value of Time domain Body Gyroscope in X direction
body-gyro-mean-y-time                               | Average of Mean Value of Time domain Body Gyroscope in Y direction
body-gyro-mean-z-time                               | Average of Mean Value of Time domain Body Gyroscope in Z direction
body-gyro-std-x-time                                | Average of Standard Deviation of Time domain Body Gyroscope in X direction
body-gyro-std-y-time                                | Average of Standard Deviation of Time domain Body Gyroscope in Y direction
body-gyro-std-z-time                                | Average of Standard Deviation of Time domain Body Gyroscope in Z direction
body-gyro-jerk-mean-x-time                          | Average of Mean Value of Time domain Body Gyroscope Jerk signal in X direction
body-gyro-jerk-mean-y-time                          | Average of Mean Value of Time domain Body Gyroscope Jerk signal in Y direction
body-gyro-jerk-mean-z-time                          | Average of Mean Value of Time domain Body Gyroscope Jerk signal in Z direction
body-gyro-jerk-std-x-time                           | Average of Standard Deviation of Time domain Body Gyroscope Jerk signal in X direction
body-gyro-jerk-std-y-time                           | Average of Standard Deviation of Time domain Body Gyroscope Jerk signal in Y direction
body-gyro-jerk-std-z-time                           | Average of Standard Deviation of Time domain Body Gyroscope Jerk signal in Z direction
body-acceleration-magnitude-mean-time               | Average of Mean Value of Time domain Body Acceleration Magnitude
body-acceleration-magnitude-std-time                | Average of Standard Deviation of Time domain Body Acceleration Magnitude
gravity-acceleration-magnitude-mean-time            | Average of Mean Value of Time domain Gravity Acceleration Magnitude
gravity-acceleration-magnitude-std-time             | Average of Standard Deviation of Time domain Gravity Acceleration Magnitude
body-acceleration-jerk-magnitude-mean-time          | Average of Mean Value of Time domain Body Acceleration Magnitude Jerk Signal
body-acceleration-jerk-magnitude-std-time           | Average of Standard Deviation of Time domain Body Acceleration Magnitude Jerk Signal
body-gyro-magnitude-mean-time                       | Average of Mean Value of Time domain Body Gyroscope Magnitude
body-gyro-magnitude-std-time                        | Average of Standard Deviation of Time domain Body Gyroscope Magnitude
body-gyro-jerk-magnitude-mean-time                  | Average of Mean Value of Time domain Body Gyroscope Magnitude Jerk Signal
body-gyro-jerk-magnitude-std-time                   | Average of Standard Deviation of Time domain Body Gyroscope Magnitude Jerk Signal
body-acceleration-mean-x-frequency                  | Average of Mean Value of Frequency domain Body Acceleration in X direction
body-acceleration-mean-y-frequency                  | Average of Mean Value of Frequency domain Body Acceleration in Y direction
body-acceleration-mean-z-frequency                  | Average of Mean Value of Frequency domain Body Acceleration in Z direction
body-acceleration-std-x-frequency                   | Average of Standard Deviation of Frequency domain Body Acceleration in X direction
body-acceleration-std-y-frequency                   | Average of Standard Deviation of Frequency domain Body Acceleration in Y direction
body-acceleration-std-z-frequency                   | Average of Standard Deviation of Frequency domain Body Acceleration in Z direction
body-acceleration-meanfreq-x-frequency              | Average of Mean Value of Mean Frequency domain Body Acceleration in X direction
body-acceleration-meanfreq-y-frequency              | Average of Mean Value of Mean Frequency domain Body Acceleration in Y direction
body-acceleration-meanfreq-z-frequency              | Average of Mean Value of Mean Frequency domain Body Acceleration in Z direction
body-acceleration-jerk-mean-x-frequency             | Average of Mean Value of Frequency domain Body Acceleration Jerk Signal in X direction
body-acceleration-jerk-mean-y-frequency             | Average of Mean Value of Frequency domain Body Acceleration Jerk Signal in Y direction
body-acceleration-jerk-mean-z-frequency             | Average of Mean Value of Frequency domain Body Acceleration Jerk Signal in Z direction
body-acceleration-jerk-std-x-frequency              | Average of Standard Deviation of Frequency domain Body Acceleration Jerk Signal in X direction
body-acceleration-jerk-std-y-frequency              | Average of Standard Deviation of Frequency domain Body Acceleration Jerk Signal in Y direction
body-acceleration-jerk-std-z-frequency              | Average of Standard Deviation of Frequency domain Body Acceleration Jerk Signal in Z direction
body-acceleration-jerk-meanfreq-x-frequency         | Average of Mean Value of Mean Frequency domain Body Acceleration Jerk Signal in X direction
body-acceleration-jerk-meanfreq-y-frequency         | Average of Mean Value of Mean Frequency domain Body Acceleration Jerk Signal in Y direction
body-acceleration-jerk-meanfreq-z-frequency         | Average of Mean Value of Mean Frequency domain Body Acceleration Jerk Signal in Z direction
body-gyro-mean-x-frequency                          | Average of Mean Value of Frequency domain Body Gyroscope in X direction
body-gyro-mean-y-frequency                          | Average of Mean Value of Frequency domain Body Gyroscope in Y direction
body-gyro-mean-z-frequency                          | Average of Mean Value of Frequency domain Body Gyroscope in Z direction
body-gyro-std-x-frequency                           | Average of Standard Deviation of Frequency domain Body Gyroscope in X direction
body-gyro-std-y-frequency                           | Average of Standard Deviation of Frequency domain Body Gyroscope in Y direction
body-gyro-std-z-frequency                           | Average of Standard Deviation of Frequency domain Body Gyroscope in Z direction
body-gyro-meanfreq-x-frequency                      | Average of Mean Value of Mean Frequency domain Body Gyroscope in X direction
body-gyro-meanfreq-y-frequency                      | Average of Mean Value of Mean Frequency domain Body Gyroscope in Y direction
body-gyro-meanfreq-z-frequency                      | Average of Mean Value of Mean Frequency domain Body Gyroscope in Z direction
body-acceleration-magnitude-mean-frequency          | Average of Mean Value of Frequency domain Body Acceleration Magnitude
body-acceleration-magnitude-std-frequency           | Average of Standard Deviation of Frequency domain Body Acceleration Magnitude
body-acceleration-magnitude-meanfreq-frequency      | Average of Mean Value of Mean Frequency domain Body Acceleration Magnitude
body-acceleration-jerk-magnitude-mean-frequency     | Average of Mean Value of Frequency domain Body Acceleration Magnitude Jerk Signal
body-acceleration-jerk-magnitude-std-frequency      | Average of Standard Deviation of Frequency domain Body Acceleration Magnitude Jerk Signal
body-acceleration-jerk-magnitude-meanfreq-frequency | Average of Mean Value of Mean Frequency domain Body Acceleration Magnitude Jerk Signal
body-gyro-magnitude-mean-frequency                  | Average of Mean Value of Frequency domain Body Gyroscope Magnitude
body-gyro-magnitude-std-frequency                   | Average of Standard Deviation of Frequency domain Body Gyroscope Magnitude
body-gyro-magnitude-meanfreq-frequency              | Average of Mean Value of Mean Frequency domain Body Gyroscope Magnitude
body-gyro-jerk-magnitude-mean-frequency             | Average of Mean Value of Frequency domain Body Gyroscope Magnitude Jerk Signal
body-gyro-jerk-magnitude-std-frequency              | Average of Standard Deviation of Frequency domain Body Gyroscope Magnitude Jerk Signal
body-gyro-jerk-magnitude-meanfreq-frequency         | Average of Mean Value of Mean Frequency domain Body Gyroscope Magnitude Jerk Signal