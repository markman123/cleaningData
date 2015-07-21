#Assignment 1 - Getting and Cleaning Data
This repo will hold the information in regards to the coursera course _Getting and Cleaning Data_ and Assignment 1 in particular.

The [CodeBook](CodeBook.md) holds the information on how the data was collected, and how it was analysed.


## Long vs. Skinny
I have opted for a skinny implementation of tidy data. If you have not seen the discussion, I encourage you view it [here](https://class.coursera.org/getdata-030/forum/thread?thread_id=107).

## My output
The average by subject & activity is in the following format:
| Column name | Data Type | Description |
| ---------- | ---------- | ----------- |
| SubjectNumber| Integer | The individual person (subject) |
| ActivityName | Factor | Factors for the activities: <br> * Laying <br> * Sitting <br> * Standing <br> * Walking <br> * Walking_Downstairs <br> * Walking_Upstairs |
| MeasurementName | Character | Contains the different measurements taken from the Samsung Galaxy |
| avg | numeric | Average for the subject / activity combination |