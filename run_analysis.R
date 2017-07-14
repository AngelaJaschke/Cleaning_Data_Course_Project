library(dplyr)

#####################################################################################################
# Step 0: Download, unzip and load the data. 
#####################################################################################################

if(!file.exists("./data")){dir.create("./data")} # Check if the data directory exists

filename <- "data/Dataset.zip"
if (!file.exists(filename)){   #Check if file exists, if not download it
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL, filename, method="wininet", mode="wb")
} 

if (!file.exists("data/UCI HAR Dataset")) { # Unzip if file doesn't exist
        unzip(filename,exdir="./data") # unzip to data directory
}

# Read dataframes from the documents
test_vals<-read.table("data/UCI HAR Dataset/test/X_test.txt") #The 561 variables from the test set, 2947 observations (rows).
test_subs<-read.table("data/UCI HAR Dataset/test/subject_test.txt") # The subject (range 1-30) for each of the 2947 observations (rows).
test_labs<-read.table("data/UCI HAR Dataset/test/y_test.txt") # The activity (range 1-6) for each of the 2947 observations (rows).

train_vals<-read.table("data/UCI HAR Dataset/train/X_train.txt") #The 561 variables from the training set, 7352 observations (rows).
train_subs<-read.table("data/UCI HAR Dataset/train/subject_train.txt") # The subject (range 1-30) for each of the 7352 observations (rows).
train_labs<-read.table("data/UCI HAR Dataset/train/y_train.txt") # The activity (range 1-6) for each of the 7352 observations (rows).

labels<-read.table("data/UCI HAR Dataset/features.txt") # The labels for the observations.
colnames(test_vals)<-labels$V2 # Label the columns of test set data.
colnames(train_vals)<-labels$V2 # Label the columns of training set data.

#####################################################################################################
# Step 1: Merge the two datasets. Concretely, we will append the subject labels and activity labels to the measurements with cbind, then rowbind the two resulting datasets.
#####################################################################################################

test<-cbind(test_vals, test_subs[1])
test<-cbind(test, test_labs[1])
colnames(test)[562]<-"Subject"
colnames(test)[563]<-"activity_nr"

train<-cbind(train_vals, train_subs[1])
train<-cbind(train, train_labs[1])
colnames(train)[562]<-"Subject"
colnames(train)[563]<-"activity_nr"

alldata<-rbind(train,test) 

rm(test_labs,test_subs,test_vals,train_labs,train_subs,train_vals,train,test) # Remove original dataframes to free memory.

#####################################################################################################
# Step 2: Extract only the measurements on the mean and standard deviation for each measurement.
#####################################################################################################

ids<-grep("mean",labels$V2)
ids<-c(ids,grep("std",labels$V2))
ids<-sort(ids) # These are the relevant indices of the columns.
ids<-c(ids,562,563) # We want to keep the activity and subject labels.

cleaned_data<-alldata[ids] # Select only the data corresponding to the ids.
rm(alldata)

#####################################################################################################
# Step 3: Use descriptive activity names to name the activities in the data set
#####################################################################################################

act_labels<-read.table("data/UCI HAR Dataset/activity_labels.txt") # The labels for the activities.
cleaned_data<-mutate(cleaned_data, Activity = act_labels[activity_nr,2]) # Add a new column that assigns the right activity name.
cleaned_data<-select(cleaned_data,-activity_nr) # Delete the old column with the activity numnbers.

#####################################################################################################
# Step 4: Appropriately label the data set with descriptive variable names.
#####################################################################################################


# We already assigned names when we read the data in (lines 16/17). 
# We will, however, remove the brackets and hyphens from the names and substitute 
# abbreviations: t-> time, f->frequency, Acc->Accelerometer, Gyro->Gyroscope, Mag->Magnitude

names(cleaned_data)<-gsub("-","",names(cleaned_data))
names(cleaned_data)<-gsub("\\(","",names(cleaned_data))
names(cleaned_data)<-gsub("\\)","",names(cleaned_data))
names(cleaned_data)<-gsub("^t","Time",names(cleaned_data))
names(cleaned_data)<-gsub("^f","Frequency",names(cleaned_data))
names(cleaned_data)<-gsub("Acc","Accelerometer",names(cleaned_data))
names(cleaned_data)<-gsub("Gyro","Gyroscope",names(cleaned_data))
names(cleaned_data)<-gsub("Mag","Magnitude",names(cleaned_data))
names(cleaned_data)<-gsub("mean","Mean",names(cleaned_data))
names(cleaned_data)<-gsub("std","Std",names(cleaned_data))


#####################################################################################################
# Step 5: From the data set in step 4, create a second, independent tidy data set 
         #with the average of each variable for each activity and each subject.
#####################################################################################################

tidy<-cleaned_data %>% group_by(Activity,Subject) %>% summarise_all(funs(mean)) 
# summarise_all is like summarize, but does it for all columns simultaneously

# Save it to file
write.table(tidy, "tidy.txt", sep="\t", row.names = FALSE)
