# How to make a QA report:

1. Open an issue, with a suitable title.
2. In the first few lines of the description of the issue include at least one of the following
   - variable_id: \<insert here, required\>
   - experiment_id: \<Hist or SSP585\>
   - time_range: \<insert here\>
3. Make a new line and comment on your QA process.

(If you do not include one of these parameters, the bot will pass qc for all values. E.g., if you don't include time_range then all time_ranges will pass for the given variable_id and experiment. You can also pass qc for multiple time_range by using list notation.)

N.B.: It is not possible to pass QC for individual ensemble members at this time. Please make sure all 30 ensemble members pass before reporting.

## Example description:

```
variable_id: slp
experiment_id: Hist

I tested slp by ... and made sure there was no missing or corrupt data.
```

## Example description for a set of time ranges:

```
variable_id: snow
time_range: [20410101-20501231, 20110101-20201231, 20510101-20601231, 20310101-20401231]

I tested snow for these time ranges.
```
