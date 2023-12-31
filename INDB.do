
* Abbreviations
* FCT = food composition table
* NIN = National Institute of Nutrition (India)

********************************************************************************
*Clear settings
********************************************************************************
clear all
clear matrix
macro drop _all
graph drop _all


********************************************************************************
*Assign values using global macros for file location and date
********************************************************************************

*this is the location of the project @UPDATE
global location "C:\Users\Aswathy Vijayakumar\Desktop\Aswathy Files\Anuvaad Solutions India 2022\Indian Nutrient Database\November_2023"

*lindsay
global location "C:\Users\ljaacks\OneDrive - University of Edinburgh\Anuvaad\What India Eats\Indian Food Composition Database"

*this is the location of the data within the project
global data `"$location\Data"'

*this is where the output should go within the project
global output `"$location\Output"'

*this is where the log should go within the project
global log `"$location\Log"'

*this is the date @UPDATE
global date "20231229"

********************************************************************************
*Import Excel files and convert to Stata files
********************************************************************************

*NIN FCT 
import excel "$data\NIN_fct.xlsx", sheet("Sheet1") firstrow clear
sort food_code
save "$data\NIN_fct.dta", replace

*convert to numeric
local list energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg iron_mg sodium_mg zinc_mg folate_ug vita_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

foreach var1 of varlist `list' {
	replace `var1' = "0" if `var1' =="N" | `var1' =="Tr" | `var1' =="NA" 
 }

local list energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg iron_mg sodium_mg zinc_mg folate_ug vita_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

destring `list', replace

save "$data\NIN_fct.dta", replace

*UK FCT 
import excel "$data\UK_fct.xlsx", sheet("Sheet1") firstrow clear

*convert to numeric
local list energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg iron_mg sodium_mg zinc_mg folate_ug vita_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

foreach var1 of varlist `list' {
	replace `var1' = "0" if `var1' =="N" | `var1' =="Tr" | `var1' =="" 
 }

destring `list', replace
	
save "$data\UK_fct.dta", replace
		
*US FCT 
import excel "$data\US_fct.xlsx", sheet("Sheet1") firstrow clear

*drop empty rows from Excel
drop if food_name==""
	
*convert to numeric
local list freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg iron_mg sodium_mg zinc_mg folate_ug vita_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug 

foreach var1 of varlist `list' {
	replace `var1' = "0" if `var1' =="NA"
 }

local list energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg iron_mg sodium_mg zinc_mg folate_ug vita_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

destring `list', replace
	
save "$data\US_fct.dta", replace

*Recipe ingredients
import excel "$data\recipes.xlsx", sheet("Sheet1") firstrow clear
drop recipe_name
sort recipe_code
save "$data\recipes.dta", replace

*Recipe names
import excel "$data\recipes_names.xlsx", sheet("sheet1") firstrow clear
drop recipe_code_org recipe_name_org

*drop empty rows from Excel
drop if recipe_name==""
	
sort recipe_code
save "$data\recipes_names.dta", replace

*Serving size
import excel "$data\recipes_servingsize.xlsx", sheet("Sheet1") firstrow clear
sort recipe_code
save "$data\recipes_servingsize.dta", replace

*assign macros

*these are the original recipes to use
global recipes `"$data\recipes"'

*these are the recipe names to use
global names `"$data\recipes_names"'

*these are the recipe serving sizes to use
global servingsize `"$data\recipes_servingsize"'

********************************************************************************
*Add missing foods from UK FCT
********************************************************************************
use "$data\UK_fct.dta", clear
append using "$data\NIN_fct", force
save "$data\temp_fct", replace

********************************************************************************
*Add missing foods from US FCT
********************************************************************************
use "$data\US_fct.dta", clear
append using "$data\temp_fct", force
save "$data\temp_fct", replace

********************************************************************************
*Derive nutrients in recipes 
********************************************************************************
use "$recipes", clear

*split food code to enable easy identification of spices vs oils vs vegetables etc.
gen food_category = substr(food_code, 1, 1)

*convert all amounts to grams
*see information file 'units.xlxs' for assumptions

gen amount_g=.
replace amount_g=amount if unit=="g"
replace amount_g=amount*2 if unit=="tsp" & (food_category=="G" | food_category=="H" | food_category=="B" | food_category=="U") /*dry teaspoons*/
replace amount_g=amount*7 if unit=="tbsp" & (food_category=="D" | food_category=="G" | food_category=="H" | food_category=="B" | food_category=="U") /*dry tablespoons*/
replace amount_g=amount*2 if unit=="tsp" & food_category=="D" /*chillies*/
replace amount_g=amount*40 if unit=="tbsp" & food_category=="F" /*Potatoes*/
replace amount_g=amount*1 if unit=="ml" & (food_category=="G"| food_category=="H"|food_category=="I"|food_category=="V"| food_category=="X") /*vinegar, coconutmilk*/
replace amount_g=amount*2.5 if unit=="tsp" & (food_category=="A")
replace amount_g=amount*5 if unit=="tsp" & (food_category=="M")
replace amount_g=amount*7 if unit=="tbsp" & (food_category=="A")
replace amount_g=amount*2 if unit=="tsp" & (food_category=="V")
replace amount_g=amount*4 if unit=="tsp" & food_category=="T" /*oils, butter and ghee*/
replace amount_g=amount*13.5 if unit=="tbsp" & food_category=="T" /* oils, butter and ghee */
replace amount_g=amount*6 if unit=="tsp" & (food_category=="X"| food_category=="W") /*sauces such as soy and tomato*/
replace amount_g=amount*20 if unit=="tbsp" & (food_category=="X"| food_category=="W") /*sauces such as soy and tomato*/
replace amount_g=amount*4 if unit=="tsp" & food_category=="I" /*sugar*/
replace amount_g=amount*12 if unit=="tbsp" & food_category=="I" /*sugar */
replace amount_g=amount*200 if unit=="C" & food_category=="I" /*sugar */

replace amount_g=amount*15 if unit=="tbsp" & (food_category=="Z") /*bread crumbs*/

replace amount_g=amount*5 if unit=="tsp" & food_category=="L" /*ice cream/cream/curd/milk/ mayonnaise/cheese spread*/
replace amount_g=amount*15 if unit=="tbsp" & food_category=="L" /*ice cream/cream/curd/milk/ mayonnaise/cheese spread*/
replace amount_g=amount*240 if unit=="C" & food_category=="L" /*ice cream/cream/curd/milk/ mayonnaise/cheese spread*/
replace amount_g=amount*1 if unit=="ml" & food_category=="L" /*ice cream/cream/curd/milk/ mayonnaise/cheese spread*/

replace amount_g=amount*2 if unit=="sprig" & (food_category=="G" | food_category=="U"| food_category=="C"| food_category=="A") /*spices*/
replace amount_g=amount*0.5 if unit=="tsp" & (food_category=="C") /*spices*/
replace amount_g=amount*5 if unit=="tbsp" & (food_category=="C") /*spices*/
replace amount_g=amount*4 if unit=="tsp" & food_category=="T" /*oils*/
replace amount_g=amount*1 if unit=="ml" & food_category=="T" /*oils*/
replace amount_g=amount*240 if unit=="C" /*cups liquid*/
replace amount_g=amount*1 if unit=="ml" & food_category=="K" /*WATER*/
replace amount_g=amount*1 if unit=="ml" & food_category=="E" /*ORANGE JUICE*/
replace amount_g=amount*5 if unit=="tsp" & (food_category=="K" | food_category=="E") /*WATER*/
replace amount_g=amount*5 if unit=="tsp" & (food_category=="E") /*ORANGE JUICE*/
replace amount_g=amount*15 if unit=="tbsp" & (food_category=="K" | food_category=="E") /*WATER*/
replace amount_g=amount*15 if unit=="tbsp" & (food_category=="E") /*ORANGE JUICE*/
replace amount_g=amount*8 if unit=="tbsp" & (food_category=="V") /*cocoapowder*/

replace amount_g=amount*240 if unit=="C" & (food_category=="L") 

replace amount_g=amount*2 if unit=="small" & food_category=="G" /*spices*/
replace amount_g=amount*2 if food_name=="FENUGREEK LEAVES" 
replace amount_g=0.125 if unit=="pinch" 

*drop ingredients without food codes (n=119) - mostly additives
local list food_code 

foreach var1 of varlist `list' {
    drop if missing(`var1')
} 

*derive nutrients in a given recipe

*merge recipes with FCT
sort food_code
merge n:m food_code using "$data\temp_fct" 

*drop foods that are not ingredients in any of the recipes
drop if _merge==2
drop _merge

*derive nutrients in each ingredient
local nutrients energy_kj energy_kcal carb_g protein_g fat_g iron_mg calcium_mg zinc_mg sodium_mg cholesterol_mg freesugar_g sfa_mg mufa_mg pufa_mg fibre_g folate_ug vita_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

foreach var1 of varlist `nutrients' {
    gen r_`var1' = amount_g*(`var1'/100)
  } 
  
*sum up nutrients within a recipe

*replace . with 0 to ensure sums are correct
local r_nutrients r_energy_kj r_energy_kcal r_carb_g r_protein_g r_fat_g r_iron_mg r_calcium_mg r_zinc_mg r_sodium_mg r_cholesterol_mg r_freesugar_g r_sfa_mg r_mufa_mg r_pufa_mg r_fibre_g r_folate_ug r_vita_ug r_vitb1_mg r_vitb2_mg r_vitb3_mg r_vitb5_mg r_vitb6_mg r_vitb7_ug r_vitb9_ug r_vitc_mg r_carotenoids_ug

foreach var2 of varlist `r_nutrients' {
    replace `var2' = 0 if `var2'==.
  } 

*sum up within recipe
sort recipe_code

local r_nutrients r_energy_kj r_energy_kcal r_carb_g r_protein_g r_fat_g r_iron_mg r_calcium_mg r_zinc_mg r_sodium_mg r_cholesterol_mg r_freesugar_g r_sfa_mg r_mufa_mg r_pufa_mg r_fibre_g r_folate_ug r_vita_ug r_vitb1_mg r_vitb2_mg r_vitb3_mg r_vitb5_mg r_vitb6_mg r_vitb7_ug r_vitb9_ug r_vitc_mg r_carotenoids_ug

collapse (sum) amount_g `r_nutrients', by(recipe_code)
  
*drop prefix
rename r_* (*)

save "$data\temp_recipes.dta", replace

********************************************************************************
*Convert to amount per 100 g recipe 
********************************************************************************
local nutrients energy_kj energy_kcal carb_g protein_g fat_g iron_mg calcium_mg zinc_mg sodium_mg cholesterol_mg freesugar_g sfa_mg mufa_mg pufa_mg fibre_g folate_ug vita_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

foreach var1 of varlist `nutrients' {
    gen t_`var1' = `var1'/(amount_g/100)
  } 
  
*drop prefix
drop amount_g energy_kj energy_kcal carb_g protein_g fat_g iron_mg calcium_mg zinc_mg sodium_mg cholesterol_mg freesugar_g sfa_mg mufa_mg pufa_mg fibre_g folate_ug vita_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

rename t_* (*)

*merge with recipe name
sort recipe_code
merge n:n recipe_code using "$names"
drop _merge
order recipe_name, after(recipe_code)

*append to IFCT
rename recipe_name (food_name)
rename recipe_code (food_code)
append using "$data\temp_fct" 
save "$data\INDB_$date", replace

********************************************************************************
*Convert to amount per serving of recipe
********************************************************************************
use "$data\temp_recipes.dta"

*merge with serving size 
sort recipe_code
merge n:n recipe_code using "$servingsize"
drop _merge

drop if no_of_servings==. /* n=89 missing serving size*/

*derive nutrients per serving of recipe
local nutrients energy_kj energy_kcal carb_g protein_g fat_g iron_mg calcium_mg zinc_mg sodium_mg cholesterol_mg freesugar_g sfa_mg mufa_mg pufa_mg fibre_g folate_ug vita_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

foreach var1 of varlist `nutrients' {
    gen serving_`var1' = `var1'/no_of_servings
  } 

*merge to IFCT
drop amount_g energy_kj energy_kcal carb_g protein_g fat_g iron_mg calcium_mg zinc_mg sodium_mg cholesterol_mg freesugar_g sfa_mg mufa_mg pufa_mg fibre_g folate_ug vita_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug recipe_code_org recipe_name_org recipe_name no_of_servings

rename recipe_code (food_code)
sort food_code
merge n:m food_code using "$data\INDB_$date" 
drop _merge

********************************************************************************
*Organise data
********************************************************************************

*label variables
label var food_code "Food / recipe code"
label var food_name "Food / recipe name"

label var energy_kj "Total energy (kilojoules) per 100g"
label var energy_kcal "Total energy (kilocalories) per 100g"
label var carb_g "Total carbohydrates (g) per 100g"
label var protein_g "Total protein (g) per 100g"
label var fat_g "Total fat (g) per 100g"
label var iron_mg "Total iron (mg) per 100g"
label var calcium_mg "Total calcium (mg) per 100g"
label var zinc_mg "Total zinc (mg) per 100g"
label var sodium_mg "Total sodium (mg) per 100g"
label var cholesterol_mg "Total cholesterol (mg) per 100g"
label var freesugar_g "Total free sugars (g) per 100g"
label var sfa_mg "Total saturated fatty acids (mg) per 100g"
label var mufa_mg "Total monounsaturated fatty acids (mg) per 100g"
label var pufa_mg "Total polyunsaturated fatty acids (mg) per 100g"
label var fibre_g "Total fibre (g) per 100g"
label var folate_ug "Total folate (ug) per 100g"
label var vita_ug "Total vitamin A (ug) per 100g"
label var vitb1_mg "Total vitamin B1 (mg) per 100g"
label var vitb2_mg "Total vitamin B2 (mg) per 100g"
label var vitb3_mg "Total vitamin B3 (mg) per 100g"
label var vitb5_mg "Total vitamin B5 (mg) per 100g"
label var vitb6_mg "Total vitamin B6 (mg) per 100g"
label var vitb7_ug "Total vitamin B7 (ug) per 100g"
label var vitb9_ug "Total vitamin B9 (ug) per 100g"
label var vitc_mg "Total vitamin C (mg) per 100g"
label var carotenoids_ug "Total carotenoids (ug) per 100g"

label var serving_energy_kj "Total energy (kilojoules) per serving"
label var serving_energy_kcal "Total energy (kilocalories) per serving"
label var serving_carb_g "Total carbohydrates (g) per serving"
label var serving_protein_g "Total protein (g) per serving"
label var serving_fat_g "Total fat (g) per serving"
label var serving_iron_mg "Total iron (mg) per serving"
label var serving_calcium_mg "Total calcium (mg) per serving"
label var serving_zinc_mg "Total zinc (mg) per serving"
label var serving_sodium_mg "Total sodium (mg) per serving"
label var serving_cholesterol_mg "Total cholesterol (mg) per serving"
label var serving_freesugar_g "Total free sugars (g) per serving"
label var serving_sfa_mg "Total saturated fatty acids (mg) per serving"
label var serving_mufa_mg "Total monounsaturated fatty acids (mg) per serving"
label var serving_pufa_mg "Total polyunsaturated fatty acids (mg) per serving"
label var serving_fibre_g "Total fibre (g) per serving"
label var serving_folate_ug "Total folate (ug) per serving"
label var serving_vita_ug "Total vitamin A (ug) per serving"
label var serving_vitb1_mg "Total vitamin B1 (mg) per serving"
label var serving_vitb2_mg "Total vitamin B2 (mg) per serving"
label var serving_vitb3_mg "Total vitamin B3 (mg) per serving"
label var serving_vitb5_mg "Total vitamin B5 (mg) per serving"
label var serving_vitb6_mg "Total vitamin B6 (mg) per serving"
label var serving_vitb7_ug "Total vitamin B7 (ug) per serving"
label var serving_vitb9_ug "Total vitamin B9 (ug) per serving"
label var serving_vitc_mg "Total vitamin C (mg) per serving"
label var serving_carotenoids_ug "Total carotenoids (ug) per serving"

*order variables
order size_of_servings servings_unit serving_energy_kj serving_energy_kcal serving_carb_g serving_protein_g serving_fat_g serving_iron_mg serving_calcium_mg serving_zinc_mg serving_sodium_mg serving_cholesterol_mg serving_freesugar_g serving_sfa_mg serving_mufa_mg serving_pufa_mg serving_fibre_g serving_folate_ug serving_vita_ug serving_vitb1_mg serving_vitb2_mg serving_vitb3_mg serving_vitb5_mg serving_vitb6_mg serving_vitb7_ug serving_vitb9_ug serving_vitc_mg serving_carotenoids_ug, after(food_name)

order energy_kj energy_kcal carb_g protein_g fat_g iron_mg calcium_mg zinc_mg sodium_mg cholesterol_mg freesugar_g sfa_mg mufa_mg pufa_mg fibre_g folate_ug vita_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug, after(serving_carotenoids_ug)

order food_code_org food_group_nin primarysource secondarysource, after(carotenoids_ug)

save "$data\INDB_$date", replace

export excel "$output\INDB_$date", firstrow(variables) replace
