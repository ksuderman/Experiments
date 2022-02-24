#!/usr/bin/env bash

function write_to_file() {
	fname=$(printf "./assets/rules/%sx%s.yml" $1 $2)
	python3 bin/make-job-conf.py $1 $2 > $fname
	echo "Wrote $fname"
}

function render() {
	write_to_file $1 $2
	write_to_file $(($1 - 1)) $(($2 - 1))
}

render 4 8
render 4 16
render 8 16
render 8 32
render 16 32
render 16 64
