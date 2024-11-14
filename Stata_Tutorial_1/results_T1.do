/*----------------------------------------------------------

Stata Tutorial - Section 1 INTRODUCTION & DATA MANAGEMENT

RESULTS EX.1

----------------------------------------------------------*/ 

/* Using the dataset auto.dta, do/answer to the following points. 

	1. Report size of data matrix: n. of observations and n. of variables and identify which variable uniquely identifies each observation 
	2. Focus only on cars with a mileage (miles per liter) below 25 
	3. What is the average price of the cars in the sample? And the extreme values?
	3b. What is the average price if we restrict the sample to domestic cars with a gear ratio below 3
	4. How many foreign cars?
	5. Create a variable named "size" that multiplies length * weight and assign a consistent label to it
	6. Express the price in logarithm 
	7. Generate a variable "average_price_rep78" that foreach level of rep78 (group) reports the maximum price
	8. Generate a string variable to identify if a car id "foreigner" or "domestic"
	9. Save dataset as a csv file "auto_excercise1.csv"
	
*/

*** Results: 

* 1.
clear all
use auto.dta
describe // 67 observations, 12 variables 
br 
isid make // "make" (labelled "Make and Model") is the unique identifier 
* 2.
keep if mpg<25
* 3.
summarize price // mean price is 6504. Min price is 3291 and Max price is 15906
* 3b.
summarize price if foreign==0 & gear_ratio<3 // Mean is 3440.897, Min 3667 and Max 15906
* 4. 
tab foreign // 8 cars,  15.38% 
* 5. 
gen size = length*weight
label variable size "Car's dimension"
* 6. 
gen log_price = log(price)
list price log_price in 1/10
* 7. 
bys rep78: egen average_price_rep78 = max(price)
bys rep78: sum average_price_rep78
label variable average_price_rep78 "Max price per group" 
* 8. 
tostring foreign, gen(foreign_string)
replace foreign_string = "Foreign" if foreign_string=="1"
replace foreign_string = "Domestic" if foreign_string=="0"
* 9. 
export delimited "auto_excercise1.csv", delimiter(",") replace