#!/usr/bin/env bash
# REQUIRES wget, grep, cut and diff IN PATH

readonly SRC_BASE_IOCS_URL="https://raw.githubusercontent.com/AmnestyTech/investigations/e60689d9765f7402502dde66affb1755a5384b08/2021-07-18_nso/domains.txt"
readonly SRC_CURRENT_IOCS_URL="https://github.com/AmnestyTech/investigations/raw/master/2021-07-18_nso/domains.txt"
readonly RESULT_IOC_LINE_TEMPLATE="{\"id\": _ID_, \"type\": \"domain\", \"tag\": \"pegasus\", \"tlp\": \"white\", \"value\": \"_IOC_\"}"
readonly RESULT_DELETE_LINE_TEMPLATE="{\"value\": \"_TODEL_\"}"
readonly RESULT_CONTENT_TEMPLATE="{\"iocs\": [_IOCS_], \"to_delete\": [_TODELS_]}"
readonly RESULT_FILE="tinypeg.iocs"
SRC_BASE=$(wget -q -O - "${SRC_BASE_IOCS_URL}")
SRC_INPUT=$(wget -q -O - "${SRC_CURRENT_IOCS_URL}")

if [[ -n "${SRC_INPUT}" || -n "${SRC_BASE}" ]]; then
	RESULT_CONTENT_BUFFER=""
	# IFS tuning to split by line instead of space in for loops
	BACKIFS=${IFS}
	IFS=$'\n'
	INDEX=0
	# Parse IOCs, each line in SRC is simply added to a template
	RESULT_IOCS_LINES_BUFFER=""
	for IOC in ${SRC_INPUT}; do
		INDEX=$(( INDEX + 1 ))
		RESULT_CURRENT_LINE=${RESULT_IOC_LINE_TEMPLATE/_ID_/$INDEX}
		RESULT_CURRENT_LINE=${RESULT_CURRENT_LINE/_IOC_/$IOC}
		RESULT_IOCS_LINES_BUFFER="${RESULT_IOCS_LINES_BUFFER}${RESULT_CURRENT_LINE}, "
	done
	if [[ "${INDEX}" -gt 0 && -n "${RESULT_IOCS_LINES_BUFFER}" && "${#RESULT_IOCS_LINES_BUFFER}" -gt 2 ]]; then
		RESULT_IOCS_LINES_BUFFER=${RESULT_IOCS_LINES_BUFFER:0:-2}
		echo "Successfully converted ${INDEX} domains in ${RESULT_FILE}"
	else
		echo "Could not add any IOCs from ${SRC_CURRENT_IOCS_URL}" >&2
	fi
	RESULT_CONTENT_BUFFER=${RESULT_CONTENT_TEMPLATE/_IOCS_/$RESULT_IOCS_LINES_BUFFER}
	# Determine IOCs to delete by comparing to the initial (first commit) source IOCs list
	# TODO: this is not covering all cases, and should be created from previous source
	# commit instead.
	RESULT_TODELS_LINES_BUFFER=""
	SRC_DELETE_CONTENT=$(diff -i -E -w -B -a <(echo "${SRC_BASE}") <(echo "${SRC_INPUT}") | grep "<" | cut -d " " -f 2)
	INDEX=0
	if [[ -n "${SRC_DELETE_CONTENT}" ]]; then
		for TODEL in ${SRC_DELETE_CONTENT}; do
			INDEX=$(( INDEX + 1 ))
			DELETE_CURRENT_LINE=${RESULT_DELETE_LINE_TEMPLATE/_TODEL_/$TODEL}
			RESULT_TODELS_LINES_BUFFER="${RESULT_TODELS_LINES_BUFFER}${DELETE_CURRENT_LINE}, "
		done
	fi
	# IFS restore
	IFS=${BACKIFS}
	if [[ "${INDEX}" -gt 0 && -n "${RESULT_TODELS_LINES_BUFFER}" && "${#RESULT_TODELS_LINES_BUFFER}" -gt 2 ]]; then
		RESULT_TODELS_LINES_BUFFER=${RESULT_TODELS_LINES_BUFFER:0:-2}
		echo "Successfully added ${INDEX} domains to delete in ${RESULT_FILE}"
	else
		echo "No IOCs to delete has been found from ${SRC_CURRENT_IOCS_URL}" >&2
	fi
	RESULT_CONTENT_BUFFER=${RESULT_CONTENT_BUFFER/_TODELS_/$RESULT_TODELS_LINES_BUFFER}
	# Write to result file
	echo "${RESULT_CONTENT_BUFFER}" > "${RESULT_FILE}"
else
	echo "Could not wget input URLs" >&2
fi

