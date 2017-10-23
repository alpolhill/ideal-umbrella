test_set <- read.table("C:/Users/apolhill/DSc Local/X_test.txt")
test_labels <- read.table("C:/Users/apolhill/DSc Local/y_test.txt")
subject_test <- read.table("C:/Users/apolhill/DSc Local/subject_test.txt")
activity_labels <- read.table("C:/Users/apolhill/DSc Local/activity_labels.txt")
subject_train <- read.table("C:/Users/apolhill/DSc Local/subject_train.txt")
train_set <- read.table("C:/Users/apolhill/DSc Local/X_train.txt")
train_labels <- read.table("C:/Users/apolhill/DSc Local/y_train.txt")
features <- read.table("C:/Users/apolhill/DSc Local/features.txt")


library(tidyr)
library(tidyverse)

glimpse(test_set)

# clean up features column names
(
  # insert underscore at lower/Upper boundaries; sub underscores for periods, hyphens & commas; nix parens; lowercase everything
  features_snake <- str_replace_all(features$V2, c("([a-z])([A-Z])" = "\\1_\\2", "[,\\-\\.]" = "_", "[\\(\\)]" = "")) %>%
    str_to_lower()
)

## insert column names from features list
colnames(test_set) <- features_snake

## change test_labels to actual names
library(stringr)

test_labels$V1 <- as.character(test_labels$V1)
plyr::revalue(test_labels$V1, c("1" = "walking",
                                "2" = "upstairs",
                                "3" = "downstairs",
                                "4" = "sitting",
                                "5" = "standing",
                                "6" = "laying"
)) -> test_labels$V1

## rename column name in test_labels

colnames(test_labels) <- c("activity")

## insert activity to test_set
test_set$activity <- test_labels$activity


## add subject to test_set

glimpse(subject_test)
colnames(subject_test) <- c("subject")
test_set$subject <- subject_test$subject



##REPEAT FOR TRAIN SET

## insert column names from features list
colnames(train_set) <- features_snake

## change train_labels to actual names
glimpse(train_labels)
train_labels$V1 <- as.character(train_labels$V1)
plyr::revalue(train_labels$V1, c("1" = "walking",
                                "2" = "upstairs",
                                "3" = "downstairs",
                                "4" = "sitting",
                                "5" = "standing",
                                "6" = "laying"
)) -> train_labels$V1

## rename column name in train_labels

colnames(train_labels) <- c("activity")

## insert activity to train_set
train_set$activity <- train_labels$activity

## add subject to train_set

glimpse(subject_train)
colnames(subject_train) <- c("subject")
train_set$subject <- subject_train$subject
glimpse(train_set)

## get rid of duplicate columns from each set

test_set2 <- test_set[-c(317:344, 396:423, 475:502)]
train_set2 <- train_set[-c(317:344, 396:423, 475:502)] 

## select mean and std deviation from each set

test_set3 <- select(test_set2, subject, activity, contains("mean"), contains("std"))
train_set3 <- select(train_set2, subject, activity, contains("mean"), contains("std"))

## join tables

total_set <- full_join(test_set3, train_set3)
glimpse(total_set)

## find mean by subject and activity

total_set1 <- total_set %>%
  group_by(subject, activity) %>%
  summarize_all(mean)
View(total_set1)

## print data to txt file
?write.table
path <- getwd()
write.table(total_set1, file.path(path, 'tidy.txt'), row.names=FALSE)
