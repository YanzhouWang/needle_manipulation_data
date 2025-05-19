# Needle Manipulation Data
Public data and code used for RAL 2025 submission. Code written in MATLAB.

## Cloning and Unpacking Data

1. **Clone the repository:**

   ```bash
   git clone https://github.com/YanzhouWang/needle_manipulation_data.git
   cd needle_manipulation_data/matlab_scripts

2. **Unzip recorded data:**

   In `matlab`, do

   ```bash
   unzip_data
   ```
   A `data` folder should appear inside the `matlab_scripts` folder, with contents from `experiment_results.zip` unzipped inside `data`.

## Generating Plots

A few scripts can be run in `matlab` to generate the plots used in the submission.

- `steering_vs_manipulation`:
This file uses `steering_plan.mat` and `manipulation_plan.mat` to recreate the __steering__ and __manipulation__ strategies. Environment is automatically loaded with `init_fem_comp_params`, and a file named `two_plans.png` is created with the help of `single_result_draw`

- `targeting_accuracy`:
  This file calculates the targeting performance inside plastisol and chicken breast tissue phantoms. Depending on the set of experiment chosen (by uncommenting corresponding block of code), recorded runs in the `data` folder is loaded, and a bullseye grid plot `em_error_xxx.png` is generated.

- `single_result`:
  This file plots the needle shape and control history for a specific run. Environment is automatically loaded with `load_experiment_param`, and a file named `single_result.png` is created with the help of `single_result_draw`
