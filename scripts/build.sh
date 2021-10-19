#!/bin/bash
# gzc 6/8/2021
# Antora file
antora_file="antora-playbook.yml"
# File to edit to support the search UI with lunr
generate_site_file="generate-site.js"
# Path in netlify where is located the node modules dir
node_modules_path="/opt/buildhome/.nvm/versions/node/$NODE_VERSION/lib/node_modules"
# Path where is the generate_site.js file
generate_site_file_path="$node_modules_path/@antora/site-generator-default/lib"
supplemental_ui_dir="$node_modules_path/antora-lunr/supplemental_ui"

echo build
echo Start antora
echo Using $antora_file
npm install -g @antora/cli
npm install -g @antora/site-generator-default
npm i asciidoctor asciidoctor-kroki
npm i -g antora-lunr
npm list -g --depth 0
cp -r $supplemental_ui_dir ./ 
sed -i "/use strict/!b;n;c const generateIndex = require('antora-lunr')" "${generate_site_file_path}/${generate_site_file}"
sed -i "/const siteFiles = mapSite(playbook, pages).concat(produceRedirects(playbook, contentCatalog))/!b;n;c const index = generateIndex(playbook, pages, contentCatalog, env)\nsiteFiles.push(generateIndex.createIndexFile(index))" "${generate_site_file_path}/${generate_site_file}"
sed -i s/\$GITHUB_TOKEN/$GITHUB_TOKEN/ $antora_file
DOCSEARCH_ENABLED=true DOCSEARCH_ENGINE=lunr DOCSEARCH_INDEX_VERSION=lates antora $antora_file
echo Antora: done