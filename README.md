# SOS LASSO Simulations
The code in this repository is intended to be used in conjunction with [`WISC_MVPA`](https://github.com/crcox/WISC_MVPA) and [`InputSetup`](https://github.com/crcox/InputSetup), which are the same code bases used to run full scale LASSO, Ridge, and SOS LASSO analyses on full scale data.

## Description of the data
The following is adapted from the description in our submitted manuscript:

The repository contains simulated imaging data from the simple auto-encoder network shown below. The model was trained 10 times under identical conditions except for weight initialization to reproduce 72 input patterns over the output units. Items were sampled equally from two categories (A & B) corresponding to some cognitive distinction of interest (e.g. faces versus places). Each trained model is analogous to an individual in an fMRI study, with the BOLD signal at a single voxel simulated as the unit’s activation perturbed by independently-sampled noise.

Two subsets of units encode category information in different ways. Informative input/output (IIO) units adopt an independent code: each is weakly but reliably more active on average for items in one category (A or B) than the other. Informative hidden (IH) units connect informative input to output units, and thus learn a distributed code: after training, items from the same category always evoke similar patterns across units, but individual units vary arbitrarily in their independent correlations with category structure within and across networks. The model also includes arbitrary input-output (AIO) and hidden (AH) units that respond to stimuli but do not encode category information, and inactive units that take low random values.

We considered two anatomical layouts for the network (see figure), corresponding to two different assumptions about how units coding a distributed representation can be spatially organized. Both layouts grouped the I/O units by type (A, B, arbitrary) in the same way across model individuals, analogous to early perceptual areas where the neural code and its anatomical situation are known to be similar in different people. The localized layout also grouped hidden units by type (IH, AH, irrelevant) identically across model individuals, consistent with the common view that layers in a neural network model correspond roughly to contiguous cortical regions in the brain. The dispersed layout arranged hidden units in four anatomically distal “regions” containing a mix of IH, AH, and irrelevant units, with unit locations shuffled within region for each model subject. This condition represents the possibility suggested by neural network models that neural populations jointly contributing to a representation may be anatomically distal from one another, somewhat variable in their spatial location across individuals, and intermingled populations contributing to other representations. All models had the same connectivity—the layouts differed only in hypothesized spatial locations of the units.

In the figure below, each dot is a unit in the network. Lines in the left panel indicate full connectivity between visually grouped sets of units. Blue shading groups units that are considered anatomical neighbors. This means that spatial smoothing, searchlight definition, or the grouping for SOS LASSO will be applied such that units that are not within the same blue shaded area cannot be grouped or included in the same smoothing kernel.
 
## Step 1: Setup
The raw data `./raw/simulation_fMRI_nonoise.csv` contains the activation patters associated the activation patterns for 10 trained autoencoders (72 examples for each, so 720 rows plus 1 for the header). The first 3 columns indicate the “subject” (1 – 10; i.e., repetition of the model fit with random initial weights), the item ID (0 – 71), the example type (“A” or “B”). Remaining columns correspond to units and contain the activation value. The first 36 are input units, and so are represented as 0 or 1. The input for item ID n will be the same for all subjects (all models were trained on the same examples). The next 14 units are hidden units, which take on positive and negative real values. The final 36 units are output units, which are also real valued but reflect the input (with a degree of imprecision).

The `./setup.m` script will take this data and produce a collection of files in a subfolder (e.g., `data_01`):

```
01/14/2020  03:22 PM    <DIR>          .
01/14/2020  03:22 PM    <DIR>          ..
01/14/2020  03:22 PM         1,406,201 AnnotatedData.mat
01/14/2020  03:22 PM             4,747 ConditionIndex.mat
01/14/2020  03:22 PM            12,253 metadata.mat
01/14/2020  03:22 PM           109,698 s01_noise040.mat
01/14/2020  03:22 PM           109,738 s01_noise060.mat
01/14/2020  03:22 PM           109,873 s01_noise080.mat
01/14/2020  03:22 PM           110,077 s01_noise100.mat
01/14/2020  03:22 PM           109,709 s02_noise040.mat
01/14/2020  03:22 PM           109,752 s02_noise060.mat
…
01/14/2020  03:22 PM           109,782 s10_noise080.mat
01/14/2020  03:22 PM           110,059 s10_noise100.mat
```

The process begins by “long” formatting the raw data, such that each row corresponds to a single unit. This allows each unit to be tagged with metadata. Then, units are added that can be used as padding to separate the different shaded blue areas in the figure above, as well as units that are considered “inactive”. These units, obviously, have nothing to do with the fitting of the model nor the representation of any information. They are simply added as “true negatives”, units that we know should not be selected by the statistical method.

Several experimental conditions are also established, and these are encoded in the `ConditionIndex.mat` table and `metadata.mat` structure. The conditions are represented as different sets of coordinates for the units, and define which units are anatomical neighbors and how they align across subjects.

## Conditions
### Local
The local condition keeps all units in the positions depicted in the figure. This set of coordinates has units neatly grouped by type.

### Permuted
All hidden and uninformative units are randomly permuted with each other, such that they are all anatomical neighbors. Each subject receives a different permutation, so informative units are unlikely to line up across subjects.

### Interleaved 
The hidden and uninformative units are shuffled such that the systematic hidden units are as distant from each other as possible while still being anatomical neighbors. Each subject has their units interleaved in the same way, so the informative units will line up perfectly across subjects, but the information within subjects is distributed.

### Blocked Interleaved
This is similar to interleaved, but instead of each information unit being as distant from every other as possible, information units are spread across 3 distributed areas that are as distant from each other as possible. These 3 areas are in the same location across subjects.

### Blocked Permuted
This takes the idea of 3 distributed areas from “Blocked interleaved”. There are three areas where informative hidden units will appear, and these areas are the same across subjects. But, rather than the order of units being the same across subjects, the location of information units within each of those areas is permuted by subject. Informative units is spread across these 3 areas in a balanced way. In short, informative hidden units are certain to be spread out but the fragments will be in roughly the same place across people—but not exactly.

## Running analysis
### Univariate
Once the data have been generated, running the analysis is a matter of pointing the `bin/UnivariateAnalysis.m` function at the right data and giving it the right parameters. Check the `data/ConditionIndex.mat` file (or `data/metadata.m` file, in the coordinates field) for available conditions.

### Multivariate
All multivariate analyses are run using the WISC MVPA package linked above. The setup procedure ensures that the data are in a convenient format to work with this package. The package is well suited for high-throughput computing, which really speeds up the simulations.
