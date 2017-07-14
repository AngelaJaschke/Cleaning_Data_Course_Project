---
title: "Code Book: Getting and Cleaning Data Course Project"
output: html_document
---

## The Original Data

### Source
The data is downloaded from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip if the file does not exist yet, and is unzipped into the directory **data**.

### Loading
The data is loaded from the given files into several datasets:

* **test_vals** contains the measurements of the test set from "data/UCI HAR Dataset/test/X_test.txt"", i.e., 561 variables and 2947 observations (rows).

* **test_subs** contains the subject identifiers (range 1-30) for the test set from "data/UCI HAR Dataset/test/subject_test.txt" for each of the 2947 observations (rows).

* **test_labs** contains the subject identifiers (range 1-6) for the test set from "data/UCI HAR Dataset/test/y_test.txt" for each of the 2947 observations (rows).

* **train_vals** contains the measurements of the training set from "data/UCI HAR Dataset/train/X_train.txt"", i.e., 561 variables and 7352 observations (rows).

* **train_subs** contains the subject identifiers (range 1-30) for the training set from "data/UCI HAR Dataset/train/subject_train.txt" for each of the 7352 observations (rows).

* **train_labs** contains the subject identifiers (range 1-6) for the training set from "data/UCI HAR Dataset/train/y_train.txt" for each of the 7352 observations (rows).

* **labels** contains the labels from "data/UCI HAR Dataset/features.txt" for the 561 variables in the _vals datasets.

The variables in the **test_vals** and **train_vals** datasets are then renamed according to **labels**.


## Merge the two Datasets

For both test and training datasets, we use **cbind** to merge the **vals** dataframe with the activity labels and subject identifiers, which then constitute the last two columns (which we rename appropriately as **Subject** and **activity_nr**). The resulting dataframes, which contain all the information for training and testing set, respectively, are called **train** and **test**.

We then use **rbind** to merge the **train** and **test** dataframes, storing the result in **alldata**

Lastly, we delete the intermediate dataframes from above to free memory, keeping only **alldata** and **labels**.

## Extract Only Mean and Standard Deviation for Each Measurement

To extract only the measurements referring to the mean and standard deviation, we use in index vector **ids**. 

We first use **grep** to find all indices where the label contains the term "mean". 

We do the same for the term "std" and concatenate and sort the resulting index vector **ids**. 

We also add the last two columns of the dataframe (562 and 563) to the index vector because these contain **Subject** and **activity_nr** for each observation, and we need to keep this information. 

We then generate **cleaned_data**, which selects only the columns corresponding to the indices in **ids** from **alldata**.


## Make Activity Names Descriptive

We first read the labels corresponding to the numbers in **activity_nr** from "data/UCI HAR Dataset/activity_labels.txt" and store them in **act_labels**.

Next, we use **mutate** from the dplyr package to add a new column called **Activity** to **cleaned_data**, where we write the character description from **act_labels** that corresponds to the number in **activity_nr** for each row.

Lastly, we delete the old column **activity_nr** from **cleaned_data** via **select**.

## Label the Data Set with Descriptive Variable Names

We already named the variables according to the provided labels when we read them from the file, but we change the names via **gsub** in the following way:

* Remove "-", "(" and ")".

* Replace **t** at the beginning with **Time**.

* Replace **f** at the beginning with **Frequency**.

* Replace **Acc** with **Accelerometer**.

* Replace **Gyro** with **Gyroscope**.

* Replace **Mag** with **Magnitude**.

* Replace **mean** with **Mean**.

* Replace **std** with **Std**.

## Create a Second, Independent Tidy Data Set with the Average of Each Variable for Each Activity and Each Subject

We use a pipeline (the **%>%** operator) to first group **cleaned_data** by **Activity** and **Subject** via the dplyr command **group_by**. Next, we call **summarise_all** (which is a dplyr function similar to **summarize**, but applies the chosen function to all columns) with the function **mean**. 

We assign the result to the new data frame **tidy**, whcih we save to the file "tidy.txt" in a last step.










