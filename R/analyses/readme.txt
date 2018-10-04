R_PDT
-----

Code for publication of "Neural correlates of cue-induced changes in decision-making distinguish pathological gamblers from healthy controls"
by: Alexander Genauck (2018)


How to use
----------

Download the whole zip and put it into some working directory. The working directory you will have to indicate
at the beginning of "severity_pred_loop_v6.R":

1)
The machine learning part is started with the script "severity_pred_loop_v6.R"; put the path to working directory (root_wd = ...).
Please read the instructions at beginning of the script before running it. This script also plots the classifier estimated from the whole data set.

2)
The application of the behavioral classifier draws from the results "1010" folder; run the apply_PIT_GD_behav_to_MRI_sample_v2.R script.
Please, take note of the instructions at the beginning of the script.

3)
Producing p-values for the MRI classifier is done in classifier_against_total_H0.R; Before running the script, please go through the instructions
at beginning of script. 

4)
The univariate testing part and hierarchical regression (lme4) modeling part is done with the
/02_univariate_testing/glmer_accRate_la_cat_v2.R script; it is set such that the glmer models are run (10 to 20 minutes) but the permutation test
for the group difference in loss aversion is just loaded; running it takes about an hour or longer; see instructions and settings in the
beginning of the script

5)
Making the ratings graph. It is automatically produced when running "severity_pred_loop_v6.R".

6)
Ratings: statistical tests. Run the script /03_image_adequacy/ratings_analysis_for_paper.R


Careful: The script "severity_pred_loop_v6.R" installs and loads many R packages (see in the beginning). They are all useful and should not
hurt your installation of R or bother your other code. However, revise the list before you run the code and decide
if you would like to continue.