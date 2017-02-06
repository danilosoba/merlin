#!/bin/sh

# top merlin directory
merlin_dir="/l/SRC/merlin"
# tools directory
glotthmm="${merlin_dir}/tools/GlottHMM/src/"
confg_default="${merlin_dir}/tools/GlottHMM/cfg/config_default"
sptk="${merlin_dir}/tools/bin/SPTK-3.9"

# Data directory
data_dir="/l/SRC/merlin/egs/slt_arctic/s1/slt_arctic_demo_data"
# input audio directory
wav_dir="${data_dir}/wav"

# Output features directory
f0_dir="${data_dir}/F0"
lsf_dir="${data_dir}/lsf"
hnr_dir="${data_dir}/hnr"
lsfsource_dir="${data_dir}/lsfsource"
gain_dir="${data_dir}/gain"
lf0_dir="${data_dir}/lf0"
resyn_dir="${data_dir}/resyn"

mkdir -p $lsf_dir
mkdir -p $hnr_dir
mkdir -p $lsfsource_dir
mkdir -p $gain_dir
mkdir -p $f0_dir
mkdir -p $lf0_dir
mkdir -p $resyn_dir

# initializations
fs=16000
LPC_ORDER_SOURCE=10
HNR_CHANNELS=5

if [ "$fs" -eq 16000 ]
then
SAMPLING_FREQUENCY=16000
LPC_ORDER=30
WARPING_VT=0.0
HPFILTER_FILENAME="${merlin_dir}/tools/GlottHMM/cfg/hp_16khz"
fi

if [ "$fs" -eq 48000 ]
then
SAMPLING_FREQUENCY=48000
LPC_ORDER=50
WARPING_VT=0.35
HPFILTER_FILENAME="${merlin_dir}/tools/GlottHMM/cfg/hp_44khz"
fi

for file in $wav_dir/*.wav #.wav
do
    filename="${file##*/}"
    file_id="${filename%.*}"
   
    echo $file_id

    ### GlottHMM ANALYSIS -- extract vocoder parameters ###
    echo '
#########################################################
#   User configuration file for GlottHMM (v. 1.1)    #
#########################################################

# Analysis and Synthesis: Common parameters:
	SAMPLING_FREQUENCY = 	'$SAMPLING_FREQUENCY';
	FRAME_LENGTH = 			25.0;
	UNVOICED_FRAME_LENGTH = 	20.0;
	F0_FRAME_LENGTH = 		45.0;
	FRAME_SHIFT = 			5.0;
	LPC_ORDER = 			'$LPC_ORDER';
	LPC_ORDER_SOURCE = 		'$LPC_ORDER_SOURCE';
	WARPING_VT = 			'$WARPING_VT';
	WARPING_GL = 			0.0;
	HNR_CHANNELS = 			'$HNR_CHANNELS';
	NUMBER_OF_HARMONICS = 		10;
	SEPARATE_VU_SPECTRUM = 		false;
	DIFFERENTIAL_LSF = 		false;
    UNVOICED_PRE_EMPHASIS =     	false;
	LOG_F0 = 			false;
	DATA_FORMAT = 			"ASCII";	# Choose between "ASCII" / "BINARY"


# Noise reduction
	NOISE_REDUCTION_ANALYSIS = 	false;
	NOISE_REDUCTION_SYNTHESIS = 	false;
	NOISE_REDUCTION_LIMIT_DB = 	2.0;
	NOISE_REDUCTION_DB = 		30.0;


# Analysis:
# Analysis: General parameters:
    PITCH_SYNCHRONOUS_ANALYSIS = 	false;
    INVERT_SIGNAL = 		false;
    HP_FILTERING = 			true;
    HPFILTER_FILENAME =     "'$HPFILTER_FILENAME'";

# Analysis: Parameters for F0 estimation:
    F0_MIN = 			50.0;
    F0_MAX = 			300.0;
    VOICING_THRESHOLD = 		100.0;
    ZCR_THRESHOLD = 		120.0;
    USE_F0_POSTPROCESSING = 	false;
    RELATIVE_F0_THRESHOLD = 	0.005;
    F0_CHECK_RANGE = 		10;
    USE_EXTERNAL_F0 = 		false;
    EXTERNAL_F0_FILENAME = 		"wavs/filename.F0";

# Analysis: Parameters for extracting pulse libraries:
    MAX_NUMBER_OF_PULSES = 		10000;
    PULSEMAXLEN = 			45.0;
    RESAMPLED_PULSELEN = 		10.0;
    WAVEFORM_SAMPLES = 		10;
    MAX_PULSE_LEN_DIFF = 		0.05;
    EXTRACT_ONLY_UNIQUE_PULSES =	false;
    EXTRACT_ONE_PULSE_PER_FRAME =	false;

# Analysis: Parameters for spectral modeling:
    USE_IAIF = 			true;
    LPC_ORDER_GL_IAIF = 		8;		# Order of the LPC analysis for voice source in IAIF
    USE_MOD_IAIF = 			false;		# Modified version of IAIF
    LP_METHOD = 			"LPC";		# Select between "LPC" / "WLP" / "XLP"
    LP_STABILIZED = 		false;
    LP_WEIGHTING = 			"STE";		# Select between "STE" / "GCI"
    FORMANT_PRE_ENH_METHOD = 	"NONE";		# Select between "NONE" / "LSF" / "LPC"
    FORMANT_PRE_ENH_COEFF = 	0.5;
    FORMANT_PRE_ENH_LPC_DELTA = 	20.0;		# Only for LPC-based method

# Analysis: Select parameters to be extracted:
    EXTRACT_F0 = 			true;
    EXTRACT_GAIN = 			true;
    EXTRACT_LSF = 			true;
    EXTRACT_LSFSOURCE =     	true;
    EXTRACT_HNR = 			true;
    EXTRACT_HARMONICS = 		false;
    EXTRACT_H1H2 = 			false;
    EXTRACT_NAQ = 			false;
    EXTRACT_WAVEFORM = 		false;
    EXTRACT_INFOFILE =		true;
    EXTRACT_PULSELIB = 		true;
    EXTRACT_FFT_SPECTRA =   	false;
    EXTRACT_SOURCE = 		false;




# Synthesis:
# Synthesis: General parameters:
    SYNTHESIZE_MULTIPLE_FILES = 	false;
    SYNTHESIS_LIST = 		"synthesis_list_filename";
    USE_HMM = 			false;

# Synthesis: Single pulse
    GLOTTAL_PULSE_NAME = 		"'${merlin_dir}/tools/GlottHMM/pulses/gpulse'";
    TWO_PITCH_PERIOD_DIFF_PULSE = 	false;

# Synthesis: DNN pulse generation
    USE_DNN_PULSEGEN =		false;
    USE_DNN_PULSELIB_SEL =		false;
    USE_DNN_SPECMATCH = 		false;
    DNN_WEIGHT_PATH = 		"DNNTrain/dnnw/";
    DNN_WEIGHT_DIMS = 		[48, 200, 201, 200, 201, 400];
    DNN_INPUT_NORMALIZED =		true;
    DNN_NUMBER_OF_STACKED_FRAMES =	1;

# Synthesis: Choose excitation technique and related parameters:
    USE_PULSE_LIBRARY = 		false;
    PULSE_LIBRARY_NAME = 		"pulse_libraries/pulselib1/pulselib1";
    NORMALIZE_PULSELIB = 		false;
    USE_PULSE_CLUSTERING = 		false;
    USE_PULSE_INTERPOLATION = 	true;
    AVERAGE_N_ADJACENT_PULSES = 	0;
    ADD_NOISE_PULSELIB = 		true;
    MAX_PULSES_IN_CLUSTER = 	2000;
    NUMBER_OF_PULSE_CANDIDATES = 	200;
    PULSE_ERROR_BIAS = 		0.3;
    CONCATENATION_COST = 		1.0;
    TARGET_COST = 			1.0;
    PARAMETER_WEIGHTS = 		[0.0, 1.0, 1.0, 2.0, 3.0, 5.0, 1.0, 1.0, 1.0, 0.0];
    #Parameter names   		[LSF  SRC  HARM HNR  GAIN F0   WAV  H1H2 NAQ  PCA]

# Synthesis: Select used parameters:
    # F0, Gain, and LSFs are always used
    USE_LSFSOURCE = 		true;
    USE_HNR = 			true;
    USE_HARMONICS = 		false;
    USE_H1H2 = 			false;
    USE_NAQ = 			false;
    USE_WAVEFORM = 			false;
    USE_MELSPECTRUM =		false;
    USE_PULSE_PCA = 		false;

# Synthesis: Set level and band of voiced noise:
    NOISE_GAIN_VOICED = 		1.0;
    NOISE_LOW_FREQ_LIMIT = 		2000.0;	# Hz
    HNR_COMPENSATION =          	false;

# Synthesis: Smoothing of parameters for analysis-synthesis:
    LSF_SMOOTH_LEN = 		5;
    LSFSOURCE_SMOOTH_LEN = 		3;
    GAIN_SMOOTH_LEN = 		5;
    HNR_SMOOTH_LEN = 		15;
    HARMONICS_SMOOTH_LEN = 		5;

# Synthesis: Gain related parameters:
    GAIN_UNVOICED = 		1.0;
    NORM_GAIN_SMOOTH_V_LEN = 	0;
    NORM_GAIN_SMOOTH_UV_LEN = 	0;
    GAIN_VOICED_FRAME_LENGTH = 	25.0;
    GAIN_UNVOICED_FRAME_LENGTH = 	20.0;

# Synthesis: Postfiltering:
    POSTFILTER_METHOD = 		"LPC";	# Select between "NONE" / "LSF" / "LPC"
    POSTFILTER_COEFFICIENT = 	0.4;

# Synthesis: Utils:
    USE_HARMONIC_MODIFICATION = 	false;
    HP_FILTER_F0 = 			false;
    FILTER_UPDATE_INTERVAL_VT = 	0.3;
    FILTER_UPDATE_INTERVAL_GL = 	0.05;
    WRITE_EXCITATION_TO_WAV = 	false;

# Synthesis: Voice adaptation:
    PITCH = 			1.0;
    SPEED = 			1.0;
    JITTER = 			0.0;
    ADAPT_TO_PULSELIB = 		false;
    ADAPT_COEFF = 			1.0;
    USE_PULSELIB_LSF = 		false;
    NOISE_ROBUST_SPEECH = 		false;

# Synthesis: Pulse library PCA:
    USE_PULSELIB_PCA =		false;
    PCA_ORDER =			12;
    PCA_ORDER_SYNTHESIS =		0;
    PCA_SPECTRAL_MATCHING = 	false;
    PCA_PULSE_LENGTH = 		800;' > config_test_$file_id;

    ### extract f0, sp, ap ###
    $glotthmm/Analysis $file $confg_default config_test_$file_id

    $sptk/x2x +af $wav_dir/$file_id.F0 > $f0_dir/$file_id.F0
    $sptk/x2x +af $wav_dir/$file_id.Gain > $gain_dir/$file_id.Gain
    $sptk/x2x +af $wav_dir/$file_id.LSF > $lsf_dir/$file_id.LSF
    $sptk/x2x +af $wav_dir/$file_id.LSFsource > $lsfsource_dir/$file_id.LSFsource
    $sptk/x2x +af $wav_dir/$file_id.HNR > $hnr_dir/$file_id.HNR
    ### GlottHMM copy-synthesis -- reconstruction of parameters ###
   # $glotthmm/Synthesis $wav_dir/$file_id $config_default config_test_$file_id
   
done
# mv $wav_dir/*.syn.wav $resyn_dir
rm  config_test*
#rm -rf $resyn_dir
