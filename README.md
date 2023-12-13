# Indian-Nutrient-Databank-INDB-
This code generates a food composition database for India called the ‘Indian Nutrient Databank (INDB).’ INDB includes raw foods and standard recipes commonly consumed in India. 

The following abbreviations are used in this README file.

FAO = Food and Agriculture Organization of the United Nations 
FCT = Food Composition Table
ICMR = Indian Council of Medical Research
IFCT = Indian Food Composition Table
NIN = National Institute of Nutrition

There are 6 data files:

1. Excel file called ‘NIN_fct.xlxs'

This contains nutrient data (amount of nutrient per 100g food item) for 932 raw foods. It is compiled from the ICMR-NIN IFCT 2004 and IFCT 2017. When duplicate food items were in the 2004 and 2017 editions, the more recent (2017) was retained. 

Nutrients include: energy, carbohydrates (carb), protein, fat, iron, calcium, zinc, sodium, cholesterol, free sugars, saturated fat (sfa), monounsaturated fat (mufa), polyunsaturated fat (pufa), fibre, folate, vitamin A (vita), vitamin B1, vitamin B2, vitamin B3, vitamin B5, vitamin B6, vitamin B7, vitamin B9, vitamin C, and carotenoids. 

Food items have also been classified into mutually exclusive food groups: grains, roots and tubers, legumes and pulses, dark green leafy vegetables (dglv-dark), other vegetables, vitamin A-rich fruits and vegetables (vita_fv), dairy, eggs, meat (including fish), other fruit, and nuts and seeds. The classification was based on the FAO Minimum Dietary Diversity for Women, available from: https://www.fao.org/3/cb3434en/cb3434en.pdf. 

2. Excel file called ‘UK_fct.xlxs'

This contains nutrient data (amount of nutrient per 100g food item) for 150 ingredients that are found in Indian recipes included in the INDB, but were not in the NIN_fct file. These data are from the 2021 version of the UK ‘McCance and Widdowson's composition of foods integrated dataset’ available from: https://www.gov.uk/government/publications/composition-of-foods-integrated-dataset-cofid. 

3. Excel file called ‘US_fct.xlxs'

This contains nutrient data (amount of nutrient per 100g food item) for 55 ingredients that are found in Indian recipes included in the INDB, but were not in the NIN_fct file or the UK dataset mentioned in #2. These data are from the US Department of Agriculture’s FoodData Central available from: https://fdc.nal.usda.gov/. 

4. Excel file called ‘recipes.xlxs'

This contains the ingredients (name, amount, amount unit, and food code linking it to the NIN_fct, UK_fct, or US_fct) of recipes. Recipes are from the following sources :

5. Excel file called ‘recipes_names.xlxs'

This contains the common names of recipes from the dataset mentioned in #4.


6. Excel file called ‘recipes_servingsize.xlxs'

This contains the serving sizes for recipes from the dataset mentioned in #4.

There is 1 code file:
1. Stata file called 'INDB.do'

This uses the FCT datasets described above to derive the nutrients per 100g recipe and per serving size of recipe. It then appends the recipe nutrient information to the ingredient nutrient information for a master IFCT with both foods and recipes. 
