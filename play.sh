#!/bin/bash

cd `dirname ${BASH_SOURCE[0]}`

repo_tag=sammyne/debug-wasm:alpha

workdir=/workspace

docker run -it --rm -v $PWD:$workdir -w $workdir $repo_tag bash
