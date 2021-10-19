#!/bin/bash
# RJM 1/10/2021
# rebuild antora doc site
rm -rf build
antora antora-playbook.yml 
cd build/site/
python -m SimpleHTTPServer 8081