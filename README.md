Getting and cleaning data project
========================================================

This document describes how works the script run_analysis.R.


It is assumed that the data is in my working directory and the working directory
is changed to it.


The first thing you do is read the training data and test as well as the names 
of the variables and labels of activities.

In the first step, the training data bind with test data and then subjects the 
measurements and the activities come together to create the total data set.


Then, in the second step, the columns are renamed and step two is only 
selected variables containing stockings.


In the third step the activities are labeled.


In the fourth step the names of the variables are cleaned to make them more readable.


In the fifth step, by data.table package, the means of each variable subject and activity are calculated.






