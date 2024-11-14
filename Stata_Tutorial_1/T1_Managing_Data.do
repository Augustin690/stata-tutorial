/*----------------------------------------------------------

Stata Tutorial - Section 1 INTRODUCTION & DATA MANAGEMENT

Created by Chiara Belletti 20/02/2023

----------------------------------------------------------*/ 

********************************************************************************
*************************** GETTING STARTED WITH STATA *************************
********************************************************************************

* Stata interface has four main components, showing: 
  * The commands
  * The results 
  * The working history
  * The variables window

* You can type your code directly in "Command" window (one by one) but it's better to write all the scripts in a unique notebook named "dofile"
	*To run the commands from your dofile, click "Do" 

* You can add comments as line of codes in your dofiles by using * text 
* You can add text in the same line of a code using //text or /* text */

* Use the code "help", to access the STATA guide. "help" followed by a specific command, will open the documentation on that specific command, e.g. "help regress" 

********************************************************************************
************************************** SET UP **********************************
********************************************************************************

clear all /*To clear from memory everything you have done before*/

set more off // To prevent Stata to pause if the output exceeds the height of the console window, so that all the output will be displayed without interruption

* Set up a directory: 
	cd "C:/Users/belletti/Dropbox/PhD_Material/Teaching/MODS206_2023/2023/Tutorials/Stata_Tutorial_1" // To set current directory (where you want to store your results, save your data, etc.). When you call a file from the directory you won't need to specify all the path 

	pwd // Print current (working) directory

	dir // Reports a summary of which files are stored in the directory

* Log file (save the codes and the output they produced during a Stata session):
	capture log close // To close old log files, if opened
	log using "log_tutorial1", replace 

* To install a new package, you can: 
 * 1. Research the package using: 
   search mdesc
 * 2. Download it
   ssc install mdesc // Install the package mdesc (to tabulate prevalence of missing values) 

********************************************************************************
*********************************** IMPORT DATA ********************************
********************************************************************************

* You may want to upload data from different sources or with different formats: 

	* If the file it is stored on your computer and in a dta format:
    use auto.dta, clear // If the file is stored in the directory, you can call it simply by its name
	
	* To import excel dataset:
	import excel "auto.xls", clear
		
	* To import csv files:
	import delimited "auto.csv", clear
	
********************************************************************************
************************************ EXPLORE DATA ******************************
********************************************************************************

use Earnings_and_Height.dta, clear // To upload the dataset for the first part of this tutorial

* Describe and visualize matrix: 
describe // "describe" reports the dataset size (n. variables and observations), type of variables, etc.

/*
Data Storage Types
string: words ("between quotas")
numbers - integers: byte, int, long (according to how big the number)
numbers - real: float, double (according to the digits of accuracy)
*/

browse // To visualize the data matrix (shortcut "br") 

* Sort variables in the matrix 
	sort earnings  // To sort dataset by earning level, ascending order is standard
	br
	* gsort +earnings // Same of above
	
	gsort -earnings // "gsort -" sorts dataset in descending order
	br
	
	gsort -earnings +age +region // To sort by different criteria at the same time
	br
	
* Unique identifier
generate identifier =_n // To generate a unique identifier for each row. _n stands for the current number of the observation, while _N for the total number of observations

isid identifier // If the code "isid" does not report an error, it means that the variable chosen is a unique identifier of each row
*isid region // Region is not a unique identifier of each observation

* Describe and summarize variables
codebook // To describe data contents, it prints complete report 

codebook educ 

summarize educ // To report the main distribution moments of one or more variable in a synthetic way (you can also only type "sum")

sum educ, detail // To have more more details about variables distrbution

tabulate cworker, missing // "Tabulate" (tab) reports freqency by category/group
mdesc cworker // To verify if there are missing values

tab cworker sex

bysort sex: summarize earnings // To summarize a varible by group (same results with code below:)

* Conditional operations in Stata ( the "if" option) 
	summarize educ if sex==0 
	summarize educ if sex==1 

	* More than one condition
	summarize educ if age>50 & cworker!=6  // "!=" means "different" 

	tab region 
	summarize educ if region==1 | region==2 // Vertical bar means "or" 
	summarize educ if region>=3
	
**** Try to find the mean of some other groups, if you like!

* We can use macros to faciliate repeated operations: 

	 * "global" is a macro that is accessible within a Stata session
	 global mylist educ earnings // The first element, after command "global", is the name of the global
	 summarize $mylist if sex==0 // To call global use $

		/*
	 * "local" tells Stata to keep everything in the command line in memory only until do-file ends
	 local mylist "educ earnings" /* The first element, after command "local", is the name of the global */
	 summarize `mylist' if sex==0 // To call a local use `' 
		*/

********************************************************************************
********************************** PROCESSING DATA *****************************
********************************************************************************

* You can create a new variable using "gen" for simple functions or "egen" for more complex ones:
	generate weight_kg = weight*0.45359237 
	list weight weight_kg in 1/10
	label variable weight_kg "Weight in kg" //Labelling variable is a good practice (e.g. for clearer graphs)

	gen ln_weight = log(weight_kg)
	label variable ln_weight "Earnings Log"

* For more complicated functions, use "egen":
	* Max value of a variable:
	egen max_earning  = max(earning) 
	label variable max_earning "Maximum earning in the sample"
	br earning max_earning

	* Mean value of a variable:
	egen avg_educ  = mean(educ) 
	label variable avg_educ "Average level of educ. in the sample"

	* Mean by group: 
	tab mrd
	bys mrd: egen avg_educ_mrd = mean(educ) 
	br mrd avg_educ_mrd
	
	/* There are several other possibilities
	e.g. 
	egen newvar = rowmax(length weight) // To take the maximum value between the two variables for the same observation
	list length weight newvar */

* You can create a set of dummies from a categorical variable: 
	tabulate mrd, generate(dum_marital)
	list mrd dum_marital* in 1/10

* Other than labelling variables, you could label varibales' values:
	tab mrd
	tab mrd, nolabel
	* Create label:
	label define mrd_lab 1 "Married" 2 "Married" 3 "Formerly Married" 4 "Formerly Married" 5 "Formerly Married" 6 "Not Married"
	* Attach label to values:
	label values mrd mrd_lab
	tab mrd
	
* Create a dummy:
	generate below_13590_new = (earnings<13590)
	label variable below_13590 "Below poverty line" 
	tab below_13590_new
	
**** If you want, try to assign a label also to the variable values!

* Stata has several commands to modify data (variable names, variables' values, ...):

	* Rename the entire variable: 
    rename below_13590_new below_13590_2

	* Replace a variable's value with "replace" or "recode":
    replace below_13590_2=1 if earnings==13590 // To replace the values of some variables, when some conditions are met 
   
	* Recode values of a variable and generate a categorical variable
	sum earnings, d
    recode earnings (1/ 23363=1) ( 23364 / 84054=2) (84054/84055=3), generate(earnings_cat) 
    tab earnings_cat 

* Change the format of variable:
	* From numeric to string (textual)
    tostring earnings_cat, replace // For the opposite approach, use code "destring" 
	replace earnings_cat="1st group" if earnings_cat=="1" // To call a string use "text"
	replace earnings_cat="2nd and 3rd group" if (earnings_cat=="2" | earnings_cat=="3")
	tab earnings_cat
	

********************************************************************************
********************************** SELECTING DATA ******************************
********************************************************************************

* Drop variables and observations permanently or temporarily (add preserve - restore):
	* To drop column (variable), use "drop". Alternatively, use "keep" for the variables you want to mantain 
    drop height race

	* To drop rows (observations):
    preserve 
    keep if region!= 4 // Temporarily get rid of all the observations for region: West
	*keep in 1/10 // Other possibility: keep only observations from 1 to 10 
    restore 
   
/*
* Loops (repeated operations): 
   foreach var of varlist educ age {
   replace `var'= . if `var'> 20
   } 
*/
   

********************************************************************************
**************************** SAVING and COMBINING DATASET **********************
********************************************************************************

* Save your modified dataset: 
compress // To reduce the size of your data set. It changes data storage type, if necessary

	* As dta:
	save "survey_1.dta", replace 
	
	* As excel:
    export excel "survey_1.xls", firstrow(variables) replace 
   
    * As csv file: 
    export delimited "survey_1.csv", delimiter(",") replace
	
* Let's now open the dataset we will use for the second part of the tutorial:
use auto.dta, clear

describe
    
* Combine different datasets together:
   
	* Append (combine vertically two datasets: same n. varibales, increased n. observations) 
	use added_auto, clear 
	describe
	append using "auto.dta"
	describe 
  
	* Merge combine horizontally two datasets: same n. onservations, increased n. of varaibles)
	use auto_discount, clear // 69 observations
	describe // same n. obs, but different n. of columns
	merge 1:1 make using auto.dta // One-to-one merge 
	
	* Alternative merging options m:1 (Many-to-One), 1:m (One-to-Many)
	* Carefull!: merge m:m should never be used (read the help file for more info).It generates random matches.In case of m:m situation, one should not use merge, but joinby
	* help merge
	
********************************************************************************
************************************ EXCERCISE *********************************
********************************************************************************
/* Using the dataset auto.dta, do/answer to the following points. 
For the results open the dofile "results_T1.do".

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

* Don't forget to close the log 
log close
