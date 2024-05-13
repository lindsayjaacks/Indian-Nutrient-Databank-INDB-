
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
global location "C:\Users\Aswathy Vijayakumar\Desktop\Aswathy Files\Anuvaad Solutions India 2022\Indian Nutrient Database\data_masterfiles"

*lindsay
global location "C:\Users\ljaacks\OneDrive - University of Edinburgh\Anuvaad\What India Eats\Indian Food Composition Database"

*this is the location of the data within the project
global data `"$location\Data"'

*this is where the output should go within the project
global output `"$location\Output"'

*this is where the log should go within the project
global log `"$location\Log"'

*this is the date @UPDATE
global date "20240513"

********************************************************************************
*Import Excel files and convert to Stata files
********************************************************************************

*NIN FCT 
import excel "$data\NIN_fct.xlsx", sheet("Sheet1") firstrow clear
sort food_code
save "$data\NIN_fct.dta", replace

*drop empty rows from Excel
drop if food_code==""

*convert to numeric
local list energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

foreach var1 of varlist `list' {
	replace `var1' = "0" if `var1' =="N" | `var1' =="Tr" | `var1' =="NA" 
 }

local list energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

destring `list', replace

save "$data\NIN_fct.dta", replace

*UK FCT 
import excel "$data\UK_fct.xlsx", sheet("Sheet1") firstrow clear

*drop empty rows from Excel
drop if food_code==""

*convert to numeric
local list energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

foreach var1 of varlist `list' {
	replace `var1' = "0" if `var1' =="N" | `var1' =="Tr" | `var1' =="" | `var1' =="NA"
 }

destring `list', replace
	
save "$data\UK_fct.dta", replace
		
*US FCT 
import excel "$data\US_fct.xlsx", sheet("Sheet1") firstrow clear

*drop empty rows from Excel
drop if food_code==""
	
*convert to numeric
local list freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

foreach var1 of varlist `list' {
	replace `var1' = "0" if `var1' =="NA"
 }

local list energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

destring `list', replace
	
save "$data\US_fct.dta", replace

*Recipe ingredients
import excel "$data\recipes.xlsx", sheet("Sheet1") firstrow clear
drop if recipe_code==""

drop recipe_name
sort recipe_code
save "$data\recipes.dta", replace

*Recipe names
import excel "$data\recipes_names.xlsx", sheet("sheet1") firstrow clear

*drop empty rows from Excel
drop if recipe_code==""

drop recipe_name_org
	
sort recipe_code
save "$data\recipes_names.dta", replace

*Serving size
import excel "$data\recipes_servingsize.xlsx", sheet("Sheet1") firstrow clear

*drop empty rows from Excel
drop if recipe_code==""

drop no_of_servings_org size_of_servings_org servings_unit_org remarks_1 remarks_2
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

sort food_code
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

*drop ingredients without food codes (n=123) - mostly additives
local list food_code 

foreach var1 of varlist `list' {
    drop if missing(`var1')
}

save "$data\temp_recipes_conversions.dta", replace

*derive nutrients in a given recipe

*merge recipes with FCT
sort food_code
merge n:m food_code using "$data\temp_fct" 

*drop foods that are not ingredients in any of the recipes
drop if _merge==2
drop _merge

*derive nutrients in each ingredient
local nutrients energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

foreach var1 of varlist `nutrients' {
    gen r_`var1' = amount_g*(`var1'/100)
  } 
  
*sum up nutrients within a recipe

*replace . with 0 to ensure sums are correct
local r_nutrients r_energy_kj r_energy_kcal r_carb_g r_protein_g r_fat_g r_freesugar_g r_fibre_g r_sfa_mg r_mufa_mg r_pufa_mg r_cholesterol_mg r_calcium_mg r_phosphorus_mg r_magnesium_mg r_sodium_mg r_potassium_mg r_iron_mg r_copper_mg r_selenium_ug r_chromium_mg r_manganese_mg molybdenum_mg r_zinc_mg r_vita_ug r_vite_mg r_vitd2_ug r_vitd3_ug r_vitk1_ug r_vitk2_ug r_folate_ug r_vitb1_mg r_vitb2_mg r_vitb3_mg r_vitb5_mg r_vitb6_mg r_vitb7_ug r_vitb9_ug r_vitc_mg r_carotenoids_ug

foreach var2 of varlist `r_nutrients' {
    replace `var2' = 0 if `var2'==.
  } 

*sum up within recipe
sort recipe_code

local r_nutrients r_energy_kj r_energy_kcal r_carb_g r_protein_g r_fat_g r_freesugar_g r_fibre_g r_sfa_mg r_mufa_mg r_pufa_mg r_cholesterol_mg r_calcium_mg r_phosphorus_mg r_magnesium_mg r_sodium_mg r_potassium_mg r_iron_mg r_copper_mg r_selenium_ug r_chromium_mg r_manganese_mg molybdenum_mg r_zinc_mg r_vita_ug r_vite_mg r_vitd2_ug r_vitd3_ug r_vitk1_ug r_vitk2_ug r_folate_ug r_vitb1_mg r_vitb2_mg r_vitb3_mg r_vitb5_mg r_vitb6_mg r_vitb7_ug r_vitb9_ug r_vitc_mg r_carotenoids_ug

collapse (sum) amount_g `r_nutrients', by(recipe_code)
  
*drop prefix
rename r_* (*)

save "$data\temp_recipes.dta", replace

********************************************************************************
*Convert to amount per 100 g recipe without nutrient retention factor
********************************************************************************
local nutrients energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

foreach var1 of varlist `nutrients' {
    gen t_`var1' = `var1'/(amount_g/100)
  } 
  
*drop prefix
drop amount_g energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

rename t_* (*)

*merge with recipe name
sort recipe_code
merge n:n recipe_code using "$names"
drop _merge
order recipe_code_org recipe_name primarysource, after(recipe_code)

*save the nutrient values with two decimal points
local nutrients energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

foreach var1 of varlist `nutrients' {
	format `var1' %9.2f
  } 

*ORGANISE DATA
*label variables

label var energy_kj "Total energy (kilojoules) per 100g"
label var energy_kcal "Total energy (kilocalories) per 100g"
label var carb_g "Total carbohydrates (g) per 100g"
label var protein_g "Total protein (g) per 100g"
label var fat_g "Total fat (g) per 100g"
label var freesugar_g "Total free sugars (g) per 100g"
label var fibre_g "Total fibre (g) per 100g"
label var sfa_mg "Total saturated fatty acids (mg) per 100g"
label var mufa_mg "Total monounsaturated fatty acids (mg) per 100g"
label var pufa_mg "Total polyunsaturated fatty acids (mg) per 100g"
label var cholesterol_mg "Total cholesterol (mg) per 100g"
label var calcium_mg "Total calcium (mg) per 100g"
label var phosphorus_mg "Total phosphorus (mg) per 100g"
label var magnesium_mg "Total magnesium (mg) per 100g"
label var sodium_mg "Total sodium (mg) per 100g"
label var potassium_mg "Total potassium (mg) per 100g"
label var iron_mg "Total iron (mg) per 100g"
label var copper_mg "Total copper (mg) per 100g"
label var selenium_ug "Total selenium (ug) per 100g"
label var chromium_mg "Total chromium (mg) per 100g"
label var manganese_mg "Total manganese (mg) per 100g"
label var molybdenum_mg "Total molybdenum (mg) per 100g"
label var zinc_mg "Total zinc (mg) per 100g"
label var vita_ug "Total vitamin A (ug) per 100g"
label var vite_mg "Total vitamin E (mg) per 100g"
label var vitd2_ug "Total vitamin D2 (ug) per 100g"
label var vitd3_ug "Total vitamin D3 (ug) per 100g"
label var vitk1_ug "Total vitamin K1 (ug) per 100g"
label var vitk2_ug "Total vitamin K2 (ug) per 100g"
label var folate_ug "Total folate (ug) per 100g"
label var vitb1_mg "Total vitamin B1 (mg) per 100g"
label var vitb2_mg "Total vitamin B2 (mg) per 100g"
label var vitb3_mg "Total vitamin B3 (mg) per 100g"
label var vitb5_mg "Total vitamin B5 (mg) per 100g"
label var vitb6_mg "Total vitamin B6 (mg) per 100g"
label var vitb7_ug "Total vitamin B7 (ug) per 100g"
label var vitb9_ug "Total vitamin B9 (ug) per 100g"
label var vitc_mg "Total vitamin C (mg) per 100g"
label var carotenoids_ug "Total carotenoids (ug) per 100g"

*save the recipes with nutrients values per 100g of the recipes
save "$data\temp_recipes_100G_$date", replace

***********************************************************************************
*Convert to amount per serving size of the recipe without nutrient retention factor
***********************************************************************************

*adding servingsize

use "$data\temp_recipes.dta"

*merge with serving size 
sort recipe_code
merge n:n recipe_code using "$servingsize"
drop _merge

drop if no_of_servings==. /* n=82 missing serving size*/

*derive nutrients per serving of recipe
local nutrients energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

foreach var1 of varlist `nutrients' {
    gen serving_`var1' = `var1'/no_of_servings
  } 

*derive nutrients per serving unit of each recipe  
destring size_of_servings, replace
  
local serving_nutrients serving_energy_kj serving_energy_kcal serving_carb_g serving_protein_g serving_fat_g serving_freesugar_g serving_fibre_g serving_sfa_mg serving_mufa_mg serving_pufa_mg serving_cholesterol_mg serving_calcium_mg serving_phosphorus_mg serving_magnesium_mg serving_sodium_mg serving_potassium_mg serving_iron_mg serving_copper_mg serving_selenium_ug serving_chromium_mg serving_manganese_mg serving_molybdenum_mg serving_zinc_mg serving_vita_ug serving_vite_mg serving_vitd2_ug serving_vitd3_ug serving_vitk1_ug serving_vitk2_ug serving_folate_ug serving_vitb1_mg serving_vitb2_mg serving_vitb3_mg serving_vitb5_mg serving_vitb6_mg serving_vitb7_ug serving_vitb9_ug serving_vitc_mg serving_carotenoids_ug

foreach var1 of varlist `serving_nutrients' {
    gen unit_`var1' = `var1'/size_of_servings
  } 

drop energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

drop serving_energy_kj serving_energy_kcal serving_carb_g serving_protein_g serving_fat_g serving_freesugar_g serving_fibre_g serving_sfa_mg serving_mufa_mg serving_pufa_mg serving_cholesterol_mg serving_calcium_mg serving_phosphorus_mg serving_magnesium_mg serving_sodium_mg serving_potassium_mg serving_iron_mg serving_copper_mg serving_selenium_ug serving_chromium_mg serving_manganese_mg serving_molybdenum_mg serving_zinc_mg serving_vita_ug serving_vite_mg serving_vitd2_ug serving_vitd3_ug serving_vitk1_ug serving_vitk2_ug serving_folate_ug serving_vitb1_mg serving_vitb2_mg serving_vitb3_mg serving_vitb5_mg serving_vitb6_mg serving_vitb7_ug serving_vitb9_ug serving_vitc_mg serving_carotenoids_ug

*save the nutrient values with two decimal points
local unit_nutrients unit_serving_energy_kj unit_serving_energy_kcal unit_serving_carb_g unit_serving_protein_g unit_serving_fat_g unit_serving_freesugar_g unit_serving_fibre_g unit_serving_sfa_mg unit_serving_mufa_mg unit_serving_pufa_mg unit_serving_cholesterol_mg unit_serving_calcium_mg unit_serving_phosphorus_mg unit_serving_magnesium_mg unit_serving_sodium_mg unit_serving_potassium_mg unit_serving_iron_mg unit_serving_copper_mg unit_serving_selenium_ug unit_serving_chromium_mg unit_serving_manganese_mg unit_serving_molybdenum_mg unit_serving_zinc_mg unit_serving_vita_ug unit_serving_vite_mg unit_serving_vitd2_ug unit_serving_vitd3_ug unit_serving_vitk1_ug unit_serving_vitk2_ug unit_serving_folate_ug unit_serving_vitb1_mg unit_serving_vitb2_mg unit_serving_vitb3_mg unit_serving_vitb5_mg unit_serving_vitb6_mg unit_serving_vitb7_ug unit_serving_vitb9_ug unit_serving_vitc_mg unit_serving_carotenoids_ug

foreach var1 of varlist `unit_nutrients' {
	format `var1' %9.2f
  } 

drop amount_g recipe_name_org recipe_code_org no_of_servings size_of_servings
save "$data\temp_recipes_servingsize.dta", replace

*ORGANISE DATA
*label variables
label var servings_unit "The serving unit of the recipe"

label var unit_serving_energy_kj "Total energy (kilojoules) per serving unit"
label var unit_serving_energy_kcal "Total energy (kilocalories) per serving unit"
label var unit_serving_carb_g "Total carbohydrates (g) per serving unit"
label var unit_serving_protein_g "Total protein (g) per serving unit"
label var unit_serving_fat_g "Total fat (g) per serving unit"
label var unit_serving_freesugar_g "Total free sugars (g) per serving unit"
label var unit_serving_fibre_g "Total fibre (g) per serving unit"
label var unit_serving_sfa_mg "Total saturated fatty acids (mg) per serving unit"
label var unit_serving_mufa_mg "Total monounsaturated fatty acids (mg) per serving unit"
label var unit_serving_pufa_mg "Total polyunsaturated fatty acids (mg) per serving unit"
label var unit_serving_cholesterol_mg "Total cholesterol (mg) per serving unit"
label var unit_serving_calcium_mg "Total calcium (mg) per serving unit"
label var unit_serving_phosphorus_mg "Total phosphorus (mg) per serving unit"
label var unit_serving_magnesium_mg "Total magnesium (mg) per serving unit"
label var unit_serving_sodium_mg "Total sodium (mg) per serving unit"
label var unit_serving_potassium_mg "Total potassium (mg) per serving unit"
label var unit_serving_iron_mg "Total iron (mg) per serving unit"
label var unit_serving_copper_mg "Total copper (mg) per serving unit"
label var unit_serving_selenium_ug "Total selenium (ug) per serving unit"
label var unit_serving_chromium_mg "Total chromium (mg) per serving unit"
label var unit_serving_manganese_mg "Total manganese (mg) per serving unit"
label var unit_serving_molybdenum_mg "Total molybdenum (mg) per serving unit"
label var unit_serving_zinc_mg "Total zinc (mg) per serving unit"
label var unit_serving_vita_ug "Total vitamin A (ug) per serving unit"
label var unit_serving_vite_mg "Total vitamin E (mg) per serving unit"
label var unit_serving_vitd2_ug "Total vitamin D2 (ug) per serving unit"
label var unit_serving_vitd3_ug "Total vitamin D3 (ug) per serving unit"
label var unit_serving_vitk1_ug "Total vitamin K1 (ug) per serving unit"
label var unit_serving_vitk2_ug "Total vitamin K2 (ug) per serving unit"
label var unit_serving_folate_ug "Total folate (ug) per serving unit"
label var unit_serving_vitb1_mg "Total vitamin B1 (mg) per serving unit"
label var unit_serving_vitb2_mg "Total vitamin B2 (mg) per serving unit"
label var unit_serving_vitb3_mg "Total vitamin B3 (mg) per serving unit"
label var unit_serving_vitb5_mg "Total vitamin B5 (mg) per serving unit"
label var unit_serving_vitb6_mg "Total vitamin B6 (mg) per serving unit"
label var unit_serving_vitb7_ug "Total vitamin B7 (ug) per serving unit"
label var unit_serving_vitb9_ug "Total vitamin B9 (ug) per serving unit"
label var unit_serving_vitc_mg "Total vitamin C (mg) per serving unit"
label var unit_serving_carotenoids_ug "Total carotenoids (ug) per serving unit"

save "$data\temp_recipes_servingsize.dta", replace

*merge with 100g of recipes
use "$data\temp_recipes_servingsize.dta"

sort recipe_code
merge n:n recipe_code using "$data\temp_recipes_100G_$date"
drop _merge

order primarysource energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug, after(recipe_name)

rename recipe_name (food_name)
rename recipe_code (food_code)
rename recipe_code_org (food_code_org)

save "$data\INDB_recipes_$date.dta", replace

********************************************************************************
*COMPLETE IFCT without nutrient retention factor
********************************************************************************

*append to FCT

*Complete FCT 
use "$data\temp_fct", replace
drop retention_factor

append using "$data\INDB_recipes_$date.dta", force

drop food_code_org

order secondarysource food_group_nin, after(primarysource)

*save the nutrient values with two decimal points
local nutrients energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

foreach var1 of varlist `nutrients' {
	format `var1' %9.2f
  } 

save "$data\INDB_$date", replace
export excel "$output\INDB_$date", firstrow(variables) replace

********************************************************************************
*OBTAINING NUTRIENT VALUES WITH NUTRIENT RETENTION FACTOR
********************************************************************************

********************************************************************************
*Convert to amount per 100 g recipe WITH NUTRIENT RETENTION FACTOR
********************************************************************************
*linking total FCT with nutrient retention factor
*USDA nutrient retention factor - Release 6 data
import excel "$data\USDA_nrf.xlsx", sheet("Sheet1") firstrow clear
sort retention_factor
save "$data\USDA_nrf.dta", replace

use "$data\temp_fct", clear
sort retention_factor
merge n:m retention_factor using "$data\USDA_nrf.dta"
drop _merge

*drop empty rows from Excel
drop if food_code==""
save "$data\temp_IFCT_NRF_$date", replace

sort food_code

*drop nutrients not in IFCT
drop usda_rf_folate_food usda_rf_choline usda_rf_vitb12 usda_rf_vita_iu usda_rf_alcohol usda_rf_carotene_alpha usda_rf_cryptoxanthin usda_rf_lycopene usda_rf_lutein

*converting nutrient retention factor values from percentages
local nutrients_rf usda_rf_calcium usda_rf_iron usda_rf_magnesium usda_rf_phosphorus usda_rf_potassium usda_rf_sodium usda_rf_zinc usda_rf_copper usda_rf_vitc usda_rf_vitb1 usda_rf_vitb2 usda_rf_vitb3 usda_rf_vitb9 usda_rf_vitb6 usda_rf_folate_total usda_rf_vita_re usda_rf_carotene_beta

foreach var1 in `nutrients_rf' {
    gen d_`var1' = `var1'/100
}

drop usda_rf_calcium usda_rf_iron usda_rf_magnesium usda_rf_phosphorus usda_rf_potassium usda_rf_sodium usda_rf_zinc usda_rf_copper usda_rf_vitc usda_rf_vitb1 usda_rf_vitb2 usda_rf_vitb3 usda_rf_vitb9 usda_rf_vitb6 usda_rf_folate_total usda_rf_vita_re usda_rf_carotene_beta

rename d_* (*)

*recoding missing retention factor into 0
replace retention_factor = 0 if missing(retention_factor)

*assigning 100% retention to those with missing retention factor
local nutrients_rf usda_rf_calcium usda_rf_iron usda_rf_magnesium usda_rf_phosphorus usda_rf_potassium usda_rf_sodium usda_rf_zinc usda_rf_copper usda_rf_vitc usda_rf_vitb1 usda_rf_vitb2 usda_rf_vitb3 usda_rf_vitb9 usda_rf_vitb6 usda_rf_folate_total usda_rf_vita_re usda_rf_carotene_beta

foreach var1 in `nutrients_rf' {
    replace `var1' = 1 if retention_factor == 0
}

rename usda_rf_carotene_beta usda_rf_carotenoids /*value of NRF is same for all types of carotenoids*/

save "$data\temp_IFCT_NRF_$date", replace

*applying retention factor to nutrients

*nutrients in mg
local nutrients calcium iron magnesium phosphorus potassium sodium zinc copper vitb1 vitb2 vitb3 vitb6 vitc

foreach nutrient in `nutrients' {
    local prefix "(`nutrient'_mg*usda_rf_`nutrient')"
    generate nrf_`nutrient'_mg = `prefix'
}

*nutrients in ug
local nutrients vita folate vitb9 carotenoids

foreach nutrient in `nutrients' {
    local prefix "(`nutrient'_ug*usda_rf_`nutrient')"
    generate nrf_`nutrient'_ug = `prefix'
}

*no data on NRF - renaming the variables to same format as above
local nutrients "energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg selenium_ug chromium_mg manganese_mg molybdenum_mg vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug vitb5_mg vitb7_ug"

foreach nutrient in `nutrients' {
    local prefix "nrf_"
    local new_name "`prefix'`nutrient'"
    generate `new_name' = `nutrient'
}

save "$data\temp_IFCT_NRF_$date", replace

*derive nutrients in a given recipe - applying nutrient retention factor
**************************************************************************
use "$data\temp_recipes_conversions.dta", replace

*merge recipes with FCT
sort food_code
merge n:m food_code using "$data\temp_IFCT_NRF_$date" 

*drop foods that are not ingredients in any of the recipes
drop if _merge==2
drop _merge

*drop original nutrient values
drop energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

*derive nutrients in each ingredient
local nutrients nrf_energy_kj nrf_energy_kcal nrf_carb_g nrf_protein_g nrf_fat_g nrf_freesugar_g nrf_fibre_g nrf_sfa_mg nrf_mufa_mg nrf_pufa_mg nrf_cholesterol_mg nrf_calcium_mg nrf_phosphorus_mg nrf_magnesium_mg nrf_sodium_mg nrf_potassium_mg nrf_iron_mg nrf_copper_mg nrf_selenium_ug nrf_chromium_mg nrf_manganese_mg nrf_molybdenum_mg nrf_zinc_mg nrf_vita_ug nrf_vite_mg nrf_vitd2_ug nrf_vitd3_ug nrf_vitk1_ug nrf_vitk2_ug nrf_folate_ug nrf_vitb1_mg nrf_vitb2_mg nrf_vitb3_mg nrf_vitb5_mg nrf_vitb6_mg nrf_vitb7_ug nrf_vitb9_ug nrf_vitc_mg nrf_carotenoids_ug

foreach var1 of varlist `nutrients' {
    gen r_`var1' = amount_g*(`var1'/100)
  } 
  
*sum up nutrients within a recipe
local r_nutrients r_nrf_energy_kj r_nrf_energy_kcal r_nrf_carb_g r_nrf_protein_g r_nrf_fat_g r_nrf_freesugar_g r_nrf_fibre_g r_nrf_sfa_mg r_nrf_mufa_mg r_nrf_pufa_mg r_nrf_cholesterol_mg r_nrf_calcium_mg r_nrf_phosphorus_mg r_nrf_magnesium_mg r_nrf_sodium_mg r_nrf_potassium_mg r_nrf_iron_mg r_nrf_copper_mg r_nrf_selenium_ug r_nrf_chromium_mg r_nrf_manganese_mg r_nrf_molybdenum_mg r_nrf_zinc_mg r_nrf_vita_ug r_nrf_vite_mg r_nrf_vitd2_ug r_nrf_vitd3_ug r_nrf_vitk1_ug r_nrf_vitk2_ug r_nrf_folate_ug r_nrf_vitb1_mg r_nrf_vitb2_mg r_nrf_vitb3_mg r_nrf_vitb5_mg r_nrf_vitb6_mg r_nrf_vitb7_ug r_nrf_vitb9_ug r_nrf_vitc_mg r_nrf_carotenoids_ug

*replace . with 0 to ensure sums are correct
foreach var2 of varlist `r_nutrients' {
    replace `var2' = 0 if `var2'==.
  } 

*sum up within recipe
sort recipe_code

local r_nrf_nutrients r_nrf_energy_kj r_nrf_energy_kcal r_nrf_carb_g r_nrf_protein_g r_nrf_fat_g r_nrf_freesugar_g r_nrf_fibre_g r_nrf_sfa_mg r_nrf_mufa_mg r_nrf_pufa_mg r_nrf_cholesterol_mg r_nrf_calcium_mg r_nrf_phosphorus_mg r_nrf_magnesium_mg r_nrf_sodium_mg r_nrf_potassium_mg r_nrf_iron_mg r_nrf_copper_mg r_nrf_selenium_ug r_nrf_chromium_mg r_nrf_manganese_mg r_nrf_molybdenum_mg r_nrf_zinc_mg r_nrf_vita_ug r_nrf_vite_mg r_nrf_vitd2_ug r_nrf_vitd3_ug r_nrf_vitk1_ug r_nrf_vitk2_ug r_nrf_folate_ug r_nrf_vitb1_mg r_nrf_vitb2_mg r_nrf_vitb3_mg r_nrf_vitb5_mg r_nrf_vitb6_mg r_nrf_vitb7_ug r_nrf_vitb9_ug r_nrf_vitc_mg r_nrf_carotenoids_ug

collapse (sum) amount_g `r_nrf_nutrients', by(recipe_code)
  
*drop prefix
rename r_* (*)

save "$data\temp_recipes_nrf.dta", replace

********************************************************************************
*Convert to amount per 100 g recipe with nutrient retention factor
********************************************************************************
local nutrients nrf_energy_kj nrf_energy_kcal nrf_carb_g nrf_protein_g nrf_fat_g nrf_freesugar_g nrf_fibre_g nrf_sfa_mg nrf_mufa_mg nrf_pufa_mg nrf_cholesterol_mg nrf_calcium_mg nrf_phosphorus_mg nrf_magnesium_mg nrf_sodium_mg nrf_potassium_mg nrf_iron_mg nrf_copper_mg nrf_selenium_ug nrf_chromium_mg nrf_manganese_mg nrf_molybdenum_mg nrf_zinc_mg nrf_vita_ug nrf_vite_mg nrf_vitd2_ug nrf_vitd3_ug nrf_vitk1_ug nrf_vitk2_ug nrf_folate_ug nrf_vitb1_mg nrf_vitb2_mg nrf_vitb3_mg nrf_vitb5_mg nrf_vitb6_mg nrf_vitb7_ug nrf_vitb9_ug nrf_vitc_mg nrf_carotenoids_ug

foreach var1 of varlist `nutrients' {
    gen t_`var1' = `var1'/(amount_g/100)
  } 
  
*drop prefix
drop amount_g nrf_energy_kj nrf_energy_kcal nrf_carb_g nrf_protein_g nrf_fat_g nrf_freesugar_g nrf_fibre_g nrf_sfa_mg nrf_mufa_mg nrf_pufa_mg nrf_cholesterol_mg nrf_calcium_mg nrf_phosphorus_mg nrf_magnesium_mg nrf_sodium_mg nrf_potassium_mg nrf_iron_mg nrf_copper_mg nrf_selenium_ug nrf_chromium_mg nrf_manganese_mg nrf_molybdenum_mg nrf_zinc_mg nrf_vita_ug nrf_vite_mg nrf_vitd2_ug nrf_vitd3_ug nrf_vitk1_ug nrf_vitk2_ug nrf_folate_ug nrf_vitb1_mg nrf_vitb2_mg nrf_vitb3_mg nrf_vitb5_mg nrf_vitb6_mg nrf_vitb7_ug nrf_vitb9_ug nrf_vitc_mg nrf_carotenoids_ug

rename t_* (*)

*merge with recipe name
sort recipe_code
merge n:n recipe_code using "$names"
drop _merge
order recipe_code_org recipe_name primarysource, after(recipe_code)

*save the nutrient values with two decimal points
local nutrients nrf_energy_kj nrf_energy_kcal nrf_carb_g nrf_protein_g nrf_fat_g nrf_freesugar_g nrf_fibre_g nrf_sfa_mg nrf_mufa_mg nrf_pufa_mg nrf_cholesterol_mg nrf_calcium_mg nrf_phosphorus_mg nrf_magnesium_mg nrf_sodium_mg nrf_potassium_mg nrf_iron_mg nrf_copper_mg nrf_selenium_ug nrf_chromium_mg nrf_manganese_mg nrf_molybdenum_mg nrf_zinc_mg nrf_vita_ug nrf_vite_mg nrf_vitd2_ug nrf_vitd3_ug nrf_vitk1_ug nrf_vitk2_ug nrf_folate_ug nrf_vitb1_mg nrf_vitb2_mg nrf_vitb3_mg nrf_vitb5_mg nrf_vitb6_mg nrf_vitb7_ug nrf_vitb9_ug nrf_vitc_mg nrf_carotenoids_ug

foreach var1 of varlist `nutrients' {
	format `var1' %9.2f
  }

*save the recipes with nutrients values per 100g of the recipes
save "$data\temp_recipes_100G_nrf_$date", replace

********************************************************************************
*SENSITIVITY ANALYSIS
********************************************************************************
*saving log file of sensitivity analysis
log using "$log\sensitivity_output$date", replace

*sensitivity analysis for nutrients 100g per recipe
use "$data\temp_recipes_100G_$date", replace
merge n:n recipe_code using "$data\temp_recipes_100G_nrf_$date"
drop _merge

save "$data\temp_nutrientsensitivityanalysis_100G_$date", replace

export excel "$output\temp_nutrientsensitivityanalysis_100G_$date", firstrow(variables) replace

*sensitivity analysis
local nutrients "calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg zinc_mg vita_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb6_mg vitb9_ug vitc_mg carotenoids_ug"

foreach nutrient in `nutrients' {
    local nrf_var "nrf_`nutrient'"
    signrank `nrf_var'= `nutrient'
}

log close

*ORGANISE DATA
*getting data ready to be added to total IFCT
use "$data\temp_recipes_100G_nrf_$date", replace
rename nrf_* (*)

*label variables

label var energy_kj "Total energy (kilojoules) per 100g (with retention factor)"
label var energy_kcal "Total energy (kilocalories) per 100g (with retention factor)"
label var carb_g "Total carbohydrates (g) per 100g (with retention factor)"
label var protein_g "Total protein (g) per 100g (with retention factor)"
label var fat_g "Total fat (g) per 100g (with retention factor)"
label var freesugar_g "Total free sugars (g) per 100g (with retention factor)"
label var fibre_g "Total fibre (g) per 100g (with retention factor)"
label var sfa_mg "Total saturated fatty acids (mg) per 100g (with retention factor)"
label var mufa_mg "Total monounsaturated fatty acids (mg) per 100g (with retention factor)"
label var pufa_mg "Total polyunsaturated fatty acids (mg) per 100g (with retention factor)"
label var cholesterol_mg "Total cholesterol (mg) per 100g (with retention factor)"
label var calcium_mg "Total calcium (mg) per 100g (with retention factor)"
label var phosphorus_mg "Total phosphorus (mg) per 100g (with retention factor)"
label var magnesium_mg "Total magnesium (mg) per 100g (with retention factor)"
label var sodium_mg "Total sodium (mg) per 100g (with retention factor)"
label var potassium_mg "Total potassium (mg) per 100g (with retention factor)"
label var iron_mg "Total iron (mg) per 100g (with retention factor)"
label var copper_mg "Total copper (mg) per 100g (with retention factor)"
label var selenium_ug "Total selenium (ug) per 100g (with retention factor)"
label var chromium_mg "Total chromium (mg) per 100g (with retention factor)"
label var manganese_mg "Total manganese (mg) per 100g (with retention factor)"
label var molybdenum_mg "Total molybdenum (mg) per 100g (with retention factor)"
label var zinc_mg "Total zinc (mg) per 100g (with retention factor)"
label var vita_ug "Total vitamin A (ug) per 100g (with retention factor)"
label var vite_mg "Total vitamin E (mg) per 100g (with retention factor)"
label var vitd2_ug "Total vitamin D2 (ug) per 100g (with retention factor)"
label var vitd3_ug "Total vitamin D3 (ug) per 100g (with retention factor)"
label var vitk1_ug "Total vitamin K1 (ug) per 100g (with retention factor)"
label var vitk2_ug "Total vitamin K2 (ug) per 100g (with retention factor)"
label var folate_ug "Total folate (ug) per 100g (with retention factor)"
label var vitb1_mg "Total vitamin B1 (mg) per 100g (with retention factor)"
label var vitb2_mg "Total vitamin B2 (mg) per 100g (with retention factor)"
label var vitb3_mg "Total vitamin B3 (mg) per 100g (with retention factor)"
label var vitb5_mg "Total vitamin B5 (mg) per 100g (with retention factor)"
label var vitb6_mg "Total vitamin B6 (mg) per 100g (with retention factor)"
label var vitb7_ug "Total vitamin B7 (ug) per 100g (with retention factor)"
label var vitb9_ug "Total vitamin B9 (ug) per 100g (with retention factor)"
label var vitc_mg "Total vitamin C (mg) per 100g (with retention factor)"
label var carotenoids_ug "Total carotenoids (ug) per 100g (with retention factor)"

*save the recipes with nutrients values per 100g of the recipes
save "$data\temp_recipes_100G_nrf_$date", replace

***********************************************************************************
*Convert to amount per serving size of the recipe with nutrient retention factor
***********************************************************************************
*adding servingsize
use "$data\temp_recipes_nrf.dta", replace

rename nrf_* (*)

*merge with serving size 
sort recipe_code
merge n:n recipe_code using "$servingsize"
drop _merge

drop if no_of_servings==. /* n=82 missing serving size*/

*derive nutrients per serving of recipe
local nutrients energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

foreach var1 of varlist `nutrients' {
    gen serving_`var1' = `var1'/no_of_servings
  } 

*derive nutrients per serving unit of each recipe  
destring size_of_servings, replace
  
local serving_nutrients serving_energy_kj serving_energy_kcal serving_carb_g serving_protein_g serving_fat_g serving_freesugar_g serving_fibre_g serving_sfa_mg serving_mufa_mg serving_pufa_mg serving_cholesterol_mg serving_calcium_mg serving_phosphorus_mg serving_magnesium_mg serving_sodium_mg serving_potassium_mg serving_iron_mg serving_copper_mg serving_selenium_ug serving_chromium_mg serving_manganese_mg serving_molybdenum_mg serving_zinc_mg serving_vita_ug serving_vite_mg serving_vitd2_ug serving_vitd3_ug serving_vitk1_ug serving_vitk2_ug serving_folate_ug serving_vitb1_mg serving_vitb2_mg serving_vitb3_mg serving_vitb5_mg serving_vitb6_mg serving_vitb7_ug serving_vitb9_ug serving_vitc_mg serving_carotenoids_ug

foreach var1 of varlist `serving_nutrients' {
    gen unit_`var1' = `var1'/size_of_servings
  } 

drop energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

drop serving_energy_kj serving_energy_kcal serving_carb_g serving_protein_g serving_fat_g serving_freesugar_g serving_fibre_g serving_sfa_mg serving_mufa_mg serving_pufa_mg serving_cholesterol_mg serving_calcium_mg serving_phosphorus_mg serving_magnesium_mg serving_sodium_mg serving_potassium_mg serving_iron_mg serving_copper_mg serving_selenium_ug serving_chromium_mg serving_manganese_mg serving_molybdenum_mg serving_zinc_mg serving_vita_ug serving_vite_mg serving_vitd2_ug serving_vitd3_ug serving_vitk1_ug serving_vitk2_ug serving_folate_ug serving_vitb1_mg serving_vitb2_mg serving_vitb3_mg serving_vitb5_mg serving_vitb6_mg serving_vitb7_ug serving_vitb9_ug serving_vitc_mg serving_carotenoids_ug

*save the nutrient values with two decimal points
local unit_nutrients unit_serving_energy_kj unit_serving_energy_kcal unit_serving_carb_g unit_serving_protein_g unit_serving_fat_g unit_serving_freesugar_g unit_serving_fibre_g unit_serving_sfa_mg unit_serving_mufa_mg unit_serving_pufa_mg unit_serving_cholesterol_mg unit_serving_calcium_mg unit_serving_phosphorus_mg unit_serving_magnesium_mg unit_serving_sodium_mg unit_serving_potassium_mg unit_serving_iron_mg unit_serving_copper_mg unit_serving_selenium_ug unit_serving_chromium_mg unit_serving_manganese_mg unit_serving_molybdenum_mg unit_serving_zinc_mg unit_serving_vita_ug unit_serving_vite_mg unit_serving_vitd2_ug unit_serving_vitd3_ug unit_serving_vitk1_ug unit_serving_vitk2_ug unit_serving_folate_ug unit_serving_vitb1_mg unit_serving_vitb2_mg unit_serving_vitb3_mg unit_serving_vitb5_mg unit_serving_vitb6_mg unit_serving_vitb7_ug unit_serving_vitb9_ug unit_serving_vitc_mg unit_serving_carotenoids_ug

foreach var1 of varlist `unit_nutrients' {
	format `var1' %9.2f
  } 

drop amount_g recipe_name_org recipe_code_org no_of_servings size_of_servings
save "$data\temp_recipes_servingsize_nrf.dta", replace

*ORGANISE DATA
*label variables
label var servings_unit "The serving unit of the recipe"

label var unit_serving_energy_kj "Total energy (kilojoules) per serving unit (with retention factor)"
label var unit_serving_energy_kcal "Total energy (kilocalories) per serving unit (with retention factor)"
label var unit_serving_carb_g "Total carbohydrates (g) per serving unit (with retention factor)"
label var unit_serving_protein_g "Total protein (g) per serving unit (with retention factor)"
label var unit_serving_fat_g "Total fat (g) per serving unit (with retention factor)"
label var unit_serving_freesugar_g "Total free sugars (g) per serving unit (with retention factor)"
label var unit_serving_fibre_g "Total fibre (g) per serving unit (with retention factor)"
label var unit_serving_sfa_mg "Total saturated fatty acids (mg) per serving unit (with retention factor)"
label var unit_serving_mufa_mg "Total monounsaturated fatty acids (mg) per serving unit (with retention factor)"
label var unit_serving_pufa_mg "Total polyunsaturated fatty acids (mg) per serving unit (with retention factor)"
label var unit_serving_cholesterol_mg "Total cholesterol (mg) per serving unit (with retention factor)"
label var unit_serving_calcium_mg "Total calcium (mg) per serving unit (with retention factor)"
label var unit_serving_phosphorus_mg "Total phosphorus (mg) per serving unit (with retention factor)"
label var unit_serving_magnesium_mg "Total magnesium (mg) per serving unit (with retention factor)"
label var unit_serving_sodium_mg "Total sodium (mg) per serving unit (with retention factor)"
label var unit_serving_potassium_mg "Total potassium (mg) per serving unit (with retention factor)"
label var unit_serving_iron_mg "Total iron (mg) per serving unit (with retention factor)"
label var unit_serving_copper_mg "Total copper (mg) per serving unit (with retention factor)"
label var unit_serving_selenium_ug "Total selenium (ug) per serving unit (with retention factor)"
label var unit_serving_chromium_mg "Total chromium (mg) per serving unit (with retention factor)"
label var unit_serving_manganese_mg "Total manganese (mg) per serving unit (with retention factor)"
label var unit_serving_molybdenum_mg "Total molybdenum (mg) per serving unit (with retention factor)"
label var unit_serving_zinc_mg "Total zinc (mg) per serving unit (with retention factor)"
label var unit_serving_vita_ug "Total vitamin A (ug) per serving unit (with retention factor)"
label var unit_serving_vite_mg "Total vitamin E (mg) per serving unit (with retention factor)"
label var unit_serving_vitd2_ug "Total vitamin D2 (ug) per serving unit (with retention factor)"
label var unit_serving_vitd3_ug "Total vitamin D3 (ug) per serving unit (with retention factor)"
label var unit_serving_vitk1_ug "Total vitamin K1 (ug) per serving unit (with retention factor)"
label var unit_serving_vitk2_ug "Total vitamin K2 (ug) per serving unit (with retention factor)"
label var unit_serving_folate_ug "Total folate (ug) per serving unit (with retention factor)"
label var unit_serving_vitb1_mg "Total vitamin B1 (mg) per serving unit (with retention factor)"
label var unit_serving_vitb2_mg "Total vitamin B2 (mg) per serving unit (with retention factor)"
label var unit_serving_vitb3_mg "Total vitamin B3 (mg) per serving unit (with retention factor)"
label var unit_serving_vitb5_mg "Total vitamin B5 (mg) per serving unit (with retention factor)"
label var unit_serving_vitb6_mg "Total vitamin B6 (mg) per serving unit (with retention factor)"
label var unit_serving_vitb7_ug "Total vitamin B7 (ug) per serving unit (with retention factor)"
label var unit_serving_vitb9_ug "Total vitamin B9 (ug) per serving unit (with retention factor)"
label var unit_serving_vitc_mg "Total vitamin C (mg) per serving unit (with retention factor)"
label var unit_serving_carotenoids_ug "Total carotenoids (ug) per serving unit (with retention factor)"

save "$data\temp_recipes_servingsize_nrf.dta", replace

*merge with 100g of recipes
use "$data\temp_recipes_servingsize_nrf.dta"

sort recipe_code
merge n:n recipe_code using "$data\temp_recipes_100G_nrf_$date"
drop _merge

order primarysource energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug, after(recipe_name)

rename recipe_name (food_name)
rename recipe_code (food_code)
rename recipe_code_org (food_code_org)

save "$data\INDB_recipes_nrf_$date.dta", replace

********************************************************************************
*COMPLETE FCT nutrient retention factor
********************************************************************************

*append to FCT

*Complete FCT 
use "$data\temp_fct", replace

append using "$data\INDB_recipes_nrf_$date.dta", force

drop food_code_org retention_factor

order secondarysource food_group_nin, after(primarysource)

*save the nutrient values with two decimal points
local nutrients energy_kj energy_kcal carb_g protein_g fat_g freesugar_g fibre_g sfa_mg mufa_mg pufa_mg cholesterol_mg calcium_mg phosphorus_mg magnesium_mg sodium_mg potassium_mg iron_mg copper_mg selenium_ug chromium_mg manganese_mg molybdenum_mg zinc_mg vita_ug vite_mg vitd2_ug vitd3_ug vitk1_ug vitk2_ug folate_ug vitb1_mg vitb2_mg vitb3_mg vitb5_mg vitb6_mg vitb7_ug vitb9_ug vitc_mg carotenoids_ug

foreach var1 of varlist `nutrients' {
	format `var1' %9.2f
  } 

save "$data\INDB_nrf_$date", replace
export excel "$output\INDB_nrf_$date", firstrow(variables) replace