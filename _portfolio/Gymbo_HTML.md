---
title: "GyMBo: A Gym Monitoring Robot"
excerpt: "A bot capable of predicting future gym usage."
collection: portfolio
---






The following is a hobby project that turned into a class assignment, which earned me a class mark of 100%.  Pretty proud of that one.  Want to see the code?  Check out the R notebook on my [Github](https://github.com/Dpananos/GymBo)!


## Introduction

No one likes a crowded gym, so information about gym usage is essential for patrons.  Fortunately, Western's Rec Centre [tweets out how many students are currently in the weight room and cardio mezzanine](https://twitter.com/WesternWeightRm?lang=en) throughout the day.  Though useful to instantaneously get an estimate of usage, the tweets hold no predictive power.  A predictive model of gym usage would be valuable to students wanting to plan a workout as well as gym management looking to effectively allocate labour. 


Generating a predictive model is a tall order, and so in this project we take only the first step.  Tweets are scraped from the gym's twitter account and temporal trends are examined to attempt to understand how the gym is being used over time.  Feature engineering for time series machine learning is also performed with the aid of the `timetk` library.  A modest model is created using linear regression and turned into a tweeting robot. For now, we'll focus on data pertaining to the weight room as a proof of concept.

## Obtaining and Extracting Usage 

The Western Rec Centre operates a twitter account which periodically tweets out how many students are in the weight room and cardio mezzanine.  Recent tweets are easily accessed through the `twitteR` library.  A set of keys is required to access the API.  Once keys are obtained, the last 3200 tweets from any given account are available to users.  The API returns various metadata about the tweets made.  Of particular interest are the tweet text, the date created, and the unique id assigned to the tweet (this will become valuable for storing tweets in a sqlite database for posterity). 

The tweets are in english and though while consistent, may not always be in a dependable format. Using the library `stringr`, a heuristic is followed to determine the number of students in the weight room.  The twitter account usually uses 'WR' to indicate 'Weight Room', so the script will parse the tweets for the occurrence of 'WR' in the tweet.  If 'WR' is in the tweet (accounting for capitalization, puncuation, etc), then the script will extract the largest integer present in the tweet and use this as the number of students in the weight room (the weight room usually has more patrons than the cardio mezzanine.  This is the heuristic).  If neither an integer nor 'WR' appear in the script, -1 is returned.  This data is written to a sqlite database with the unique identifier used as the primary key.  The table shown below is a sample of what the database contains.





<table class="table" style="margin-left: auto; margin-right: auto;">
<thead><tr>
<th style="text-align:left;"> id </th>
   <th style="text-align:left;"> created </th>
   <th style="text-align:left;"> text </th>
   <th style="text-align:right;"> WR </th>
  </tr></thead>
<tbody>
<tr>
<td style="text-align:left;"> 924416733640888320 </td>
   <td style="text-align:left;"> 2017-10-28 19:24:58 </td>
   <td style="text-align:left;"> WR 65 CM 16 </td>
   <td style="text-align:right;"> 65 </td>
  </tr>
<tr>
<td style="text-align:left;"> 924409455080607745 </td>
   <td style="text-align:left;"> 2017-10-28 18:56:03 </td>
   <td style="text-align:left;"> WR 86 CM 19 </td>
   <td style="text-align:right;"> 86 </td>
  </tr>
<tr>
<td style="text-align:left;"> 924397559849848833 </td>
   <td style="text-align:left;"> 2017-10-28 18:08:47 </td>
   <td style="text-align:left;"> WR 102 CM 27 </td>
   <td style="text-align:right;"> 102 </td>
  </tr>
<tr>
<td style="text-align:left;"> 924380444614909953 </td>
   <td style="text-align:left;"> 2017-10-28 17:00:46 </td>
   <td style="text-align:left;"> WR 122 CM 47 </td>
   <td style="text-align:right;"> 122 </td>
  </tr>
<tr>
<td style="text-align:left;"> 924373350629199872 </td>
   <td style="text-align:left;"> 2017-10-28 16:32:35 </td>
   <td style="text-align:left;"> 114 WR &amp;amp; 39 CM </td>
   <td style="text-align:right;"> 114 </td>
  </tr>
<tr>
<td style="text-align:left;"> 924366703332614145 </td>
   <td style="text-align:left;"> 2017-10-28 16:06:10 </td>
   <td style="text-align:left;"> 80 WR &amp;amp; 38 CM </td>
   <td style="text-align:right;"> 80 </td>
  </tr>
</tbody>
</table>


## Extracting Important Time Features

We are primarily interested in day to day changes in the number of students.  However, there may exist dynamics on the time scale of weeks, or months, that we would miss by only considering day to day or hour to hour trends.  For this reason, we leverage the use of `timetk` to extract other time information.  Doing so produces a dataframe with many columns, several of which are redundant.  Here, we choose just a few which we believe to be of particular importance to the problem.  In particular, we extract: weekday, day of year, month, week of month, week of year.  We also create features for time, date, if the day is a weekend, if the day has any particular significance (e.g. Homecoming or Holidays), and the number of days until the significant days end (for instance, the Saturday of Thanksgiving has a value of 3 since there are 3 days until school starts again).



<table class="table" style="margin-left: auto; margin-right: auto;">
<thead><tr>
<th style="text-align:right;"> WR </th>
   <th style="text-align:left;"> created </th>
   <th style="text-align:right;"> time </th>
   <th style="text-align:left;"> date </th>
   <th style="text-align:left;"> wday.lbl </th>
   <th style="text-align:right;"> yday </th>
   <th style="text-align:left;"> is.weekday </th>
   <th style="text-align:left;"> month.lbl </th>
   <th style="text-align:right;"> mweek </th>
   <th style="text-align:right;"> week </th>
   <th style="text-align:right;"> remaining </th>
   <th style="text-align:left;"> is.special </th>
  </tr></thead>
<tbody>
<tr>
<td style="text-align:right;"> 27 </td>
   <td style="text-align:left;"> 2017-09-08 06:30:18 </td>
   <td style="text-align:right;"> 6.500000 </td>
   <td style="text-align:left;"> 2017-09-08 </td>
   <td style="text-align:left;"> Friday </td>
   <td style="text-align:right;"> 251 </td>
   <td style="text-align:left;"> Yes </td>
   <td style="text-align:left;"> September </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 36 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> No </td>
  </tr>
<tr>
<td style="text-align:right;"> 37 </td>
   <td style="text-align:left;"> 2017-09-08 06:59:40 </td>
   <td style="text-align:right;"> 6.983333 </td>
   <td style="text-align:left;"> 2017-09-08 </td>
   <td style="text-align:left;"> Friday </td>
   <td style="text-align:right;"> 251 </td>
   <td style="text-align:left;"> Yes </td>
   <td style="text-align:left;"> September </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 36 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> No </td>
  </tr>
<tr>
<td style="text-align:right;"> 66 </td>
   <td style="text-align:left;"> 2017-09-08 07:30:14 </td>
   <td style="text-align:right;"> 7.500000 </td>
   <td style="text-align:left;"> 2017-09-08 </td>
   <td style="text-align:left;"> Friday </td>
   <td style="text-align:right;"> 251 </td>
   <td style="text-align:left;"> Yes </td>
   <td style="text-align:left;"> September </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 36 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> No </td>
  </tr>
<tr>
<td style="text-align:right;"> 70 </td>
   <td style="text-align:left;"> 2017-09-08 08:01:09 </td>
   <td style="text-align:right;"> 8.016667 </td>
   <td style="text-align:left;"> 2017-09-08 </td>
   <td style="text-align:left;"> Friday </td>
   <td style="text-align:right;"> 251 </td>
   <td style="text-align:left;"> Yes </td>
   <td style="text-align:left;"> September </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 36 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> No </td>
  </tr>
<tr>
<td style="text-align:right;"> 71 </td>
   <td style="text-align:left;"> 2017-09-08 09:02:18 </td>
   <td style="text-align:right;"> 9.033333 </td>
   <td style="text-align:left;"> 2017-09-08 </td>
   <td style="text-align:left;"> Friday </td>
   <td style="text-align:right;"> 251 </td>
   <td style="text-align:left;"> Yes </td>
   <td style="text-align:left;"> September </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 36 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> No </td>
  </tr>
<tr>
<td style="text-align:right;"> 69 </td>
   <td style="text-align:left;"> 2017-09-08 09:30:13 </td>
   <td style="text-align:right;"> 9.500000 </td>
   <td style="text-align:left;"> 2017-09-08 </td>
   <td style="text-align:left;"> Friday </td>
   <td style="text-align:right;"> 251 </td>
   <td style="text-align:left;"> Yes </td>
   <td style="text-align:left;"> September </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 36 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> No </td>
  </tr>
</tbody>
</table>


## Plots of Trends

The time features allow examination of usage trends at several granularities.  Examining the trends on a monthly level shows a clear change in students's behaviour as the semester progresses.  In September, the peak gym usage occurs somewhere between 5 PM and 7PM.  As the months progress, peak usage occurs later, somewhere around 8 PM.  

September seems to be the busiest month for the gym.  One possible explanation is that in this month, patrons are free of assignments and other responsibilities and may be free to go to the gym.  As the semester progresses, responsibilities pile, and they may be less inclined to go.  October sees the coming and passing of midterms as well as the fall reading break. This makes October the month with the least usage.  Granularity can be further increased to the level of weekday.  Monday sees the largest temporal shift in peak use from the evening to late night, where as the middle weekdays see no shift in temporal peek use.  Friday's 
temporal peak use regresses in October (likely due to exams) and then shifts to later in the evening in November.  Weekends see no drastic shifts in temporal peak use.


<img src="/images/portfolio/Gymbo/unnamed-chunk-5-1.png"  />


## Modelling Considerations

There are several considertions to be made before modelling the process can begin.  The first is that prediction for this specific problem is essentially a time series problem. However the times between observations are not uniformly spaced. The gym seems to try to tweet every thirty minutes, but on the rare occasion is delayed upwards of 50 minutes.  Observations could be rounded to the nearest hour or half hour in order to account for this. A summary statistic could also be chosen to be applied to all dates (e.g. the median), and this summary statistic could be forcasted through the use of time series methods.

The WR variable is highly autocorrelated and heteroskedastic.  The heteroskedasticity can be dealt with by applying a transformation to the data.  Shown in the figure below is a series of transformations one might apply, with the most effective transformation being the Box Cox Power Transformation.

Lastly, if time series are not to be used, a typical train/test split is not the best approach for obtaining cross validated predictive accuracy since the observations are not independant.  Instead, a "walk forward" validation may be more appropriate.  Such methods are implemented in most machine learning libraries, such as R's `caret`.

<img src="/images/portfolio/Gymbo/unnamed-chunk-6-1.png" />

## A Modest Attempt at Modelling

In this section, we take a very modest approach to predictive modelling using a linear model and the `caret` package.  Statistical inference may be effected by the correlation of the observations, and so we do not consider any coefficients or hypothesis tests.  Instead, performance is measured by cross validated predictive power, in particular the the MAE.

The final model only accounts for day of the week and time of day.  Shown below are some regression diagnostic plots.






<img src="/images/portfolio/Gymbo/unnamed-chunk-8-1.png" />







## Making Predictions

Making future predictions is impressively easy with `caret` and `timetk`.  Simply pass the time features into `timetk`'s function `tk_make_future_series` and the library will return an array with future observation times spaced by the mean difference in the observed times (in our case that is very close to half an hour, but just slightly larger.  We can round the times to the nearest half hour using lubridate).  Passing those times into the `tk_augment_timeseires_signature` function will return appropriate time features we used for modelling, and then a small mutate to include our unique features finishes the job.

Shown below is a plot of predictions for the next three days.
<img src="/images/portfolio/Gymbo//unnamed-chunk-9-1.png" />

## Conclusions, Discussion, and Next Steps

The model is far from ideal. The residuals from the regression exhibit correlation, are ever so slightly positvely skewed, and the model can not account for sudden drops in usage due to holidays, exams, etc.  Furthermore, time is not the only variable that is informative for gym usage.  Weather (either too hot or too cold, the probability of precipitation, etc) has an enormous impact on gym usage, but as of now no weather data has been captured.  Including data on month or if the day is "special" often results in zero variance features for most window lengths, and so the impact of these features are hard to estimate using the methods implemented for this particular model.  Information on class schedules may also be useful.  It could be the case that sporadic increases in gym usage are due to classes letting out, or that dips in usage are due to the start of large classes.  The impact of class scheduling is purely conjecture at this moment.



None the less, the model serves as an indicator of what gym usage possible could be, and is certainly better than instantaneously guessing what gym usage will be like in the coming hours.  The model has been implemented as a twitter account and tweets out predictions each day approximately every hour.  Since the tweets are made automatically, this qualifies the account as a "bot".  This bot is named **GyMbo** (a homonym of the male name Jimbo and portmanteau of Gym Monitoring Robot) and is implemented in python.  Readers can follow the bot at @WesternGymBot.


