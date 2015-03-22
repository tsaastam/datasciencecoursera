# Requires the "plyr" package. Use 'install.packages("plyr")' to install it.
# Assumes the data is unzipped into a directory called "UCI HAR Dataset" under the current working dir.
# Writes out the summary into a file "summary.txt" under the current working dir.

library("plyr")

# read all data
print("Reading training data...")
xtrain <- read.table("UCI HAR Dataset/train/X_train.txt")
ytrain <- read.table("UCI HAR Dataset/train/y_train.txt")
subjecttrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
print("Reading test data...")
xtest <- read.table("UCI HAR Dataset/test/X_test.txt")
ytest <- read.table("UCI HAR Dataset/test/y_test.txt")
subjecttest <- read.table("UCI HAR Dataset/test/subject_test.txt")

# read feature names, activity labels
print("Reading feature names & activity labels...")
featurenames <- read.table("UCI HAR Dataset/features.txt")
activitylabels <- read.table("UCI HAR Dataset/activity_labels.txt")

# merge train & test data
print("Processing...")
xall <- rbind(xtest, xtrain)
yall <- rbind(ytest, ytrain)
subjectall <- rbind(subjecttest, subjecttrain)

# use feature names, activity labels to make all column names human-readable
names(xall) <- featurenames$V2
activityall <- data.frame(V1=yall, V2=factor(activitylabels$V2[1],levels=activitylabels$V2))
for(i in 1:length(activitylabels$V1)) {
    activityall$V2[activityall$V1 == activitylabels$V1[i]] <- activitylabels$V2[i]
}

# bind together all the things in a data frame
dfall <- data.frame(activity=activityall$V2, subject=subjectall$V1, xall)

# figure out which columns we want - only mean & stdev (i.e. containing "mean" or "std")
wantedcols <- featurenames[grepl("(std|mean)", featurenames$V2),]
wantedcolindex <- c(1, 2, wantedcols$V1 + 2) # activity, subject, the rest
dfwanted <- dfall[,wantedcolindex]

# summarise the things in the wanted-data frame
summary <- ddply(dfwanted, .(subject, activity), numcolwise(mean))
# and write out the result
print("Writing summary file...")
write.table(summary, file="summary.txt", row.name=FALSE)
print("Done! Summary should now be in the file 'summary.txt'")

# to read the summary file into R, you can use e.g. the following:
# mysummary <- read.table("summary.txt", header=TRUE)
