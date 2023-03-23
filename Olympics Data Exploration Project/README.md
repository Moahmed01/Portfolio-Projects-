# Olympics Data Exploration Project (in progress)
This project explores historical dataset on the modern Olympic Games, including all the Games from Athens 1896 to Rio 2016. Python queries are executed to answer questions and look at trends over the course of 120 years of olympics games

# The Data
The dataset is from [Kaggle](https://www.kaggle.com/datasets/heesoo37/120-years-of-olympic-history-athletes-and-results?resource=download). It has data from 1896 to Rio 2016.

# Dataset Features
| Attribute | Definition | Data Type |
| ----- | ----- | ----- |
| ID | Athletes unique number| int64 |
| Name | Athletes name | object |
| Sex | Athletes gender M = Male, F = Female | object |
| Age | Athletes age | float64 |
| Height | Athletes height in centimeters | float64 |
| Weight | Athletes weight in kilograms | float64 |
| Team | Athletes team name | object |
| NOC | National Olympic Committee 3 letter code | object |
| Games | Year and season | object |
| Year | Year the games took place | int64 |
| Season | Summer or Winter games | object |
| City | Host city | object |
| Sport | Sport played | object |
| Event | Specific event in the sport | object |
| Medal | What medal the athlete received if any| object |
| Sex_Male | 1 = Athlete is male, 0 = Athlete is female | int64 |
| medalist | 1 = Athlete received a medal, 0 = Athlete received no medal | int64 |
| BMI | Athletes Body Mass Index | float64 |
| AgeBins | Athletes age binned by every 10 years | category |
