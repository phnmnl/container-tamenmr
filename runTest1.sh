#!/bin/bash

# automatic test for PhenoMeNal


function error_trap() {
  echo "#### Error at line ${BASH_LINENO[0]} running command ${BASH_COMMAND} ####" >&2
}

trap error_trap ERR

set -o errexit
set -o nounset


# Download the data files
echo "Downloading data..." >&2
wget -O test_data.zip https://www.dropbox.com/s/c3453n1io7dzp4j/test_data.zip 
unzip -o test_data.zip

echo "Preparing input and reference files" >&2
mkdir -p test_outputs

echo "##### Running SliceSpectra test #######" >&2

SliceSpectra.R --input=test_data/inputdata.tsv --output=test_outputs/out_slice.csv --retainPpm=4-1 --remWater=Y
if ! diff test_outputs/out_slice.csv test_data/out_slice.csv; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 1
fi

echo "##### Running Spectra Normalisation tests #######" >&2

Normalise.R --input=test_data/inputdata.tsv --output=test_outputs/out_norm_PQN.csv --type=PQN
if ! diff test_outputs/out_slice.csv test_data/out_slice.csv; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 1
fi

Normalise.R --input=test_data/inputdata.tsv --output=test_outputs/out_norm_totArea.csv --type=totInt
if ! diff test_outputs/out_norm_PQN.csv test_data/out_norm_PQN.csv; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 1
fi

Normalise.R --input=test_data/inputdata.tsv --output=test_outputs/out_norm_refPeak.csv --type=refPeak --param=0.32-0.33
if ! diff test_outputs/out_norm_refPeak.csv test_data/out_norm_refPeak.csv; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 1
fi

echo "##### Running Peak-picking test  #######" >&2

PeakPick.R --input=test_data/out_slice_norm.csv --output=test_outputs/out_peaks.csv
if ! diff test_outputs/out_peaks.csv test_data/out_peaks.csv; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 1
fi

echo "##### Running Spectra local Alignment test #######" >&2

Align.R --inData=test_data/out_slice_norm.csv --inPeaks=test_data/out_peaks.csv --output=test_outputs/out_aligned.csv
if ! diff test_outputs/out_aligned.csv test_data/out_aligned.csv; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 1
fi

echo "##### Running Spectra global Alignment test #######" >&2

GlobalAlign.R --input=test_data/out_norm_PQN.csv --output=test_outputs/out_aligned_global.csv
if ! diff test_outputs/out_aligned_global.csv test_data/out_aligned_global.csv; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 1
fi

echo "##### Running Pattern prep tests  #######" >&2

echo "..making uniform bin table" >&2

prepPattern.R --method=uniform --dataSet=test_data/out_norm_PQN.csv --output=test_outputs/bins_uniform.csv --binSize=0.05
if ! diff test_outputs/bins_uniform.csv test_data/bins_uniform.csv; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 1
fi

echo "..making bin table from Bruker pattern file" >&2

prepPattern.R --method=brukerPattern --pattern=test_data/Bruker_pattern.txt --output=test_outputs/bins_bruker.csv
if ! diff test_outputs/bins_bruker.csv test_data/bins_bruker.csv; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 1
fi

echo "..making bin table from a csv file" >&2

prepPattern.R --method=csvTable --pattern=test_data/customPattern.csv --output=test_outputs/bins_fromcsv.csv
if ! diff test_outputs/bins_fromcsv.csv test_data/bins_fromcsv.csv; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 1
fi

echo "##### Running Binning test  #######" >&2

BinSpectra.R --input=test_data/out_norm_PQN.csv --output=test_outputs/out_binned_uniform.csv --pattern=test_data/bins_uniform.csv
if ! diff test_outputs/out_binned_uniform.csv test_data/out_binned_uniform.csv; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 1
fi

echo "##### Running Data Scaling tests  #######" >&2

Scaling.R --input=test_data/out_binned_uniform.csv --output=test_outputs/scaled_data_auto.csv --method=auto
if ! diff test_outputs/scaled_data_auto.csv test_data/scaled_data_auto.csv; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 1
fi

Scaling.R --input=test_data/out_binned_uniform.csv --output=test_outputs/scaled_data_pareto.csv --method=pareto
if ! diff test_outputs/scaled_data_pareto.csv test_data/scaled_data_pareto.csv; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 1
fi

Scaling.R --input=test_data/out_binned_uniform.csv --output=test_outputs/scaled_data_range.csv --method=range
if ! diff test_outputs/scaled_data_range.csv test_data/scaled_data_range.csv; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 1
fi

Scaling.R --input=test_data/out_binned_uniform.csv --output=test_outputs/scaled_data_mean.csv --method=mean
if ! diff test_outputs/scaled_data_mean.csv test_data/scaled_data_mean.csv; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 1
fi


echo "##### Running Data transformation test  #######" >&2

transform.R --input=test_data/out_binned_uniform_pos.csv --output=test_outputs/trans_data_log.csv --method=log
if ! diff test_outputs/trans_data_log.csv test_data/trans_data_log.csv; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 1
fi

transform.R --input=test_data/out_binned_uniform_pos.csv --output=test_outputs/trans_data_sqrt.csv --method=sqrt
if ! diff test_outputs/trans_data_sqrt.csv test_data/trans_data_sqrt.csv; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 1
fi


echo "##### Running t-test test  #######" >&2
rm -rf test_outputs/ttest_out
Ttest.R --input=test_data/out_binned_uniform.csv --output=test_outputs/ttest_out.html --outdir=test_outputs/ttest_out --factorFile=test_data/fact_small.txt --factorCol=1 --tails=two.sided --paired=N --conf_level=0.05

if [ ! -d test_outputs/ttest_out ]; then
	echo "OUTPUT FOLDER NOT CREATED" >&2
	echo "Test failed" >&2
  exit 1
elif ! diff test_outputs/ttest_out/pvals.txt test_data/ttest_files/pvals.txt; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 2
elif [ ! -f  test_outputs/ttest_out/p_Vals.png ]; then
  echo "Plot file ttest_out/pVals.png wasn't generated" >&2
  echo "Test failed" >&2
  exit 3
elif [ ! -f  test_outputs/ttest_out/meanBars.png ]; then
  echo "Plot file ttest_out/meanBars.png wasn't generated" >&2
  echo "Test failed" >&2
  exit 4
fi


echo "##### Running Anova test  #######" >&2
rm -rf test_outputs/anova_out
Anova.R --input=test_data/out_binned_uniform.csv --output=test_outputs/anova_out.html --outdir=test_outputs/anova_out --factorFile=test_data/fact_small.txt --factorCol=2 --conf_level=0.05 --adjust=BH

if [ ! -d test_outputs/anova_out ]; then
	echo "OUTPUT FOLDER NOT CREATED" >&2
	echo "Test failed" >&2
	exit 1
elif ! diff test_outputs/anova_out/pvals.txt test_data/anova_files/pvals.txt; then
  echo "UNEXPECTED DIFFERENCES IN OUTPUT FILE" >&2
  echo "Test failed" >&2
  exit 2
elif [ ! -f  test_outputs/anova_out/AnovaPlot.png ]; then
  echo "Plot file anova_out/AnovaPlot.png wasn't generated" >&2
  echo "Test failed" >&2
  exit 3
fi


echo "##### Running PCA test  #######" >&2
rm -rf test_outputs/pca_out
PCA.R --input=test_data/out_binned_uniform.csv --output=test_outputs/pca_out.html --outdir=test_outputs/pca_out --factorFile=test_data/fact_small.txt --factorCol=2 --pcs="1-2,1-3" --scale=Y --showScores=Y --showLoadings=Y --showVarAcc=Y

if [ ! -d test_outputs/pca_out ]; then
	echo "OUTPUT FOLDER NOT CREATED" >&2
	echo "Test failed" >&2
	exit 1
elif [ ! -f  test_outputs/pca_out/VarAcc.png ]; then
	echo "Plot file pca_out/VarAcc.png wasn't generated" >&2
	echo "Test failed" >&2
	exit 2
elif [ ! -f  test_outputs/pca_out/PC_1-2_scores.png ]; then
	echo "Plot file pca_out/PC_1-2_scores.png wasn't generated" >&2
	echo "Test failed" >&2
	exit 3
elif [ ! -f  test_outputs/pca_out/PC_1-3_scores.png ]; then
	echo "Plot file pca_out/PC_1-3_scores.png wasn't generated" >&2
	echo "Test failed" >&2
	exit 4
elif [ ! -f  test_outputs/pca_out/PC_1-2_loadings.png ]; then
	echo "Plot file pca_out/PC_1-2_loadings.png wasn't generated" >&2
	echo "Test failed" >&2
	exit 5
elif [ ! -f  test_outputs/pca_out/PC_1-3_loadings.png ]; then
	echo "Plot file pca_out/PC_1-2_loadings.png wasn't generated" >&2
	echo "Test failed" >&2
	exit 6
fi

#echo "##### Running  PLSDA test  #######" >&2
rm -rf test_outputs/plsda_out
PLSDA.R --input=test_data/out_binned_uniform.csv --output=test_outputs/plsda_out.html --outDir=test_outputs/plsda_out --factorFile=test_data/fact_small.txt --factorCol=2

if [ ! -d test_outputs/plsda_out ]; then
  echo "OUTPUT FOLDER NOT CREATED" >&2
  echo "Test failed" >&2
  exit 1
elif [ ! -f  test_outputs/plsda_out/PLSDA_Scores.png ]; then
  echo "Plot file plsda_out/PLSDA_Scores.png wasn't generated" >&2
  echo "Test failed" >&2
  exit 2
elif [ ! -f  test_outputs/plsda_out/VIP.png ]; then
  echo "Plot file plsda_out/VIP.png wasn't generated" >&2
  echo "Test failed" >&2
  exit 3
elif [ ! -f  test_outputs/plsda_out/Diagnostics.png ]; then
  echo "Plot file plsda_out/Diagnostics.png wasn't generated" >&2
  echo "Test failed" >&2
  exit 4
fi

####### TODO: inplement the new plsda and add tests

echo "##### Running  Spectra Plot test  #######" >&2
rm -rf test_outputs/out_spectra_plots
PlotNMR.R --input=test_data/inputdata.tsv --output=test_outputs/out_spectra_plots.html --outDir=test_outputs/out_spectra_plots --ppmInt=3-2 --spread=N

if [ ! -d test_outputs/out_spectra_plots ]; then
	echo "OUTPUT FOLDER NOT CREATED" >&2
	echo "Test failed" >&2
	exit 1
elif [ ! -f test_outputs/out_spectra_plots/NMRplot.png ]; then
	echo "Plot file out_spectra_plots/NMRplot.png wasn't generated" >&2
	echo "Test failed" >&2
	exit 2
fi

echo "##### Running  Significant Bins Plot test  #######" >&2
rm -rf test_outputs/out_sig_plots
PlotNMRSig.R --input=test_data/inputdata.tsv --output=test_outputs/out_sig_plots.html --outDir=test_outputs/out_sig_plots --ppmInt=4-2 --bins=test_data/bins_uniform.csv --pvals=test_data/pvals --colourbar=discrete

if [ ! -d test_outputs/out_sig_plots ]; then
	echo "OUTPUT FOLDER NOT CREATED" >&2
	echo "Test failed" >&2
	exit 1
elif [ ! -f  test_outputs/out_sig_plots/NMRSigPlot.png ]; then
	echo "Plot file out_sig_plots/NMRSigPlot.png wasn't generated" >&2
	echo "Test failed" >&2
	exit 2
fi

echo "##### Running  Quantile Plot test  #######" >&2
rm -rf test_outputs/out_quantile_plots
QuantilePlot.R --input=test_data/inputdata.tsv --output=test_outputs/out_quantile_plots.html --outDir=test_outputs/out_quantile_plots --ppmInt=3-2 --pltMean=Y

if [ ! -d test_outputs/out_quantile_plots ]; then
	echo "OUTPUT FOLDER NOT CREATED" >&2
	echo "Test failed" >&2
	exit 1
elif [ ! -f  test_outputs/out_quantile_plots/QuantilePlot.png ]; then
	echo "Plot file out_quantile_plots/QuantilePlot.png wasn't generated" >&2
	echo "Test failed" >&2
	exit 2
fi

echo "Tests passed" >&2
echo "Removing test files" >&2

rm -r test_outputs
rm -r test_data
rm test_data.zip

exit 0
