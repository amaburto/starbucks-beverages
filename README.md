# starbucks-beverages
Title: "How much caffeine is in my Starbucks drink"
Author: "Alvaro Munoz"
Date: "01/09/2022"
Dataset: https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-12-21/starbucks.csv
Output: "starbucks_draw.png"
Libraries: tidyverse, cowplot, magick, stringr

Motivation: The tidytuesday contest released the Starbucks dataset in December for people to prepare visualizations. Because there were pretty good charts about this, I decided to follow along and prepare my own version.

My idea was to show the amount of caffeine for all Starbucks drinks, from the lowest to the highest concentration, in a circular way using a bar chart with a polar coordinate system. For that purpose I created an artificial scale to group drinks based on milligrams of caffeine:

0 mg - None
<= 100 mg - Low
<= 200 mg - Medium
<= 300 mg - High
Anything above - Intense

The outcome was a really neat chart grouping all the drinks in those 5 categories.
