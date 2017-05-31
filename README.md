---
### Getting and Cleaning Data Course Project

One of the most exciting areas in all of data science right now is wearable computing. Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users.

The purpose of this project is to demonstrate an ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. 

---
### Human Activity Recognition Using Smartphones Data Set 

Human Activity Recognition database built from the recordings of 30 subjects performing activities of daily living (ADL) while carrying a waist-mounted smartphone with embedded inertial sensors.

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (*WALKING*, *WALKING_UPSTAIRS*, *WALKING_DOWNSTAIRS*, *SITTING*, *STANDING*, *LAYING*) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

A video of the experiment including an example of the 6 recorded activities with one of the participants can be seen in the following [link.](http://www.youtube.com/watch?v=XOEN9W05_4A)

A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Data for analysis is downloaded from the below URL
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

---
### run_analysis.R

This is the main script to perform the cleaning and tidying of the data set as described in the excercise. It does the following:

0. Downloads the data for analysis and unzips the archive.
1. Merges the training set `trainingtData` and the test set `testData` to create one data set `mergedDataset`.
2. Extracts only the measurements on the mean `mean()` and standard deviation `std()` for each measurement.
3. Uses descriptive activity names to name the activities in the data set.
4. Appropriately labels the data set with descriptive variable names from.
5. From the data set in step 4, creates a second, independent tidy data set `tidyDataset` with the average of each variable for each activity and each subject.

The script saves the tidy data set of `180` observations and `81` columns (`2` columns for `subject` and `activity` and `79` columns for measurement variables) to a text file called `tidydataset.txt`.

---
### Running the script

To run the script, you need to download the script and load it into R from your working directory. 
You should call `runAnalysis` function, which performs all the steps listed above.

```source('run_analysis.R')```

```runAnalysis()  ```

---
### Files included in the repository

This repository includes the following files:

```runAnalysis.R```
R script which performs the cleaning and tidying of the data set.

```CodeBook.md  ```
The Code Book.

```README.md ```
ReadMe file.

```tidydataset.txt```
Tidy data set for submission.

```/rawdata/UCI HAR Dataset```
Human Activity Recognition Using Smartphones Data Set.