#!/bin/bash

# automatic test for PhenoMeNal


function error_trap() {
  echo "#### Error at line ${BASH_LINENO[0]} running command ${BASH_COMMAND} ####" >&2
}

trap error_trap ERR

set -o errexit
set -o nounset

function log() {
  echo -e "${@}" >&2
}

function compare_and_verify() {
  local test_output="${1}"
  local expected_output="${2}"

  if ! diff -q "${expected_output}" "${test_output}"; then
    log "UNEXPECTED DIFFERENCES IN ${test_output}"
    log "Test failed"
    exit 1
  fi
}

# Download the data files
echo "Downloading data..." >&2
wget -O test_data.zip https://www.dropbox.com/s/c3453n1io7dzp4j/test_data.zip 
unzip -o test_data.zip

log "Preparing input and reference files"
mkdir -p test_outputs

log "##### Running SliceSpectra test #######"

SliceSpectra.R --input=test_data/inputdata.tsv --output=test_outputs/out_slice.csv --retainPpm=4-1 --remWater=Y
compare_and_verify test_data/out_slice.csv test_outputs/out_slice.csv

log "##### Running Spectra Normalisation tests #######"

Normalise.R --input=test_data/inputdata.tsv --output=test_outputs/out_norm_PQN.csv --type=PQN
compare_and_verify test_data/out_norm_PQN.csv test_outputs/out_norm_PQN.csv

Normalise.R --input=test_data/inputdata.tsv --output=test_outputs/out_norm_totArea.csv --type=totInt
compare_and_verify test_data/out_norm_totArea.csv test_outputs/out_norm_totArea.csv

Normalise.R --input=test_data/inputdata.tsv --output=test_outputs/out_norm_refPeak.csv --type=refPeak --param=0.32-0.33
compare_and_verify test_data/out_norm_refPeak.csv test_outputs/out_norm_refPeak.csv

log "##### Running Peak-picking test  #######"

PeakPick.R --input=test_data/out_slice_norm.csv --output=test_outputs/out_peaks.csv
compare_and_verify test_data/out_peaks.csv test_outputs/out_peaks.csv

log "##### Running Spectra local Alignment test #######"

Align.R --inData=test_data/out_slice_norm.csv --inPeaks=test_data/out_peaks.csv --output=test_outputs/out_aligned.csv
compare_and_verify test_data/out_aligned.csv test_outputs/out_aligned.csv

log "##### Running Spectra global Alignment test #######"

GlobalAlign.R --input=test_data/out_norm_PQN.csv --output=test_outputs/out_aligned_global.csv
compare_and_verify test_data/out_aligned_global.csv test_outputs/out_aligned_global.csv

log "##### Running Pattern prep tests  #######"

log "..making uniform bin table"

prepPattern.R --method=uniform --dataSet=test_data/out_norm_PQN.csv --output=test_outputs/bins_uniform.csv --binSize=0.05
compare_and_verify test_data/bins_uniform.csv test_outputs/bins_uniform.csv

log "..making bin table from Bruker pattern file"

prepPattern.R --method=brukerPattern --pattern=test_data/Bruker_pattern.txt --output=test_outputs/bins_bruker.csv
compare_and_verify test_data/bins_bruker.csv test_outputs/bins_bruker.csv

log "..making bin table from a csv file"

prepPattern.R --method=csvTable --pattern=test_data/customPattern.csv --output=test_outputs/bins_fromcsv.csv
compare_and_verify test_data/bins_fromcsv.csv test_outputs/bins_fromcsv.csv

log "##### Running Binning test  #######"

BinSpectra.R --input=test_data/out_norm_PQN.csv --output=test_outputs/out_binned_uniform.csv --pattern=test_data/bins_uniform.csv
compare_and_verify test_data/out_binned_uniform.csv test_outputs/out_binned_uniform.csv

log "##### Running Data Scaling tests  #######"

Scaling.R --input=test_data/out_binned_uniform.csv --output=test_outputs/scaled_data_auto.csv --method=auto
compare_and_verify test_data/scaled_data_auto.csv test_outputs/scaled_data_auto.csv

Scaling.R --input=test_data/out_binned_uniform.csv --output=test_outputs/scaled_data_pareto.csv --method=pareto
compare_and_verify test_data/scaled_data_pareto.csv test_outputs/scaled_data_pareto.csv

Scaling.R --input=test_data/out_binned_uniform.csv --output=test_outputs/scaled_data_range.csv --method=range
compare_and_verify test_data/scaled_data_range.csv test_outputs/scaled_data_range.csv

Scaling.R --input=test_data/out_binned_uniform.csv --output=test_outputs/scaled_data_mean.csv --method=mean
compare_and_verify test_data/scaled_data_mean.csv test_outputs/scaled_data_mean.csv


log "##### Running Data transformation test  #######"

transform.R --input=test_data/out_binned_uniform_pos.csv --output=test_outputs/trans_data_log.csv --method=log
compare_and_verify test_data/trans_data_log.csv test_outputs/trans_data_log.csv

transform.R --input=test_data/out_binned_uniform_pos.csv --output=test_outputs/trans_data_sqrt.csv --method=sqrt
compare_and_verify test_data/trans_data_sqrt.csv test_outputs/trans_data_sqrt.csv


log "##### Running t-test test  #######"
rm -rf test_outputs/ttest_out
Ttest.R --input=test_data/out_binned_uniform.csv --output=test_outputs/ttest_out.html --outdir=test_outputs/ttest_out --factorFile=test_data/fact_small.txt --factorCol=1 --tails=two.sided --paired=N --conf_level=0.05

if [ ! -d test_outputs/ttest_out ]; then
  log "OUTPUT FOLDER NOT CREATED"
  log "Test failed"
  exit 1
elif [ ! -f  test_outputs/ttest_out/p_Vals.png ]; then
  log "Plot file ttest_out/pVals.png wasn't generated"
  log "Test failed"
  exit 3
elif [ ! -f  test_outputs/ttest_out/meanBars.png ]; then
  log "Plot file ttest_out/meanBars.png wasn't generated"
  log "Test failed"
  exit 4
fi
compare_and_verify test_data/ttest_files/pvals.txt test_outputs/ttest_out/pvals.txt

log "##### Running Anova test  #######"
rm -rf test_outputs/anova_out
Anova.R --input=test_data/out_binned_uniform.csv --output=test_outputs/anova_out.html --outdir=test_outputs/anova_out --factorFile=test_data/fact_small.txt --factorCol=2 --conf_level=0.05 --adjust=BH

if [ ! -d test_outputs/anova_out ]; then
	log "OUTPUT FOLDER NOT CREATED"
	log "Test failed"
	exit 1
elif [ ! -f  test_outputs/anova_out/AnovaPlot.png ]; then
  log "Plot file anova_out/AnovaPlot.png wasn't generated"
  log "Test failed"
  exit 3
fi
compare_and_verify test_data/anova_files/pvals.txt test_outputs/anova_out/pvals.txt

log "##### Running PCA test  #######"
rm -rf test_outputs/pca_out
PCA.R --input=test_data/out_binned_uniform.csv --output=test_outputs/pca_out.html --outdir=test_outputs/pca_out --factorFile=test_data/fact_small.txt --factorCol=2 --pcs="1-2,1-3" --scale=Y --showScores=Y --showLoadings=Y --showVarAcc=Y

if [ ! -d test_outputs/pca_out ]; then
	log "OUTPUT FOLDER NOT CREATED"
	log "Test failed"
	exit 1
elif [ ! -f  test_outputs/pca_out/VarAcc.png ]; then
	log "Plot file pca_out/VarAcc.png wasn't generated"
	log "Test failed"
	exit 2
elif [ ! -f  test_outputs/pca_out/PC_1-2_scores.png ]; then
	log "Plot file pca_out/PC_1-2_scores.png wasn't generated"
	log "Test failed"
	exit 3
elif [ ! -f  test_outputs/pca_out/PC_1-3_scores.png ]; then
	log "Plot file pca_out/PC_1-3_scores.png wasn't generated"
	log "Test failed"
	exit 4
elif [ ! -f  test_outputs/pca_out/PC_1-2_loadings.png ]; then
	log "Plot file pca_out/PC_1-2_loadings.png wasn't generated"
	log "Test failed"
	exit 5
elif [ ! -f  test_outputs/pca_out/PC_1-3_loadings.png ]; then
	log "Plot file pca_out/PC_1-2_loadings.png wasn't generated"
	log "Test failed"
	exit 6
fi

#log "##### Running  PLSDA test  #######"
rm -rf test_outputs/plsda_out
PLSDA.R --input=test_data/out_binned_uniform.csv --output=test_outputs/plsda_out.html --outDir=test_outputs/plsda_out --factorFile=test_data/fact_small.txt --factorCol=2

if [ ! -d test_outputs/plsda_out ]; then
  log "OUTPUT FOLDER NOT CREATED"
  log "Test failed"
  exit 1
elif [ ! -f  test_outputs/plsda_out/PLSDA_Scores.png ]; then
  log "Plot file plsda_out/PLSDA_Scores.png wasn't generated"
  log "Test failed"
  exit 2
elif [ ! -f  test_outputs/plsda_out/VIP.png ]; then
  log "Plot file plsda_out/VIP.png wasn't generated"
  log "Test failed"
  exit 3
elif [ ! -f  test_outputs/plsda_out/Diagnostics.png ]; then
  log "Plot file plsda_out/Diagnostics.png wasn't generated"
  log "Test failed"
  exit 4
fi

####### TODO: inplement the new plsda and add tests

log "##### Running  Spectra Plot test  #######"
rm -rf test_outputs/out_spectra_plots
PlotNMR.R --input=test_data/inputdata.tsv --output=test_outputs/out_spectra_plots.html --outDir=test_outputs/out_spectra_plots --ppmInt=3-2 --spread=N

if [ ! -d test_outputs/out_spectra_plots ]; then
	log "OUTPUT FOLDER NOT CREATED"
	log "Test failed"
	exit 1
elif [ ! -f test_outputs/out_spectra_plots/NMRplot.png ]; then
	log "Plot file out_spectra_plots/NMRplot.png wasn't generated"
	log "Test failed"
	exit 2
fi

log "##### Running  Significant Bins Plot test  #######"
rm -rf test_outputs/out_sig_plots
PlotNMRSig.R --input=test_data/inputdata.tsv --output=test_outputs/out_sig_plots.html --outDir=test_outputs/out_sig_plots --ppmInt=4-2 --bins=test_data/bins_uniform.csv --pvals=test_data/pvals --colourbar=discrete

if [ ! -d test_outputs/out_sig_plots ]; then
	log "OUTPUT FOLDER NOT CREATED"
	log "Test failed"
	exit 1
elif [ ! -f  test_outputs/out_sig_plots/NMRSigPlot.png ]; then
	log "Plot file out_sig_plots/NMRSigPlot.png wasn't generated"
	log "Test failed"
	exit 2
fi

log "##### Running  Quantile Plot test  #######"
rm -rf test_outputs/out_quantile_plots
QuantilePlot.R --input=test_data/inputdata.tsv --output=test_outputs/out_quantile_plots.html --outDir=test_outputs/out_quantile_plots --ppmInt=3-2 --pltMean=Y

if [ ! -d test_outputs/out_quantile_plots ]; then
	log "OUTPUT FOLDER NOT CREATED"
	log "Test failed"
	exit 1
elif [ ! -f  test_outputs/out_quantile_plots/QuantilePlot.png ]; then
	log "Plot file out_quantile_plots/QuantilePlot.png wasn't generated"
	log "Test failed"
	exit 2
fi

log "Tests passed"
log "Removing test files"

rm -r test_outputs
rm -r test_data
rm test_data.zip

exit 0
