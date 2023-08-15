#!/usr/bin/env bash

# for cores in 4 8 16 32 ; do
#     mem=$(($cores * 2))
#     name="$cores"x"$mem".yml
#     render_template.py -t rules-template.yml.j2 cores=$cores mem=$mem > $name
#     echo "Wrote $name"
# done
for cores in 4 8 ; do
    for mem in 8 16 32 64 ; do
        name="$cores"x"$mem".yml
        render_template.py -t rules-template.yml.j2 cores=$cores mem=$mem > $name
        echo "Wrote $name"
    done
done
cores=16
for mem in 16 32 64 ; do
    name="$cores"x"$mem".yml
    render_template.py -t rules-template.yml.j2 cores=$cores mem=$mem > $name
    echo "Wrote $name"
done
cores=32
for mem in 32 64 ; do
    name="$cores"x"$mem".yml
    render_template.py -t rules-template.yml.j2 cores=$cores mem=$mem > $name
    echo "Wrote $name"
done

